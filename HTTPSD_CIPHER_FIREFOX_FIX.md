# HTTPSD Cipher Configuration & Firefox Compatibility

**Priority**: High - Blocks remote testing with standard browsers  
**Scope**: YAML-based cipher configuration for HTTPSD  
**Impact**: Enable testing on remote servers with Firefox/Chrome without special configs  

---

## Current Problem

**In httpsd.create_ssl_socket:**
```perl
my @cipher_list = qw|
    DEFAULT !aNULL !eNULL !MD5 !3DES !DES !RC4 !IDEA !SEED !aDSS !SRP !PSK
|;
```

**Issue**: This restrictive filter breaks many modern browsers
- Firefox cannot negotiate handshake
- Chrome may also fail depending on cert type
- Requires manual SSL exception workarounds

**Root Cause**: Too aggressive filtering. DEFAULT with exclusions causes conflicts.

---

## Solution: Cipher Profile System

### Phase 1: YAML-Based Profiles

Create `/etc/protocol-7/httpsd-ciphers.yaml`:

```yaml
cipher_profiles:
  firefox_compatible:
    description: "Tested Firefox, Chrome, Safari, Brave"
    tls_versions:
      - "TLSv1_3"
      - "TLSv1_2"
    cipher_suite: |
      ECDHE-ECDSA-AES256-GCM-SHA384:
      ECDHE-ECDSA-CHACHA20-POLY1305:
      ECDHE-ECDSA-AES128-GCM-SHA256:
      ECDHE-RSA-AES256-GCM-SHA384:
      ECDHE-RSA-CHACHA20-POLY1305:
      ECDHE-RSA-AES128-GCM-SHA256
    certificate_key_types:
      - "ECDSA"
      - "RSA"
  
  high_security:
    description: "Minimal attack surface, client compatibility varies"
    tls_versions:
      - "TLSv1_3"
    cipher_suite: |
      TLS_AES_256_GCM_SHA384:
      TLS_CHACHA20_POLY1305_SHA256:
      TLS_AES_128_GCM_SHA256
    certificate_key_types:
      - "ECDSA"
      - "RSA"
  
  backward_compatible:
    description: "Older clients, includes deprecated ciphers"
    tls_versions:
      - "TLSv1_3"
      - "TLSv1_2"
    cipher_suite: |
      ECDHE-ECDSA-AES256-GCM-SHA384:
      ECDHE-ECDSA-CHACHA20-POLY1305:
      ECDHE-ECDSA-AES128-GCM-SHA256:
      ECDHE-RSA-AES256-GCM-SHA384:
      ECDHE-RSA-CHACHA20-POLY1305:
      ECDHE-RSA-AES128-GCM-SHA256:
      DHE-RSA-AES256-GCM-SHA384:
      DHE-RSA-AES128-GCM-SHA256
    certificate_key_types:
      - "ECDSA"
      - "RSA"

# Active profile for this deployment
active_profile: "firefox_compatible"
