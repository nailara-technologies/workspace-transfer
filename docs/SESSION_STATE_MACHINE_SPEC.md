# Protocol-7: Session State Machine Specification

**Document Date**: 2025-11-28
**Session**: Encryption & Authentication Security Fixes
**Purpose**: Complete specification of session states, transitions, and handlers

---

## 🎯 Overview

Protocol-7 sessions transition through 4 distinct states, each with specific handlers, timeouts, and responsibilities. This document formally specifies the state machine that governs all session behavior.

### Quick Reference

| State | Name | Timeout | Handler | Purpose |
|-------|------|---------|---------|---------|
| 0 | Pre-Auth | 17s | `base.handler.auth` | Authenticate client |
| 1 | Authenticated | None | `base.handler.command` | Execute commands |
| 2 | Link-Upgrade | 17s | `base.handler.link-upgrade` | Negotiate encryption |
| 3 | Encrypted | None | Encryption wrappers | Send/receive encrypted messages |

---

## 📊 State Definitions

### State 0: Pre-Authentication

**Purpose**: Authenticate client identity before allowing any commands

**Entry**: Client connects
**Exit Condition**:
- Successful authentication (→ State 1)
- Failed authentication (→ Disconnect)
- Timeout (17 seconds → Disconnect)

**Timeout**: 17 seconds
- Prevents connections from hanging indefinitely
- Forces authentication within time window
- Protects against slowloris attacks

**Active Handler**: `base.handler.auth`
- Dispatches to appropriate auth plugin (zenka, unix, pwd, twofish, c25519)
- Collects authentication data from client
- Verifies credentials
- Returns auth result code

**Handler Return Codes**:
```
0 → Success: Transition to State 1 (Authenticated)
1 → Continue: Wait for more authentication data (remain in State 0)
2 → Fail: Disconnect client immediately
```

**Configuration**:
```perl
$data{'session'}{$session_id} = {
    'state' => 0,
    'state_timeout' => 17,              # 17-second limit
    'buffer' => {
        'input'  => \$input_buffer,     # Auth data from client
        'output' => \$output_buffer,    # Auth responses to client
    },
    'handle' => $client_handle,         # TCP/Unix socket handle
};
```

**Example Flow**:
```
Client connects
    ↓
Server: "Enter username"
    ↓
Client: "myuser"
    ↓
Server: "Enter password"
    ↓
Client: "mypassword"
    ↓
Server: (Verify credentials)
    ↓
[VALID] → Return 0 → Transition to State 1
[INVALID] → Return 2 → Disconnect
[INCOMPLETE] → Return 1 → Wait for more input
```

---

### State 1: Authenticated

**Purpose**: Execute commands as authenticated user

**Entry**: Successful authentication (from State 0)
**Exit Condition**:
- Client requests link-upgrade (→ State 2)
- Client disconnects (→ End)
- Connection error (→ End)

**Timeout**: None
- Authenticated connections can remain open indefinitely
- No session timeout (commands take as long as needed)
- Assumption: Authenticated users are trusted

**Active Handler**: `base.handler.command`
- Parses user commands
- Validates command syntax
- Executes command handlers
- Returns results to client

**Handler Return Codes**:
```
0 → Success: Remain in State 1
1 → Continue: Wait for more command data (remain in State 1)
2 → Fail: Disconnect client
```

**Session Data Available**:
```perl
$data{'session'}{$session_id} = {
    'state' => 1,
    'auth_user' => 'myuser',            # Authenticated username
    'auth_method' => 'unix',            # How user was authenticated
    'client_uid' => 1000,               # For socket auth
    'capabilities' => [...],             # What this user can do
    'buffer' => {...},
    'handle' => $client_handle,
};
```

**Example Commands**:
```
myuser> list
(returns list of available operations)

myuser> show-buffer compile-errors
(returns buffer contents)

myuser> link-upgrade c25519 <pubkey>
(requests state transition to State 2)
```

---

### State 2: Link-Upgrade Negotiation

**Purpose**: Negotiate encryption parameters and establish encrypted session

**Entry**: Explicit `link-upgrade` command from State 1
**Exit Condition**:
- Successful negotiation (→ State 3)
- Failed negotiation (→ State 1 or Disconnect)
- Timeout (17 seconds → Disconnect)

**Timeout**: 17 seconds
- Protocol-level timeout (prevents hanging in negotiation)
- Sufficient for Curve25519 ECDH negotiation
- Prevents DoS attacks during key exchange

**Active Handler**: `base.handler.link-upgrade`
- Parses `link-upgrade` command
- Validates cipher specifications (currently: c25519)
- Performs Curve25519 ECDH key agreement
- Derives encryption key from shared secret
- Transitions to State 3 on success

**Protocol Exchange**:
```
1. Client → Server: "link-upgrade c25519 <client-pubkey-base32>"
2. Server: Generates ephemeral keypair
3. Server → Client: "link-upgrade-ok <server-pubkey-base32>"
4. Both sides: Compute shared_secret = ECDH(private, peer_public)
5. Both sides: Derive enc_key = AMOS7::13::key_32(\$shared_secret, \$session_id)
6. Server → Client: "link-upgrade-done"
7. Both: Transition to State 3
```

**Key Derivation**:
```perl
my $enc_key = AMOS7::13::key_32( \$shared_secret, \$session_id );
# ✅ CORRECT: Both parameters are SCALAR refs
# Output: 32-byte encryption key
```

**Session Data Available**:
```perl
$data{'session'}{$session_id} = {
    'state' => 2,
    'auth_user' => 'myuser',
    'link_dh_client_pubkey' => ...,     # Client's Curve25519 public key
    'link_dh_server_pubkey' => ...,     # Server's generated pubkey
    'link_dh_shared_secret' => ...,     # ECDH result (never transmitted)
    'link_encryption_key' => ...,       # Derived from AMOS7::13::key_32
    'buffer' => {...},
    'handle' => $client_handle,
};
```

**Performance Requirement**:
- Key derivation must complete in < 17 seconds (currently 20.3ms) ✅
- Requires: AMOS7::13::key_32 called with SCALAR ref, not numeric

---

### State 3: Encrypted Session

**Purpose**: All subsequent communication encrypted with ChaCha20-Poly1305

**Entry**: Successful link-upgrade completion
**Exit Condition**:
- Client disconnects (→ End)
- Protocol error (→ End)
- NO TIMEOUT (encrypted sessions can run indefinitely)

**Timeout**: None
- Encrypted, authenticated connections are trusted
- No session idle timeout
- Can run long-running operations

**Active Handlers**:
- **Read**: `base.handler.read.encryption-wrapper`
  - Decrypts incoming messages
  - Verifies authentication tags
  - Passes plaintext to next handler (usually base.handler.command)

- **Write**: Session-specific wrapper
  - Encrypts outgoing messages
  - Generates per-message authentication tags
  - Transmits ciphertext + tag

**Encryption Details**:

**Cipher**: ChaCha20-Poly1305 AEAD
```perl
use Crypt::AuthEnc::ChaCha20Poly1305;
my $cipher = Crypt::AuthEnc::ChaCha20Poly1305->new($key, $nonce);
my $ciphertext = $cipher->encrypt_add($plaintext);  # ✅ Returns ciphertext
my $tag = $cipher->encrypt_done();                   # Returns 16-byte tag
my $message = $ciphertext . $tag;                    # Combined for transmission
```

**Nonce Generation**:
```perl
# Per-message nonce (12 bytes) = session_id (4) + counter (4) + zeros (4)
my $nonce = pack('N', $session_id) . pack('N', $counter) . "\0\0\0\0";
# Counter incremented before each message (prevents replays)
```

**Message Counter**:
- Incremented on each encryption/decryption
- Ensures same message never encrypted with same nonce
- Enables out-of-order detection
- Part of nonce, so implicit in ciphertext

**Session Data Available**:
```perl
$data{'session'}{$session_id} = {
    'state' => 3,
    'auth_user' => 'myuser',
    'link_encryption_key' => ...,       # 32-byte key
    'link_read_counter' => 42,          # Read-side message counter
    'link_write_counter' => 43,         # Write-side message counter
    'link_encoding_mode' => 'base32',   # Optional encoding layer
    'input' => {
        'handler' => 'base.handler.read.encryption-wrapper',
        'handler_encryption_original' => 'base.handler.command',
    },
    'output' => {
        'handler' => 'base.handler.write.encryption-<session_id>',
        'handler_encryption_original' => 'base.handler.write',
    },
    'buffer' => {...},
    'handle' => $client_handle,
};
```

**Optional Link-Layer Encoding**:
If negotiated during State 2, additional wrappers apply:
```
Read: Encryption-Wrapper → Encoding-Wrapper (decode) → base.handler.command
Write: base.handler.write → Encoding-Wrapper (encode) → Encryption-Wrapper
```

---

## 🔄 State Transitions

### Transition Diagram

```
┌─────────────────┐
│  State 0        │
│  Pre-Auth       │
│  (17s timeout)  │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Return  │
    │ Code    │
    │
    ├──→ 0 (success) ─→ ┌──────────────────┐
    │                   │ State 1           │
    │                   │ Authenticated     │
    │                   │ (no timeout)      │
    │                   └────────┬──────────┘
    │                            │
    ├──→ 1 (continue) ──→ (stay in State 0, wait for more input)
    │
    └──→ 2 (fail) ──────→ (DISCONNECT)
                              ↓
                         Connection ends
```

### State 1 Transitions

```
┌─────────────────┐
│  State 1        │
│  Authenticated  │
│  (no timeout)   │
└────────┬────────┘
         │
    ┌────┴─────────────────┐
    │ Command Handler      │
    │ Return Code          │
    │
    ├──→ 0 (success) ──→ (stay in State 1, command complete)
    │
    ├──→ 1 (continue) ──→ (stay in State 1, wait for more input)
    │
    ├──→ 2 (error) ───→ (DISCONNECT)
    │
    └──→ Special: "link-upgrade" ──→ ┌──────────────────┐
                                       │ State 2          │
                                       │ Link-Upgrade     │
                                       │ (17s timeout)    │
                                       └────────┬─────────┘
                                                 │
                                         ┌───────┴───────┐
                                         │ Negotiation   │
                                         │ Result        │
                                         │
                                         ├──→ Success ─→ ┌──────────────┐
                                         │                │ State 3      │
                                         │                │ Encrypted    │
                                         │                │ (no timeout) │
                                         │                └──────────────┘
                                         │
                                         ├──→ Failed ──→ (back to State 1)
                                         │
                                         └──→ Timeout ──→ (DISCONNECT)
```

### Key Invariants

1. **State 0 → State 1 only on code 0**
   - Code 0 = "Authentication succeeded"
   - Only path to State 1

2. **Always disconnect on code 2**
   - Any handler returning 2 = "Disconnect immediately"
   - Applies to all states

3. **Code 1 only for incomplete input**
   - "Handler waiting for more data on same connection"
   - NEVER for rejecting attempts (auth failed, command invalid)
   - Connection must actually expect more input (not hanging)

4. **Encrypted sessions never timeout**
   - Once in State 3, no idle timeout
   - Trusted authenticated channels
   - Can run indefinitely

5. **Pre-auth and link-upgrade have timeouts**
   - Prevent resource exhaustion
   - Prevent slowloris attacks
   - Force decisions within time window

---

## 🔒 Security Properties

### Authentication Guarantee
```
Before State 1: Client identity verified ✓
No commands execute until State 1
Prevents unauthorized access
```

### Encryption Guarantee
```
In State 3: All messages encrypted ✓
Authentication tag prevents tampering
Per-message nonce prevents replays
ChaCha20-Poly1305 provides both confidentiality and integrity
```

### Timeout Protection
```
State 0 (17s): Prevents auth resource exhaustion
State 2 (17s): Prevents negotiation DoS
State 1/3: No timeout (authenticated = trusted)
```

### Connection State Semantics
```
Handler returning 1 ONLY means: "Waiting for more data on this connection"
If connection won't send more data, handler must return 0 or 2
Returning 1 when connection idle = event loop deadlock
```

---

## 🐛 Common Implementation Errors

### Error 1: Returning 1 for Failed Authentication
```perl
# WRONG ❌
if ($auth_failed) {
    return 1;  # "Waiting for more input"
               # But connection won't send more (already sent username+password)
               # Result: Event loop timeout, "unknown command" repeating
}

# CORRECT ✅
if ($auth_failed) {
    return 2;  # "Disconnect immediately"
}
```

**Impact**: Enables brute-force attacks, causes event loop deadlocks

### Error 2: Not Applying Return Code 0 for Success
```perl
# WRONG ❌
if ($auth_success) {
    return ($user);  # Returns just username, handler expects (code, username)
}

# CORRECT ✅
if ($auth_success) {
    return (0, $user);  # Return code 0 + username
}
```

**Impact**: Ambiguous to state machine, potential bugs in state transitions

### Error 3: Numeric Seed Instead of SCALAR Ref
```perl
# WRONG ❌ (causes 3659x slowdown)
my $enc_key = AMOS7::13::key_32(\$shared_secret, $session_id);
#                                                 ^ numeric, not SCALAR ref

# CORRECT ✅
my $enc_key = AMOS7::13::key_32(\$shared_secret, \$session_id);
#                                                 ^ SCALAR ref
```

**Impact**: Event loop timeout (key derivation: 7+ seconds instead of 20.3ms)

---

## 📋 State Machine Implementation

### Base Module
`modules/base.session.init_state` - Implements state machine transitions

### Handler Dispatch
```perl
# Each state has an active handler
my %state_handlers = (
    0 => 'base.handler.auth',
    1 => 'base.handler.command',
    2 => 'base.handler.link-upgrade',
    3 => 'base.handler.read.encryption-wrapper',  # Read path
);

# Handler called with: ($session_id, $mode, $state_id)
# Returns: 0 (success), 1 (continue), 2 (fail)
```

### Timeout Implementation
```perl
# State 0 and 2: 17-second timer
if ($session_id->{state} == 0 or $session_id->{state} == 2) {
    $session_id->{state_timeout} = 17;
} else {
    # State 1 and 3: No timeout
    $session_id->{state_timeout} = undef;
}
```

---

## 🧪 Testing State Machine

### Test Case 1: Successful Authentication
```
1. Connect (State 0)
2. Send valid credentials
3. Handler returns 0
4. Verify transition to State 1 ✓
```

### Test Case 2: Failed Authentication (Must Disconnect)
```
1. Connect (State 0)
2. Send invalid credentials
3. Handler returns 2
4. Verify connection closes ✓
5. Verify cannot send second attempt ✓
```

### Test Case 3: Link-Upgrade Encryption
```
1. Authenticate (State 0 → State 1)
2. Send link-upgrade command
3. Perform ECDH negotiation (State 2)
4. Key derivation completes < 17 seconds ✓
5. Verify transition to State 3 ✓
6. Verify all messages encrypted ✓
```

### Test Case 4: Timeout Protection
```
1. Connect to State 0
2. Wait 18 seconds (past 17s timeout)
3. Verify connection closed ✓
```

---

## 📚 References

**Related Documentation**:
- `docs/PROTOCOL_7_ENCRYPTION_IMPLEMENTATION.md` - Encryption details
- `docs/PROTOCOL_7_AUTH_SECURITY_ANALYSIS.md` - Auth vulnerabilities
- Protocol-7 repository: `/home/user/protocol-7/modules/`

**Key Files**:
- `modules/base.session.init_state` - State machine implementation
- `modules/base.handler.auth` - Auth dispatch
- `modules/base.handler.command` - Command execution
- `modules/base.handler.link-upgrade` - Encryption negotiation

---

**Last Updated**: 2025-11-28
**Status**: ✅ Complete and accurate

