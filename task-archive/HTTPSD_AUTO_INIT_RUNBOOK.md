# HTTPSD Auto-Initialization & Certificate Management Runbook

**Document Version:** 1.0
**Last Updated:** 2025-11-14
**Applicable To:** Protocol-7 HTTPSD with ACME/Let's Encrypt Integration
**Status:** Production-Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Pre-Startup Verification](#pre-startup-verification)
3. [Auto-Certificate Installation Flow](#auto-certificate-installation-flow)
4. [Startup Checklist](#startup-checklist)
5. [Certificate Management](#certificate-management)
6. [Troubleshooting](#troubleshooting)
7. [Monitoring & Maintenance](#monitoring--maintenance)

---

## Overview

HTTPSD (HTTPS Daemon) in Protocol-7 features fully automated certificate management through:
- **Automatic certificate installation** from Let's Encrypt via ACME protocol
- **Certificate symlink management** for seamless rotation
- **Auto-renewal** before expiration
- **HTTP-01 challenge** handling for domain validation

This runbook covers the initialization flow and operational procedures.

---

## Pre-Startup Verification

### 1. Directory Structure Validation

Before starting HTTPSD, verify the following directories exist with correct permissions:

```bash
# Create/verify required directories
/var/httpd/                    # Root directory for all vhosts
/var/httpd/_certs/            # Certificate storage (auto-created by system)
/var/httpd/_certs/live/       # Active certificates (symlinked from renewal)
/var/httpd/_certs/archive/    # Certificate archives
/var/httpd/_templates/        # Global templates
/var/log/httpsd/              # Log directory
/var/run/httpsd/              # Runtime/PID directory

# Verify ownership and permissions
ls -ld /var/httpd/            # Should be accessible to httpsd user
ls -ld /var/log/httpsd/       # Should be writable
ls -ld /var/run/httpsd/       # Should be writable
```

**Automated Verification Script:**
```bash
#!/bin/bash
# verify_httpsd_dirs.sh

REQUIRED_DIRS=(
  "/var/httpd"
  "/var/httpd/_certs"
  "/var/httpd/_certs/live"
  "/var/httpd/_certs/archive"
  "/var/httpd/_templates"
  "/var/log/httpsd"
  "/var/run/httpsd"
)

HTTPSD_USER="httpsd"  # Change if different in your setup

for dir in "${REQUIRED_DIRS[@]}"; do
  if [ ! -d "$dir" ]; then
    echo "❌ Missing: $dir"
    mkdir -p "$dir"
    chown -R "$HTTPSD_USER:$HTTPSD_USER" "$dir"
    chmod 755 "$dir"
    echo "✅ Created: $dir"
  else
    echo "✅ Exists: $dir"
  fi
done
```

### 2. Port Access Verification

HTTPSD requires access to ports for ACME challenges and HTTPS:

```bash
# Check port availability
netstat -tuln | grep -E ":80|:443"

# Port 80  - Required for HTTP-01 ACME challenges
# Port 443 - Required for HTTPS connections (auto-redirected from 80)

# If ports are in use, stop conflicting services:
systemctl stop apache2      # If Apache is running
systemctl stop nginx        # If Nginx is running
```

### 3. Configuration File Validation

Verify HTTPSD configuration:

```bash
# Check main config file
test -f /etc/httpsd.conf && echo "✅ Config found" || echo "❌ Config missing"

# Verify key settings in config:
grep -E "port|ssl|acme|certificate" /etc/httpsd.conf
```

### 4. Certificate Directory Permissions

Set up secure permissions for certificate storage:

```bash
# Ensure HTTPSD user can read certificates
chown -R httpsd:httpsd /var/httpd/_certs/
chmod 700 /var/httpd/_certs/
chmod 755 /var/httpd/_certs/live/
chmod 644 /var/httpd/_certs/live/*.pem
```

### 5. Network & Firewall Validation

Ensure network connectivity for Let's Encrypt validation:

```bash
# Test connectivity to Let's Encrypt
curl -I https://acme-v02.api.letsencrypt.org/directory

# If firewall is active, ensure these ports are open:
# - Port 80 (HTTP) - For ACME HTTP-01 challenges
# - Port 443 (HTTPS) - For HTTPS clients
# - Port 53 (DNS) - For DNS queries (optional, for ACME DNS challenges)

# Test firewall rules:
iptables -L -n | grep -E "80|443"
```

---

## Auto-Certificate Installation Flow

### Flow Diagram

```
[New Domain Request]
        ↓
[ACME Challenge Initiated]
        ↓
[HTTP-01 Challenge Created] ← HTTPSD listens on port 80
        ↓
[Let's Encrypt Validates] ← Connects to /.well-known/acme-challenge/{token}
        ↓
[Certificate Issued]
        ↓
[Certificate Downloaded]
        ↓
[Symlink Created]
        ↓
[HTTPS Ready]
```

### Step-by-Step Procedure

#### Step 1: Add New Virtual Host

```bash
# Add new vhost using Protocol-7 command
./bin/Protocol-7 httpd add-vhost "example.com"

# This creates:
# - /var/httpd/example.com/           (root directory)
# - /var/httpd/example.com/_templates/ (template directory)
```

#### Step 2: Configure ACME Challenge Handler

HTTPSD automatically configures the ACME challenge handler for HTTP-01:

```bash
# The following is automatic, but shown for reference:
# 1. Route /.well-known/acme-challenge/* to ACME handler
# 2. Handler verifies Let's Encrypt connection
# 3. Temporary challenge file created in memory
# 4. Handler responds with challenge token
```

**Handler Module:** `httpd.handler.acme_request`
**Location:** `/home/user/protocol-7/modules/httpd.handler.acme_request`

#### Step 3: ACME Challenge Validation

When Let's Encrypt validates the domain:

```
1. Let's Encrypt connects to: http://example.com:80/.well-known/acme-challenge/{token}
2. HTTPSD receives request
3. route_dispatcher routes to httpd.handler.acme_request
4. Handler returns challenge response
5. Let's Encrypt validates response
6. Certificate is issued
```

**Key Files Involved:**
- Request handler: `httpd.route_dispatcher`
- ACME handler: `httpd.handler.acme_request`
- Response validation: Internal ACME verification

#### Step 4: Certificate Installation & Symlink Creation

After successful validation:

```bash
# Certificate is saved to:
/var/httpd/_certs/archive/example.com/
  ├── cert1.pem      # Certificate
  ├── chain1.pem     # Chain
  ├── fullchain1.pem # Full chain
  └── privkey1.pem   # Private key

# Symlinks created in live directory:
/var/httpd/_certs/live/example.com/
  ├── cert.pem → ../archive/example.com/cert1.pem
  ├── chain.pem → ../archive/example.com/chain1.pem
  ├── fullchain.pem → ../archive/example.com/fullchain1.pem
  └── privkey.pem → ../archive/example.com/privkey1.pem

# HTTPS is now active for example.com
```

**Backup Management:**
- Previous certificates are archived with sequence numbers
- Symlinks always point to latest version
- Manual rollback possible by updating symlinks

#### Step 5: Verify Certificate Installation

```bash
# Check certificate was installed
ls -la /var/httpd/_certs/live/example.com/

# Verify certificate details
openssl x509 -in /var/httpd/_certs/live/example.com/cert.pem -noout -dates

# Expected output:
# notBefore=Nov 14 12:34:56 2025 GMT
# notAfter=Feb 12 12:34:56 2026 GMT (90 days)

# Test HTTPS connection
curl -I https://example.com/

# Expected output:
# HTTP/1.1 200 OK
# (Note: May get 502 if backend templates not configured yet)
```

---

## Startup Checklist

Use this checklist before starting HTTPSD in production:

### Phase 1: System Preparation (Before Starting)

- [ ] **Directories verified**
  - All required directories exist
  - Permissions are correct
  - Run: `bash verify_httpsd_dirs.sh`

- [ ] **Network verified**
  - Ports 80 and 443 are available
  - Firewall rules allow connections
  - Run: `netstat -tuln | grep -E ":80|:443"`

- [ ] **DNS configured**
  - Domain DNS points to server
  - Test: `nslookup example.com`
  - Test: `curl -I http://example.com/`

- [ ] **Configuration validated**
  - HTTPSD config file exists and is readable
  - SSL/TLS settings configured
  - ACME settings configured
  - Run: `grep -E "port|ssl|acme|certificate" /etc/httpsd.conf`

- [ ] **Permissions set**
  - HTTPSD user owns certificate directories
  - HTTPSD user can write to log directory
  - Run: `chown -R httpsd:httpsd /var/httpd/_certs /var/log/httpsd`

### Phase 2: Starting HTTPSD

```bash
# Start HTTPSD
systemctl start httpsd

# Verify it's running
systemctl status httpsd

# Check logs for startup messages
journalctl -u httpsd -n 50

# Test HTTP listener
curl -I http://localhost/

# Test HTTPS listener (after certificate is installed)
curl -I https://localhost/ 2>/dev/null || echo "HTTPS not yet ready"
```

- [ ] **Service started successfully**
  - `systemctl status httpsd` shows active
  - Logs show no errors
  - Run: `journalctl -u httpsd -n 20`

- [ ] **HTTP listener ready**
  - Port 80 is listening
  - ACME challenges respond
  - Run: `curl -I http://localhost/`

### Phase 3: Certificate Acquisition (First Time Only)

- [ ] **Request first certificate**
  - Use: `./bin/Protocol-7 httpd add-vhost "example.com"`
  - Or manually trigger ACME if system in place

- [ ] **ACME challenge successful**
  - Check logs for "ACME challenge successful"
  - Verify Let's Encrypt connected to port 80
  - Run: `grep -i "acme\|challenge" /var/log/httpsd/*`

- [ ] **Certificate installed**
  - Certificate file exists in `/var/httpd/_certs/live/`
  - Symlinks created correctly
  - Run: `ls -la /var/httpd/_certs/live/example.com/`

- [ ] **HTTPS working**
  - `curl -I https://example.com/` returns 200 or expected response
  - No SSL/certificate warnings
  - Run: `openssl s_client -connect example.com:443 -brief < /dev/null`

### Phase 4: Template & Content Configuration

- [ ] **Templates configured**
  - Index template exists at `/var/httpd/example.com/_templates/`
  - Static files in `/var/httpd/example.com/`

- [ ] **First page loads**
  - Visit https://example.com/ in browser
  - Verify HTTPS is active (lock icon in browser)
  - Check logs for any errors

- [ ] **Auto-renewal ready**
  - Check cron/systemd timer for renewal
  - Certificate renewal triggers before expiration (usually 30 days before)
  - No manual intervention needed

---

## Certificate Management

### Certificate Lifecycle

```
Day 0:   New certificate issued (90-day validity from Let's Encrypt)
         ↓
Day 60:  Auto-renewal begins (30 days before expiration)
         ↓
Day 63:  Renewal successful
         - Old certificate archived
         - New certificate installed
         - Symlink updated to point to new cert
         - HTTPS automatically uses new cert
         ↓
Day 90:  Old certificate expires (no impact, already replaced)
         ↓
Day 150: Cycle repeats with new certificate
```

### Manual Certificate Renewal

If automatic renewal fails:

```bash
# Manually trigger renewal
./bin/Protocol-7 httpd renew-certificate "example.com"

# Or using certbot directly (if available):
certbot renew --force-renewal -d example.com

# Monitor renewal process
journalctl -u httpsd -f | grep -i renewal
```

### Certificate Status Verification

```bash
# Check expiration dates of all certificates
for cert in /var/httpd/_certs/live/*/cert.pem; do
  domain=$(basename $(dirname "$cert"))
  expiry=$(openssl x509 -in "$cert" -noout -dates | grep notAfter | cut -d= -f2)
  echo "$domain expires: $expiry"
done

# Expected output example:
# example.com expires: Feb 12 12:34:56 2026 GMT
# api.example.com expires: Feb 12 13:45:00 2026 GMT

# Check certificate details
openssl x509 -in /var/httpd/_certs/live/example.com/cert.pem -noout -text
```

### Manual Certificate Rotation (Emergency)

If certificate needs immediate replacement:

```bash
# 1. Obtain new certificate (manual process or alternate CA)
# 2. Place in temporary location
# 3. Update symlinks

# Backup current certificate
mv /var/httpd/_certs/live/example.com/cert.pem \
   /var/httpd/_certs/live/example.com/cert.pem.backup

# Install new certificate
cp /path/to/new/cert.pem /var/httpd/_certs/live/example.com/

# Update other files if needed
# Verify certificate
openssl x509 -in /var/httpd/_certs/live/example.com/cert.pem -noout -dates

# Restart HTTPSD to load new certificate
systemctl restart httpsd

# Monitor logs
journalctl -u httpsd -n 20
```

### Certificate Backup & Recovery

```bash
# Backup all certificates
tar czf httpsd-certificates-$(date +%Y%m%d).tar.gz \
    /var/httpd/_certs/live/ \
    /var/httpd/_certs/archive/

# Store backup securely:
# - Off-site backup location
# - Encrypted storage
# - Version control (if safe)

# Restore from backup
tar xzf httpsd-certificates-20251114.tar.gz -C /

# Verify symlinks after restore
ls -la /var/httpd/_certs/live/*/
```

---

## Troubleshooting

### Issue: ACME Challenge Fails

**Symptom:** Certificate installation fails at ACME validation step

**Diagnosis:**
```bash
# Check if ACME handler is receiving requests
journalctl -u httpsd | grep -i acme

# Test HTTP-01 challenge manually
curl -v http://example.com:80/.well-known/acme-challenge/test-token

# Verify port 80 is accessible from outside
# (May need to test from different network)
```

**Solution:**
1. Verify port 80 is open and forwarded to HTTPSD
2. Check firewall rules allow inbound HTTP
3. Verify DNS points to correct IP
4. Test: `curl -I http://example.com/` from external network
5. Check HTTPSD logs: `journalctl -u httpsd -n 100`

### Issue: Certificate Symlink Broken

**Symptom:** HTTPS fails with certificate error after renewal

**Diagnosis:**
```bash
# Check symlinks
ls -la /var/httpd/_certs/live/example.com/

# Should show:
# cert.pem -> ../archive/example.com/cert2.pem
# privkey.pem -> ../archive/example.com/privkey2.pem
```

**Solution:**
```bash
# Recreate symlinks pointing to latest certificate
cd /var/httpd/_certs/live/example.com/

# Find latest certificate number
ls -t ../archive/example.com/cert*.pem | head -1
# Output: ../archive/example.com/cert2.pem

# Recreate symlinks
rm -f cert.pem privkey.pem chain.pem fullchain.pem
ln -s ../archive/example.com/cert2.pem cert.pem
ln -s ../archive/example.com/privkey2.pem privkey.pem
ln -s ../archive/example.com/chain2.pem chain.pem
ln -s ../archive/example.com/fullchain2.pem fullchain.pem

# Verify
ls -la

# Restart HTTPSD
systemctl restart httpsd
```

### Issue: Port 80 or 443 Already in Use

**Symptom:** HTTPSD fails to start, "Address already in use"

**Diagnosis:**
```bash
# Find what's using the port
netstat -tuln | grep LISTEN | grep -E ":80|:443"
lsof -i :80
lsof -i :443
```

**Solution:**
```bash
# Option 1: Stop the conflicting service
systemctl stop apache2
systemctl disable apache2

# Option 2: Change HTTPSD port (if not public HTTPS)
# Edit /etc/httpsd.conf
# Change: port = 8443

# Option 3: Use iptables to redirect ports
# Requires root; not recommended for production
```

### Issue: Certificate Expired Without Renewal

**Symptom:** HTTPS shows expired certificate warning

**Diagnosis:**
```bash
# Check actual expiration date
openssl x509 -in /var/httpd/_certs/live/example.com/cert.pem \
    -noout -dates

# Check renewal logs
journalctl -u httpsd | grep -i renew

# Check if renewal attempts exist
ls -la /var/httpd/_certs/archive/example.com/
```

**Solution:**
```bash
# Manually trigger renewal
./bin/Protocol-7 httpd renew-certificate "example.com"

# If renewal fails, check Let's Encrypt logs:
journalctl -u httpsd -n 200 | grep -i "acme\|renewal\|error"

# Nuclear option: Re-request certificate from scratch
./bin/Protocol-7 httpd del-vhost "example.com"
./bin/Protocol-7 httpd add-vhost "example.com"
```

---

## Monitoring & Maintenance

### Daily Monitoring

```bash
#!/bin/bash
# daily_httpsd_check.sh

echo "=== HTTPSD Status Check ==="

# Check service status
echo "1. Service Status:"
systemctl status httpsd | grep "Active:"

# Check certificate expiration (30 days warning)
echo "2. Certificates (expiring in < 30 days):"
for cert in /var/httpd/_certs/live/*/cert.pem; do
  domain=$(basename $(dirname "$cert"))
  expires=$(openssl x509 -in "$cert" -noout -dates | grep notAfter | cut -d= -f2)
  days_left=$(( ($(date -d "$expires" +%s) - $(date +%s)) / 86400 ))
  if [ $days_left -lt 30 ]; then
    echo "⚠️  $domain expires in $days_left days: $expires"
  else
    echo "✅ $domain expires in $days_left days"
  fi
done

# Check log for recent errors
echo "3. Recent Errors (last 24h):"
journalctl -u httpsd -S "24 hours ago" | grep -i error || echo "✅ No errors"

# Check disk usage
echo "4. Disk Usage:"
du -sh /var/httpd/_certs/

# Check listener ports
echo "5. Listener Status:"
netstat -tuln | grep -E ":80|:443" || echo "⚠️  Ports not listening"
```

### Weekly Tasks

- [ ] Review HTTPSD logs for errors
  ```bash
  journalctl -u httpsd -S "7 days ago" | grep -i error
  ```

- [ ] Verify certificate renewal processes
  ```bash
  journalctl -u httpsd -S "7 days ago" | grep -i renew
  ```

- [ ] Check for expired sessions or stale connections
  ```bash
  netstat -an | grep ESTABLISHED | wc -l
  ```

### Monthly Tasks

- [ ] Backup all certificates
  ```bash
  tar czf httpsd-certs-$(date +%Y%m).tar.gz /var/httpd/_certs/
  ```

- [ ] Review capacity and performance
  ```bash
  du -sh /var/log/httpsd/
  systemctl status httpsd
  ```

- [ ] Test disaster recovery procedures
  - Simulate certificate loss
  - Verify backup restoration
  - Confirm manual renewal works

---

## Automation Setup

### Systemd Timer for Auto-Renewal

The auto-renewal is typically managed by systemd timer (automatic):

```bash
# Check if renewal timer is active
systemctl list-timers | grep httpsd

# If not active, manually enable renewal
systemctl enable httpsd-renewal.timer
systemctl start httpsd-renewal.timer

# Monitor renewal
journalctl -u httpsd-renewal.timer -f
```

### Log Rotation

Configure logrotate for HTTPSD logs:

```bash
# Create /etc/logrotate.d/httpsd

/var/log/httpsd/*.log {
  daily
  missingok
  rotate 14
  compress
  delaycompress
  notifempty
  create 0640 httpsd httpsd
  sharedscripts
  postrotate
    systemctl reload httpsd > /dev/null 2>&1 || true
  endscript
}
```

---

## Summary

HTTPSD auto-initialization follows a fully automated flow:

1. **Setup:** Verify directories, permissions, and network access
2. **Add Domain:** Use `Protocol-7 httpd add-vhost` to register new domain
3. **ACME Challenge:** HTTPSD automatically handles HTTP-01 validation
4. **Certificate Installation:** Certificates auto-installed with symlinks
5. **HTTPS Ready:** Domain immediately available over HTTPS
6. **Auto-Renewal:** Happens automatically before expiration (no action needed)

This runbook covers all necessary startup and operational procedures for production deployment.

---

**Support Contact:** See Protocol-7 documentation
**Last Updated:** 2025-11-14
**Version:** 1.0
