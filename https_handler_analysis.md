# HTTPS Handler Invocation Analysis - Comprehensive Report

## Executive Summary

The HTTPS server infrastructure is **properly configured** with handlers registered at both the socket-type level (io.ip.ssl) and protocol level (https). However, there's a potential **timing issue with handler invocation during normal request processing** before client disconnect.

**Key Finding:** `base.s_read` has been updated to handle SSL sockets correctly, and the handler chain is properly configured. The delayed execution after disconnect suggests an **event loop registration or watcher activation issue**, not a handler chain problem.

---

## 1. HTTPS Protocol State Definition

**Status:** ✅ PROPERLY DEFINED

**Location:** `/home/user/protocol-7/modules/httpsd.init_code` (lines 64-115)

```perl
# Protocol state for HTTPS
<protocol.https.state> = {
    '0' => {
        'input'  => { 'handler' => 'httpsd.request_handler' },
        'output' => { 'handler' => 'base.handler.write' }
    }
};

# Register SSL socket type handlers
$data{'io'}{'type'}{'ip.ssl'} = {
    'ref'     => 'IO::Socket::SSL',
    'handler' => {
        'input' => {
            'connect' => 'io.ip.ssl.input.connect',
            'read'    => 'base.handler.read',      # ← CRITICAL
            'write'   => 'base.handler.write'
        }
    }
};

# Register HTTPS protocol
$data{'protocol'}{'https'} = {
    'state' => <protocol.https.state>
};
```

**Key Points:**
- Protocol state uses `httpsd.request_handler` for input (NOT the generic HTTP handler)
- Socket-type `ip.ssl` is registered with correct handlers
- Handler chain: `io.ip.ssl.input.read → base.handler.read → httpsd.request_handler`

---

## 2. Event Loop Handler Invocation Flow

**Status:** ⚠️  CHAIN EXISTS BUT INVOCATION TIMING IS SUSPECT

**Handler Chain (Two-Level System):**

### Level 1: Socket Input Monitoring
**File:** `/home/user/protocol-7/modules/base.session.init` (lines 241-250)

```perl
$session->{'watcher'}->{'input_handler'} = Event->io(
    'fd'     => $fd,                    # The accepted SSL socket
    'cb'     => sub { &{ $code{'base.handler.read'} } },
    'poll'   => qw| r |,               # Watch for readable
    'prio'   => 1,
    'repeat' => FALSE,
    'data'   => $id,                    # Pass session ID
    'desc'   => sprintf( '[%d] input handler', $id )
);
```

**Flow Diagram:**

```
Event Loop (when FD readable)
    ↓
Event->io() watcher triggers (fd, poll='r')
    ↓
base.handler.read($event)
    ↓
Determines read-mode (linewise/binary/bytewise)
    ↓
net.read_linewise_estimated($id)
    ↓
base.s_read($socket, \$buffer, $bytes)  ← CRITICAL POINT
    ↓
Session input buffer updated
    ↓
base.handler.input() triggered via buffer watcher
    ↓
Calls protocol-specific handler from state
    ↓
httpsd.request_handler($event) ← HTTPS REQUEST HANDLER
```

**File:** `/home/user/protocol-7/modules/base.handler.input` (lines 38-40)

```perl
if ( defined $handler and exists $code{$handler} ) {
    my $ret_code = $code{$handler}->($event);
    # $handler comes from $session->{'input'}->{'handler'}
    # which is set by base.session.init_state
}
```

---

## 3. Handler Registration for HTTPS

**Status:** ✅ PROPERLY REGISTERED AT BOTH LEVELS

### Level 1: Socket-Type Handler Registration

**File:** `/home/user/protocol-7/modules/httpsd.init_code` (lines 83-104)

```perl
$data{'io'}{'type'}{'ip.ssl'} = {
    'ref'     => 'IO::Socket::SSL',
    'handler' => {
        'input' => {
            'connect' => 'io.ip.ssl.input.connect',
            'read'    => 'base.handler.read',
            'write'   => 'base.handler.write'
        }
    }
};
```

**Used by:** `base.handler.connect` (line 29)

```perl
my $handler = $data{'io'}{'type'}{$type}{'handler'}{$mode}{'connect'};
# Resolves to: io.ip.ssl.input.connect
```

### Level 2: Protocol Handler Registration

**File:** `/home/user/protocol-7/modules/httpsd.init_code` (lines 109-115)

```perl
$data{'protocol'}{'https'} = {
    'connect' => { 'callback' => undef, 'banner' => '' },
    'state' => {
        '0' => {
            'input'  => { 'handler' => 'httpsd.request_handler' },
            'output' => { 'handler' => 'base.handler.write' }
        }
    }
};
```

**Used by:** `base.session.init_state` (line 48)

```perl
$session->{'input'}->{'handler'} = $state->{$mode}->{'handler'};
# Resolves to: httpsd.request_handler
```

---

## 4. Input Handler State for HTTPS Connections

**Status:** ✅ PROPERLY INITIALIZED, ⚠️ DELAYED INVOCATION POSSIBLE

### State Initialization Sequence

**File:** `/home/user/protocol-7/modules/base.session.init` (line 267)

```perl
if ( not <[base.session.init_state]>->( $id, 0 ) ) {
    # Initialize input handler with protocol state handlers
}
```

**File:** `/home/user/protocol-7/modules/base.session.init_state` (line 48)

```perl
# Set input handler from protocol state
$session->{'input'}->{'handler'} = $state->{$mode}->{'handler'};
# For HTTPS: sets to 'httpsd.request_handler'
```

### Input Watcher Registration

Two watchers monitor input:

1. **File descriptor watcher** (base.session.init, line 241)
   ```perl
   Event->io( 'fd' => $fd, 'cb' => sub { &{ $code{'base.handler.read'} } } )
   ```
   Monitors the socket for readable data

2. **Buffer variable watcher** (base.session.init, line 160)
   ```perl
   <[event.add_var]>->({
       'var'     => \$session->{'buffer'}->{'input'},
       'handler' => qw| base.handler.input |,
       'poll'    => qw| w |,  # On WRITE (buffer modified)
       'repeat'  => TRUE
   })
   ```
   Triggers handler when buffer is modified

**Problem Identified:** The buffer watcher triggers on WRITE (`poll => 'w'`), which means it fires when:
- Data is **written to** the buffer (good) - this happens in `base.s_read`
- But only if buffer modification happens **during event loop iteration**

---

## 5. HTTPS Connection Acceptance and Handler Setup

**Status:** ✅ PROPERLY IMPLEMENTED

### base.handler.connect Flow for HTTPS

**File:** `/home/user/protocol-7/modules/base.handler.connect` (lines 29-43)

```perl
my $type  = $data{'handle'}{$fd_srv}{'link'};  # Gets 'ip.ssl'
my $proto = $data{'handle'}{$fd_srv}{'protocol'} 
         // $data{'session'}{$id}{'protocol'};  # Gets 'https'
my $handler = $data{'io'}{'type'}{$type}{'handler'}{$mode}{'connect'};
# Resolves to: io.ip.ssl.input.connect

my $fd_client = $code{$handler}->($_[0]);  # Call io.ip.ssl.input.connect
```

### io.ip.ssl.input.connect Handler

**File:** `/home/user/protocol-7/modules/io.ip.ssl.input.connect` (lines 13-55)

```perl
if ( ref($fd) eq qw| IO::Socket::SSL | and -S $fd ) {
    if ( not $client_sock_fd = $fd->accept() ) {
        # Handle error
    }
    
    # Register socket in handle data
    $data{'handle'}{$client_sock_fd} = {
        'encryption' => qw| tls |,
        'mode'       => qw| input |,
        'link'       => qw| ip.ssl |,
        'peerhost'   => $p_host,
        'peerport'   => $p_port
    };
    
    # CRITICAL: Also register by numeric FD
    my $client_fd = fileno($client_sock_fd);
    $data{'handle'}{$client_fd} = $data{'handle'}{$client_sock_fd};
    
    return $client_sock_fd;  # Client socket ready for new session
}
```

### Session Creation

**File:** `/home/user/protocol-7/modules/base.handler.connect` (line 76)

```perl
my $cid = <[base.session.init]>->( $fd_client, $proto, $mode, $name );
# Creates new session with protocol='https'
```

---

## Critical Difference: HTTP vs HTTPS Handler Invocation

### HTTP (TCP) Flow - WORKS ✅

```
1. Client connects to port 80
   └─> io.ip.tcp.input.connect accepts connection
   └─> Returns IO::Socket::IP object
   
2. New session created with protocol='http'
   └─> Session state initialized: handler = 'httpd.request_handler'
   
3. Event loop registers fd watcher
   └─> When data arrives: base.handler.read()
   └─> Reads data via base.s_read using IO::AIO::aio_read
   └─> Buffer updated
   
4. Buffer watcher fires (poll='w' on modified buffer)
   └─> Calls base.handler.input
   └─> Gets handler from $session->{'input'}->{'handler'}
   └─> Calls 'httpd.request_handler'
   
5. HTTP response generated and sent
```

### HTTPS (SSL) Flow - DELAYED AFTER DISCONNECT ❌

```
1. Client connects to port 443
   └─> io.ip.ssl.input.connect accepts connection
   └─> Returns IO::Socket::SSL object
   
2. New session created with protocol='https'
   └─> Session state initialized: handler = 'httpsd.request_handler'
   
3. Event loop registers fd watcher
   └─> When data arrives: base.handler.read()
   └─> Reads data via base.s_read
   └─> base.s_read DOES handle SSL (lines 25-38):
       if ( ref($read_fh) eq qw| IO::Socket::SSL | ) {
           my $b_read = $read_fh->sysread( my $r_buff, $read_len, 0 );
           ...
       }
   
4. Buffer watcher SHOULD fire when buffer is modified
   └─> BUT: Appears NOT firing during normal request processing
   └─> Possible reasons:
       a) Event loop not recognizing SSL socket FD as readable
       b) base.handler.read not being called by event loop
       c) Buffer watcher not re-enabled after base.handler.read
       d) Timing issue: handler fires AFTER disconnect cleanup
```

---

## ROOT CAUSE HYPOTHESIS

The difference lies in how the **event loop monitors readability**:

### What Happens (from code analysis)

1. **TCP Socket:** 
   - Standard file descriptor (low number: 3, 4, 5...)
   - Event loop watches via `select()` or `epoll()`
   - Reliably fires when data available

2. **SSL Socket:**
   - `fileno($ssl_socket)` returns underlying TCP FD
   - But data is **encrypted at that FD level**
   - **Hypothesis:** Event loop may see readable event for raw TCP FD, but when `base.s_read` tries to read:
     - `$ssl_socket->sysread()` works correctly (decrypts TLS)
     - But event loop's next poll cycle might not see more data if it's already in the SSL buffer

### Why It Works After Disconnect

When client disconnects or connection closes:
- Event loop cleanup triggers
- Session shutdown handler runs
- Which invokes remaining handlers
- And clears the backlog

---

## Key Code References

| Component | File | Lines | Purpose |
|-----------|------|-------|---------|
| HTTPS Init | `httpsd.init_code` | 64-115 | Register protocol & socket handlers |
| Handler Connect | `base.handler.connect` | 29-43 | Select handler for socket type |
| Handler Input | `base.handler.input` | 38-40 | Call protocol-specific handler |
| Session Init | `base.session.init` | 267 | Initialize session state |
| State Init | `base.session.init_state` | 48 | Set input handler from state |
| Read Handler | `base.handler.read` | 1-99 | Socket read dispatcher |
| Linewise Read | `net.read_linewise_estimated` | 1-100 | Line-based HTTP request reading |
| Safe Read | `base.s_read` | 25-38 | **SSL-AWARE** socket read |
| HTTPS Handler | `httpsd.request_handler` | 1-77 | HTTPS request handler (delegates to httpd) |
| SSL Accept | `io.ip.ssl.input.connect` | 13-55 | Accept SSL connections |
| SSL Lifecycle | `io.ip.ssl.input.open` / `close` | - | Initialize/cleanup SSL sockets |

---

## Findings Summary

### What Should Happen (Theory)

```
Event Loop Poll
  → SSL socket readable
  → base.handler.read()
  → base.s_read() [SSL-aware, lines 25-38]
  → $ssl_socket->sysread() [decrypts TLS]
  → Session buffer updated
  → base.handler.input() triggered
  → httpsd.request_handler() called
  → HTTP response generated
  → base.handler.write() sends via SSL
  → HTTP/1.1 200 OK with HSTS headers
```

### What Actually Happens (Observed Problem)

```
Event Loop Poll
  → SSL socket readable (maybe)
  → base.handler.read() (maybe not called?)
  → base.s_read() (not executing)
  → Session buffer empty
  → base.handler.input() not triggered
  
  [Client waits for response]
  [Timeout or disconnect]
  
  → Session shutdown
  → Handler invoked on cleanup (TOO LATE)
  → Response sent to closed socket
```

### Handler Registration: ✅ CORRECT

Both socket-type and protocol handlers are:
- Properly registered in `httpsd.init_code`
- Correctly referenced by `base.handler.connect`
- Properly set in session state by `base.session.init_state`

### Handler Chain: ✅ COMPLETE

All handlers exist and are wired correctly:
- `io.ip.ssl.input.connect` - ✅ Accept connections
- `base.handler.read` - ✅ Monitor socket input
- `base.s_read` - ✅ **NOW SSL-AWARE** (lines 25-38)
- `base.handler.input` - ✅ Dispatch to protocol handler
- `httpsd.request_handler` - ✅ Process HTTPS requests

### Input Handler Setup: ⚠️ ISSUE

The event loop registration appears to work for TCP but may have timing issues with SSL:
- Buffer watcher set to `poll='w'` (on write to buffer)
- May not fire reliably if data arrives between event cycles
- Or if event loop doesn't see the SSL socket as readable

---

## Conclusion

**The infrastructure is properly configured.** The handlers exist, are registered, and wired correctly. The issue is **event loop invocation timing** - likely that:

1. Event loop doesn't recognize SSL socket FD as readable
2. Or `base.handler.read` isn't being called during normal processing
3. Or there's a synchronization issue between socket read and buffer watcher

The fix would involve:
- Ensuring event loop properly polls SSL socket FDs
- Or adjusting watcher polling modes for SSL connections
- Or debugging the `Event->io()` watcher behavior with SSL sockets

