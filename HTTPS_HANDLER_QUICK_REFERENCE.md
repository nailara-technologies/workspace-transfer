# HTTPS Handler Investigation - Quick Reference

## Problem Statement
- TLS handshakes work perfectly
- HTTP requests over HTTPS are NOT processed during normal client interaction
- Handlers only execute AFTER client disconnects
- This indicates event loop isn't invoking handlers during request processing

## Search Results - 5 Key Areas

### 1. HTTPS Protocol Definition
**File:** `/home/user/protocol-7/modules/httpsd.init_code` (lines 64-115)

```perl
<protocol.https.state> = {
    '0' => {
        'input'  => { 'handler' => 'httpsd.request_handler' },
        'output' => { 'handler' => 'base.handler.write' }
    }
};

$data{'io'}{'type'}{'ip.ssl'} = {
    'ref' => 'IO::Socket::SSL',
    'handler' => {
        'input' => {
            'connect' => 'io.ip.ssl.input.connect',
            'read'    => 'base.handler.read',
            'write'   => 'base.handler.write'
        }
    }
};
```

**Status:** ✅ CORRECT - Protocol properly defined with separate handler

---

### 2. Event Loop Handler Invocation

**Call Chain:**
```
Event->io() watcher (polls FD for 'r'=readable)
  ↓
base.handler.read() [base.session.init, line 241]
  ↓
net.read_linewise_estimated() [reads data in lines]
  ↓
base.s_read() [CRITICAL - socket read]
  ↓
For SSL: $socket->sysread() [decrypts TLS, lines 25-38]
  ↓
Session buffer updated
  ↓
Buffer watcher fires base.handler.input()
  ↓
httpsd.request_handler() [should be called]
```

**Files Involved:**
- `/home/user/protocol-7/modules/base.session.init` - Registers Event->io() watcher
- `/home/user/protocol-7/modules/base.handler.read` - Routes to protocol handler
- `/home/user/protocol-7/modules/net.read_linewise_estimated` - Reads HTTP request lines
- `/home/user/protocol-7/modules/base.s_read` - SSL-AWARE socket reader (lines 25-38)

**Status:** ⚠️ CHAIN EXISTS BUT TIMING ISSUE
- base.s_read IS SSL-aware (can decrypt TLS)
- But Event->io() may not be firing for SSL socket FD

---

### 3. Handler Registration

**Socket-Type Registration** (httpsd.init_code, lines 83-104):
```perl
$data{'io'}{'type'}{'ip.ssl'} = {
    'handler' => {
        'input' => {
            'connect' => 'io.ip.ssl.input.connect',
            'read'    => 'base.handler.read',
        }
    }
};
```

**Protocol Handler Registration** (httpsd.init_code, lines 109-115):
```perl
$data{'protocol'}{'https'} = {
    'state' => { '0' => { 'input' => { 'handler' => 'httpsd.request_handler' } } }
};
```

**Used by:**
- `base.handler.connect` (line 29) - Gets socket-type handler
- `base.session.init_state` (line 48) - Gets protocol handler

**Status:** ✅ REGISTERED AT BOTH LEVELS

---

### 4. Input Handler Setup for HTTPS

**State Initialization:**
```
base.handler.connect() accepts SSL connection
  ↓
Creates session: base.session.init($fd_client, 'https', ...)
  ↓
Initializes state: base.session.init_state($id, 0)
  ↓
Sets handler: $session->{'input'}->{'handler'} = 'httpsd.request_handler'
```

**Two Watchers Monitor Input:**

1. **FD Watcher** (base.session.init, lines 241-250)
   - Type: `Event->io()`
   - Polls: 'r' (readable)
   - Fires: `base.handler.read()`

2. **Buffer Watcher** (base.session.init, lines 160-168)
   - Type: `event.add_var()` on `$session->{'buffer'}->{'input'}`
   - Polls: 'w' (on write/modification)
   - Fires: `base.handler.input()`

**Status:** ✅ INITIALIZED CORRECTLY
⚠️ Buffer watcher might not fire if base.handler.read isn't called

---

### 5. base.handler.connect - HTTPS Setup

**Protocol Identification:**
```perl
my $type = $data{'handle'}{$fd_srv}{'link'};      # Gets 'ip.ssl'
my $proto = ...$session{$id}{'protocol'};         # Gets 'https'
```

**Handler Selection:**
```perl
my $handler = $data{'io'}{'type'}{$type}{'handler'}{$mode}{'connect'};
# Resolves to: io.ip.ssl.input.connect

my $fd_client = $code{$handler}->($_[0]);  # Call it
```

**SSL Connection Accept:** (`io.ip.ssl.input.connect`, lines 13-55)
```perl
if ( ref($fd) eq 'IO::Socket::SSL' and -S $fd ) {
    $client_sock_fd = $fd->accept();
    $data{'handle'}{$client_sock_fd} = {..., 'encryption' => 'tls'};
    $data{'handle'}{fileno($client_sock_fd)} = $data{'handle'}{$client_sock_fd};
    return $client_sock_fd;
}
```

**Status:** ✅ PROPERLY IMPLEMENTED

---

## Critical Discovery: base.s_read IS SSL-AWARE

**File:** `/home/user/protocol-7/modules/base.s_read` (lines 25-38)

```perl
if ( ref($read_fh) eq qw| IO::Socket::SSL | ) {
    # For SSL sockets, use sysread which handles TLS decryption automatically
    my $b_read = $read_fh->sysread( my $r_buff, $read_len, 0 );
    if ( defined $b_read && $b_read > 0 ) {
        utf8::decode($r_buff);
        $b_read = length($r_buff);
        $buffer_ref->$* .= $r_buff;
        return $b_read;
    } else {
        return $b_read // -1;
    }
} else {
    # For TCP sockets, use IO::AIO::aio_read
    ...
}
```

**Implication:** The SSL read handler infrastructure IS in place. The issue is NOT
with decryption logic. The issue is that base.handler.read() probably isn't being
called by the Event->io() watcher during normal request processing.

---

## HTTP vs HTTPS Flow Comparison

### HTTP (Works)
```
Client connects (port 80)
  → io.ip.tcp.input.connect (accepts to IO::Socket::IP)
  → New session with protocol='http'
  → Event loop sees readable FD (standard TCP)
  → base.handler.read() called
  → base.s_read() uses IO::AIO::aio_read()
  → Buffer filled
  → base.handler.input() calls httpd.request_handler()
  → Response sent
  ✅ Works immediately
```

### HTTPS (Broken)
```
Client connects (port 443)
  → io.ip.ssl.input.connect (accepts to IO::Socket::SSL)
  → New session with protocol='https'
  → Event loop SHOULD see readable FD but...
  → ⚠️ base.handler.read() not called (probably)
  → base.s_read() never executes
  → Buffer stays empty
  → base.handler.input() never fires
  → Handler executes during session cleanup
  ❌ Delayed until disconnect
```

---

## The Root Cause Hypothesis

The handlers are properly registered and wired. The infrastructure for SSL reads
is in place. **The problem is event loop invocation timing:**

**Most Likely:** Event->io() watcher isn't seeing SSL socket FDs as readable
during normal request processing, or is seeing them but not calling the handler.

**Why it works after disconnect:**
- Session shutdown triggers cleanup
- Which forcefully calls remaining handlers
- By then, client is already gone

---

## Key Files to Debug Event Loop Issue

**Event Loop Registration:**
- `/home/user/protocol-7/modules/base.session.init` (lines 241-250)
  Check: Is Event->io() watcher properly polling SSL socket FD?

**Handler Execution:**
- `/home/user/protocol-7/modules/base.handler.read`
  Add logging to see if it's being called for SSL connections

**Event Loop Framework:**
- Check Protocol-7's Event.pm or event handling module
  See if there's special handling needed for IO::Socket::SSL

---

## Summary Table

| Component | File | Status | Issue |
|-----------|------|--------|-------|
| Protocol Definition | httpsd.init_code | ✅ | None |
| Socket-Type Handler | httpsd.init_code | ✅ | None |
| Protocol Handler | httpsd.init_code | ✅ | None |
| Handler Chain | multiple | ✅ | None |
| SSL-Aware Read | base.s_read | ✅ | None |
| Connection Accept | io.ip.ssl.input.connect | ✅ | None |
| Session Init | base.session.init | ✅ | None |
| Handler Assignment | base.session.init_state | ✅ | None |
| **Event Loop Invocation** | **base.session.init** | **⚠️** | **Timing issue** |
| **FD Watcher Firing** | **Event->io()** | **⚠️** | **Not firing reliably** |

---

## Next Steps for Debugging

1. **Add logging to base.handler.read** to see if it's called for SSL connections
2. **Check Event->io() watcher** configuration for SSL socket FDs
3. **Verify Event loop** is properly polling the underlying TCP FD
4. **Check if IO::Socket::SSL::fileno()** returns correct FD for polling

The fix likely involves ensuring the Event->io() watcher reliably triggers
for SSL socket file descriptors.

