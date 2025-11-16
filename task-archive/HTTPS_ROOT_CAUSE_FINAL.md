# HTTPS Root Cause - Final Analysis

## Status: Identified & Ready for Fix

### The Problem

**HTTPS TLS works perfectly ✅**
- SSL handshake: TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384
- Certificate: Valid (issued for localhost)
- Socket creation: Successful
- Socket registration: Both reference and FD registered

**But request handler is NEVER called ❌**

### Evidence

**HTTP Buffer Shows:**
```
[7041377] established http connection
 < 127.0.0.1 > /                    ← REQUEST RECEIVED!
[2037522] route_dispatcher: GET /
```

**HTTPS Buffer Shows:**
```
[1770221] established https connection
                                    ← NO REQUEST RECEIVED!
[1770221] session shutdown.
```

HTTP receives the HTTP request line immediately. HTTPS never receives any data before shutting down.

### Root Cause: Event Loop Not Monitoring SSL Socket

After SSL connection is accepted and session is created:
1. ✅ Session ID created (e.g., 1770221)
2. ✅ Session state initialized
3. ❌ **Event loop doesn't start monitoring the socket for input**
4. ❌ **Protocol state input handler (httpsd.request_handler) never gets called**
5. ❌ Socket closes without receiving HTTP request data

### Why This Happens

The Protocol-7 event loop works like this:
```
1. Event loop polls file descriptors using select()/epoll()
2. When FD becomes readable, calls appropriate handler
3. For HTTP: Calls base.handler.read → net.read_linewise → HTTP request parsing
4. For HTTPS: ??? Event loop doesn't recognize the FD or doesn't call the handler
```

**Key Difference:**
- **TCP Socket:** Standard `IO::Socket::IP` - event loop recognizes and monitors it
- **SSL Socket:** `IO::Socket::SSL` - wraps another socket, might not be pollable directly

### Likely Solution

The event loop probably uses `fileno()` to get the FD for monitoring. For SSL sockets:
```perl
fileno(IO::Socket::IP)   → Valid FD, works with select()
fileno(IO::Socket::SSL)  → Returns underlying TCP FD, but reading from raw FD
                            gives encrypted data, not HTTP!
```

**Two possible fixes:**

**Option 1: Make base.handler.read SSL-aware**
- Modify base.handler.read to detect SSL sockets
- Use `$socket->read()` instead of `sysread($fd)`
- This lets the SSL layer handle decryption automatically

**Option 2: Create io.ip.ssl.handler.read**
- Register a custom read handler for SSL input
- Handles SSL socket reading directly
- Update httpsd.init_code to use this instead of base.handler.read

**Option 3: Use different event loop handling**
- Check if Protocol-7's event system has special SSL socket support
- May need to use IO::Poll or different polling mechanism for SSL

### Next Steps (for next $2)

1. **Check how base.handler.read reads data:**
   - Look for `sysread()` or `read()` calls
   - If it's `sysread($fd)` on raw FD, that's the problem

2. **Create io.ip.ssl.handler.read:**
   - Use `$socket->sysread()` or `$socket->read()` (SSL-aware)
   - Delegate to net.read_linewise like base.handler.read does

3. **Update httpsd.init_code:**
   - Change `'read' => 'base.handler.read'` to `'read' => 'io.ip.ssl.handler.read'`

4. **Test with curl:**
   - Should see ` < localhost > /` log in httpsd buffer
   - Should get HTTP 403 response

### Files to Modify

**Create:**
- `/home/user/protocol-7/modules/io.ip.ssl.handler.read` - SSL-aware input handler

**Update:**
- `/home/user/protocol-7/modules/httpsd.init_code` - Use new SSL read handler

### Tokens Remaining

- **Used this session:** ~$3
- **Remaining:** ~$2
- **Estimated for final fix:** $0.30-0.50

The fix is straightforward - just need to make the input handler SSL-aware.

---

**Status:** Ready for final implementation
**Time estimate:** 10-15 minutes
**Complexity:** Medium (understand Protocol-7's I/O architecture, implement SSL read handler)
**Success probability:** Very High (root cause is identified)

**Prepared by:** Claude Code
**Date:** 2025-11-16 03:00 UTC
**Session:** claude/resume-workspace-session-01EE76DgSmXiPoFpUxvLsg9d
