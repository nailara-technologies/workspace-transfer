# Certificate Bootstrap Guide - Quick Solutions

**Date:** November 16, 2025
**Purpose:** Bootstrap HTTPS certificates to unblock httpsd startup
**Status:** Ready for immediate execution next session

---

## Problem

httpsd startup is **intentionally blocked** by design (via `httpsd.startup.validate_certificates`). This requires:
```
/etc/protocol-7/certs/current.pem  (certificate)
/etc/protocol-7/certs/current.key  (private key)
```

The system architecture expects certificates to exist. We need to **populate them**.

---

## Solution Options (By Effort)

### Option 1: Self-Signed Certificate (5 minutes) ⭐ RECOMMENDED

**Best for:** Development, testing, getting HTTPS working immediately

**Steps:**
```bash
# 1. Create certificate directory
sudo mkdir -p /etc/protocol-7/certs
sudo chown protocol-7:protocol-7 /etc/protocol-7/certs
sudo chmod 700 /etc/protocol-7/certs

# 2. Generate self-signed certificate (valid 365 days)
sudo openssl req -x509 -newkey rsa:4096 \
  -keyout /etc/protocol-7/certs/current.key \
  -out /etc/protocol-7/certs/current.pem \
  -days 365 -nodes \
  -subj "/CN=localhost"

# 3. Set correct ownership and permissions
sudo chown protocol-7:protocol-7 /etc/protocol-7/certs/current.*
sudo chmod 600 /etc/protocol-7/certs/current.*

# 4. Verify
ls -la /etc/protocol-7/certs/
```

**Testing:**
```bash
# Start Protocol-7
cd /home/user/protocol-7
./bin/Protocol-7 v7 -B -v

# Wait 5 seconds then check
sleep 5
p7 v7.list zenki | grep httpsd

# Test HTTPS (skip cert verification for self-signed)
curl -k https://localhost/test.html
```

**Expected Output:**
```
HTTP/1.1 200 OK
(Full HTML response from test template)
```

**Advantages:**
- ✅ Immediate HTTPS access
- ✅ No external dependencies
- ✅ Perfect for development/testing
- ✅ Takes 5 minutes

**Disadvantages:**
- ⚠️ Browser shows SSL warning (self-signed)
- ⚠️ Not suitable for production

---

### Option 2: Let's Encrypt via httpd Command (15 minutes)

**Best for:** Production, valid certificates, auto-renewal

**Requirements:**
- Valid domain name (not localhost)
- Port 80 accessible from internet
- Domain DNS pointing to this server

**Process:**
```bash
# 1. Trigger enrollment via httpd command
p7 httpd.cmd.add-vhost domain=yourdomain.com

# This will:
# - Check letsencrypt zenka is available
# - Request certificate via ACME HTTP-01 challenge
# - Validate domain ownership
# - Store certificate in /etc/protocol-7/certs/
# - Create symlink for httpsd to use

# 2. Restart httpsd
p7 v7.restart httpsd

# 3. Test HTTPS
curl https://yourdomain.com/test.html
```

**Advantages:**
- ✅ Valid, trusted certificates
- ✅ Auto-renewal handled by letsencrypt zenka
- ✅ Browser accepts without warnings
- ✅ Production-ready

**Disadvantages:**
- ⚠️ Requires valid domain and DNS
- ⚠️ ACME challenges take time
- ⚠️ Slightly more complex

---

### Option 3: Manual Certificate Generation (10 minutes)

**Best for:** Understanding the system, custom cert parameters

**Using OpenSSL directly:**
```bash
# Generate private key
openssl genrsa -out /tmp/current.key 4096

# Generate certificate signing request
openssl req -new -key /tmp/current.key \
  -out /tmp/current.csr \
  -subj "/CN=localhost/O=Protocol-7/C=US"

# Self-sign the certificate
openssl x509 -req -days 365 \
  -in /tmp/current.csr \
  -signkey /tmp/current.key \
  -out /tmp/current.pem

# Move to correct location
sudo mkdir -p /etc/protocol-7/certs
sudo mv /tmp/current.key /etc/protocol-7/certs/
sudo mv /tmp/current.pem /etc/protocol-7/certs/
sudo chown protocol-7:protocol-7 /etc/protocol-7/certs/*
sudo chmod 600 /etc/protocol-7/certs/*
```

---

## What Each Component Expects

### httpsd (HTTPS server)
```perl
# From configuration/zenki/httpsd/start line 49:
httpsd.cert_status = [httpsd.startup.validate_certificates]
```

**Validates:**
- ✅ `/etc/protocol-7/certs/current.pem` exists and readable
- ✅ `/etc/protocol-7/certs/current.key` exists and readable
- ✅ Ownership and permissions correct (httpsd user)

### httpd (HTTP server)
```perl
# Can request new certificates via:
p7 httpd.cmd.add-vhost domain=example.com
```

**Places certificates at:**
- `/etc/protocol-7/certs/` directory
- Symlinked as `current.pem` and `current.key`

### letsencrypt zenka
```perl
# Handles ACME protocol for certificate acquisition
# Called by: httpd.cmd.add-vhost
# Manages: Certificate requests, renewals, ACME challenges
```

---

## Next Session Quick Start

### For Development (Recommended - Option 1)

```bash
# 1. Copy this command and run exactly:
sudo bash -c 'mkdir -p /etc/protocol-7/certs && \
  openssl req -x509 -newkey rsa:4096 \
    -keyout /etc/protocol-7/certs/current.key \
    -out /etc/protocol-7/certs/current.pem \
    -days 365 -nodes -subj "/CN=localhost" && \
  chown protocol-7:protocol-7 /etc/protocol-7/certs/* && \
  chmod 600 /etc/protocol-7/certs/*'

# 2. Start Protocol-7
cd /home/user/protocol-7
./bin/Protocol-7 v7 -B -v

# 3. Wait 5 seconds
sleep 5

# 4. Check httpsd started
p7 v7.list zenki | grep httpsd

# 5. Test HTTPS
curl -k https://localhost/test.html

# 6. If all works, commit the verification
cd /home/user/workspace-transfer
git add -A && git commit -m "docs: Certificate bootstrap successful - HTTPS verified"
git push https://${GITHUB_PAT}@github.com/nailara-technologies/workspace-transfer.git base
```

---

## Troubleshooting

### httpsd still fails after certificate creation

**Check permissions:**
```bash
ls -la /etc/protocol-7/certs/
# Should show: protocol-7:protocol-7 with 600 perms
```

**Check logs:**
```bash
tail -50 /var/log/protocol-7/runsc.httpsd.zenka.log
# Should show: certificate files validated successfully
```

### curl fails with certificate errors

**For self-signed (expected):**
```bash
curl -k https://localhost/test.html  # -k skips cert verification
# OR
curl --insecure https://localhost/test.html
```

**Check cert validity:**
```bash
openssl x509 -in /etc/protocol-7/certs/current.pem -text -noout | grep -A2 "Validity"
```

---

## Architecture Understanding

**Flow with Certificates:**
```
1. Protocol-7 starts
   ↓
2. httpsd zenka loads
   ↓
3. Calls: httpsd.startup.validate_certificates
   ↓
4. Checks: /etc/protocol-7/certs/current.{pem,key}
   ↓
5a. ✅ Found → Create SSL socket on port 443
5b. ❌ Not found → Exit (intentional, by design)
   ↓
6. If created: Start accepting HTTPS connections
   ↓
7. Route HTTPS requests through:
   - httpsd.request_handler
   - httpd.http_get (reused)
   - web.process_template_recursive
   ↓
8. Return encrypted response
```

**Why This Design:**
- ✅ Never starts broken HTTPS server
- ✅ Forces explicit certificate setup
- ✅ Prevents confusing silent failures
- ✅ Matches Protocol-7 philosophy (explicit > implicit)

---

## Success Criteria

### Minimum (Just get HTTPS running)
- [ ] Certificates created at `/etc/protocol-7/certs/`
- [ ] httpsd zenka starts without error
- [ ] curl can connect to https://localhost
- [ ] Commitment to workspace-transfer repo

### Full (Verify end-to-end)
- [ ] HTTPS template processing works
- [ ] Both HTTP and HTTPS accessible simultaneously
- [ ] Concurrent requests handled
- [ ] Session documented and committed

---

## Token Estimate

| Task | Time | Tokens |
|------|------|--------|
| Create self-signed cert | 2 min | 0.2 |
| Start Protocol-7 | 2 min | 0.2 |
| Test HTTPS endpoint | 2 min | 0.1 |
| Verify templates work | 3 min | 0.2 |
| Document and commit | 5 min | 0.3 |
| **Total** | **14 min** | **~1 token** |

**Very efficient use of remaining credits!**

---

## Command Reference

### Quickest Path (Copy-Paste Ready)

```bash
# Everything in one block:
sudo bash -c 'mkdir -p /etc/protocol-7/certs && openssl req -x509 -newkey rsa:4096 -keyout /etc/protocol-7/certs/current.key -out /etc/protocol-7/certs/current.pem -days 365 -nodes -subj "/CN=localhost" && chown protocol-7:protocol-7 /etc/protocol-7/certs/* && chmod 600 /etc/protocol-7/certs/*' && \
cd /home/user/protocol-7 && \
./bin/Protocol-7 v7 -B -v && \
sleep 5 && \
p7 v7.list zenki && \
curl -k https://localhost/test.html
```

---

## Files Reference

**Current Session Documents:**
- `HTTPS_TLS_VERIFICATION_2025-11-16.md` - Blocker analysis
- `CERTIFICATE_BOOTSTRAP_2025-11-16.md` - This guide
- `WORKSPACE_INITIALIZATION_2025-11-16.md` - Setup summary

**Protocol-7 Code:**
- `/home/user/protocol-7/configuration/zenki/httpsd/start` - httpsd config
- `/home/user/protocol-7/modules/httpsd.startup.validate_certificates` - Validation logic
- `/home/user/protocol-7/modules/httpsd.create_ssl_socket` - Socket creation
- `/home/user/protocol-7/modules/httpd.cmd.add-vhost` - Cert enrollment command

---

**Status:** Ready for next session
**Recommended:** Option 1 (Self-Signed) - Fastest path to HTTPS verification
**Effort:** ~1 token, ~15 minutes
