# Phase 4: Integration Testing & Documentation - Comprehensive Guide

**Date:** 2025-11-14
**Status:** ✅ INITIATED - Zenka Services Ready for Testing
**Session ID:** claude/protocol7-https-zenki-setup-01VrYcCBJ5FfHnF6Ji6Fhq23

---

## Executive Summary

Phase 4 focuses on comprehensive integration testing of the HTTPS zenka system now that all services are initialized and running. This guide provides detailed test procedures for verifying all critical components:

1. **HTTP Route Dispatcher** - All 4 route types (ACME, API, templates, static)
2. **HTTPS Certificate Management** - ACME auto-update and renewal
3. **Web Template Processing** - Recursive template processing with caching
4. **Skin & Menu System** - Dynamic content rendering

---

## Part 1: Environment Setup & Verification

### 1.1 Zenka Services Status

**Configuration Updated:**
```
File: /home/user/protocol-7/configuration/zenki/v7/start-set-up.base

Previous: zenki.enabled = cube p7-log system events
New:      zenki.enabled = cube p7-log httpd httpsd letsencrypt web
```

**Rationale:**
- Removed `system` and `events` zenkas (not needed for HTTPS testing)
- Added `httpd`, `httpsd`, `letsencrypt`, `web` for comprehensive testing

### 1.2 Service Initialization Status

**✅ Successfully Initialized:**
- ✅ **httpd** - Online and operational
- ✅ **letsencrypt** - ACME server ready at http://localhost:8555/directory
  - Account key: `/var/cache/letsencrypt/account.key`
  - Forked child process for ACME management
- ✅ **web** - Web system loaded with 67 operational subroutines
- ✅ **p7-log** - Logging service online

**⚠️ Non-Blocking Issues:**
- crypt.C25519 key directory permissions (`/home/protocol-7/.n/user-keys`)
- Missing Perl modules: `Crypt::OpenSSL::RSA`, `Crypt::OpenSSL::X509`
  - Status: Non-blocking (ACME working without these)

### 1.3 Port Configuration Verification

**Expected Listening Ports:**
- Port 80: HTTP server (httpd)
- Port 443: HTTPS server (httpsd)
- Port 8555: Mock ACME server (for testing)

**Test Command:**
```bash
netstat -tuln | grep -E "80|443|8555"
# or
ss -tuln | grep -E "80|443|8555"
```

---

## Part 2: HTTP Route Dispatcher Testing

### Architecture Overview

The route dispatcher (`httpd.route_dispatcher`) implements a 4-tier routing system:

```
HTTP Request
    ↓
[httpd.route_dispatcher]
    ├→ Route 1: ACME Challenges (/.well-known/acme-challenge/*)
    │   Handler: httpd.handler.acme_request
    │   Cache: No caching (TTL=0)
    │
    ├→ Route 2: API Endpoints (/api/*)
    │   Handler: letsencrypt.http.api_handler
    │   Cache: 5 minutes (TTL=300)
    │
    ├→ Route 3: Template-Based Content (/**/*.html, etc.)
    │   Handler: httpd.process_template
    │   Template Resolver: httpd.vhost_template_resolver (3-level hierarchy)
    │   Cache: 30 minutes (TTL=1800)
    │
    └→ Route 4: Static Files (fallback)
        Handler: httpd.serve_static
        Cache: 1 hour (TTL=3600)
```

### 2.1 Test Case 1: ACME Challenge Route

**Objective:** Verify ACME HTTP-01 challenge responses

**Test Setup:**
```bash
# Create test directory structure
mkdir -p /var/httpd/_acme_challenges

# Create test challenge file
echo "test_challenge_token.validation_string" > \
  /var/httpd/.well-known/acme-challenge/test_token_12345
```

**Test Execution:**
```bash
# Simulate ACME challenge request
curl -v http://localhost/.well-known/acme-challenge/test_token_12345

# Expected Response:
# HTTP/1.1 200 OK
# Content-Type: text/plain
# Body: test_challenge_token.validation_string
```

**Pass Criteria:**
- ✅ HTTP 200 response
- ✅ Challenge token returned correctly
- ✅ No caching (immediate availability of new challenges)
- ✅ Proper ACME challenge format

---

### 2.2 Test Case 2: API Endpoint Route

**Objective:** Verify API endpoint routing and caching

**Test Setup:**
```bash
# Create API endpoint mock
mkdir -p /var/httpd/api

# Create test API response
cat > /var/httpd/api/status.json <<'EOF'
{
  "status": "operational",
  "version": "1.0",
  "timestamp": "2025-11-14T21:00:00Z"
}
EOF
```

**Test Execution:**
```bash
# Test API endpoint request
curl -v http://localhost/api/status.json

# Expected Response:
# HTTP/1.1 200 OK
# Content-Type: application/json
# Body: {"status": "operational", ...}

# Test caching (should be cached for 5 minutes)
curl -v http://localhost/api/status.json -H "X-Cache-Test: true"
```

**Pass Criteria:**
- ✅ HTTP 200 response
- ✅ JSON content served correctly
- ✅ Cache header: `X-Cache-Age: <seconds>` (5-min TTL)
- ✅ Subsequent requests use cache

---

### 2.3 Test Case 3: Template-Based Content Route

**Objective:** Verify template resolution and processing

**Test Setup:**

```bash
# Create vhost directory structure for example.com
mkdir -p /var/httpd/example.com/_templates
mkdir -p /var/httpd/example.com/blog/_templates
mkdir -p /var/httpd/_global_templates

# Create templates at different hierarchy levels
# Level 1: Subdirectory-specific template
cat > /var/httpd/example.com/blog/_templates/post.html.tmpl <<'EOF'
<!DOCTYPE html>
<html>
<head><title><{post_title}></title></head>
<body>
<h1><{post_title}></h1>
<div class="content">
<[get_post_content]>
</div>
<p>Published: <{published_date}></p>
</body>
</html>
EOF

# Level 2: Vhost-root level template (fallback)
cat > /var/httpd/example.com/_templates/blog/article.html.tmpl <<'EOF'
<article>
<h2><{title}></h2>
<p><{summary}></p>
</article>
EOF

# Level 3: Global template (fallback)
cat > /var/httpd/_global_templates/page.html.tmpl <<'EOF'
<div class="page">
  <content/>
</div>
EOF
```

**Test Execution:**

```bash
# Test template resolution for /blog/post.html
# Should resolve to: /var/httpd/example.com/blog/_templates/post.html.tmpl

curl -v -H "Host: example.com" http://localhost/blog/post.html \
  -H "X-Post-Title: My Blog Post" \
  -H "X-Published-Date: 2025-11-14"

# Expected Response:
# HTTP/1.1 200 OK
# Content-Type: text/html
# Body: Processed HTML with meta variables substituted
```

**Pass Criteria:**
- ✅ Correct template selected (3-level hierarchy working)
- ✅ Meta variables substituted (`<{post_title}>` → actual value)
- ✅ Commands executed (`<[get_post_content]>` → result)
- ✅ Cache header: `X-Cache-Age: <seconds>` (30-min TTL)

---

### 2.4 Test Case 4: Static File Fallback Route

**Objective:** Verify fallback to static files when no template exists

**Test Setup:**

```bash
# Create static files
mkdir -p /var/httpd/example.com/images

cat > /var/httpd/example.com/images/logo.png <<'EOF'
(Binary PNG data)
EOF

cat > /var/httpd/example.com/robots.txt <<'EOF'
User-agent: *
Disallow: /admin
Allow: /
EOF
```

**Test Execution:**

```bash
# Test static file serving
curl -v -H "Host: example.com" http://localhost/images/logo.png
curl -v -H "Host: example.com" http://localhost/robots.txt

# Expected Response:
# HTTP/1.1 200 OK
# Content-Type: (appropriate MIME type)
# Content: (file contents)
# Cache-Control: max-age=3600
```

**Pass Criteria:**
- ✅ HTTP 200 response for static files
- ✅ Correct MIME types (`image/png`, `text/plain`)
- ✅ Long cache TTL (1 hour)
- ✅ Fallback only when template not found

---

## Part 3: Web Template Processing Testing

### 3.1 Recursive Template Processing Test

**Objective:** Verify `web.process_template_recursive` handles nested templates correctly

**Module Reference:** `modules/web.process_template_recursive` (179 lines)

**Configuration:**
- Recursion depth limit: Max 8 levels
- Caching TTL: 1800 seconds (30 minutes)
- Parallel command limit: 16 concurrent

**Test Case: Multi-Level Nested Templates**

```bash
# Create nested template structure
cat > /var/httpd/example.com/_templates/nested.html.tmpl <<'EOF'
<html>
<head>
  <title><{site_title}></title>
  <meta name="author" content="<{author}>">
</head>
<body>
  <h1><{page_title}></h1>

  <section class="content">
    <[web.load_section:features]>
  </section>

  <section class="sidebar">
    <[web.load_sidebar]>
  </section>

  <footer>
    <p>Last updated: <[date_now]></p>
  </footer>
</body>
</html>
EOF

# Create included template
cat > /var/httpd/example.com/_templates/components/features.html.tmpl <<'EOF'
<ul>
  <li>Feature 1: <[get_feature:1]></li>
  <li>Feature 2: <[get_feature:2]></li>
  <li>Feature 3: <{computed_feature}></li>
</ul>
EOF
```

**Test Execution:**

```bash
# Request template with nested inclusions
curl -v -H "Host: example.com" http://localhost/nested.html \
  -H "X-Site-Title: My Website" \
  -H "X-Page-Title: Features" \
  -H "X-Author: John Doe"

# Monitor:
# 1. Time to first byte (TTFB)
#    - With caching: <100ms
#    - Without caching: <500ms
#
# 2. HTML structure validity
#
# 3. Variable substitution correctness
#
# 4. Recursive call depth (should not exceed 8)
```

**Pass Criteria:**
- ✅ All meta variables substituted correctly
- ✅ All commands executed in order
- ✅ No recursion depth exceeded errors
- ✅ Proper cache usage (second request faster)
- ✅ Valid HTML output

**Edge Cases to Test:**

1. **Circular Dependency:**
   ```bash
   # Template A includes B, B includes A
   # Should handle gracefully without infinite loop
   ```

2. **Maximum Recursion Depth:**
   ```bash
   # Create 9-level nested templates
   # Should stop at level 8 with error message
   ```

3. **Invalid Commands:**
   ```bash
   # Template with invalid command syntax
   # <[invalid_command_that_doesnt_exist]>
   # Should handle gracefully
   ```

---

### 3.2 Meta Variable Substitution Test

**Syntax:** `<{variable_name}>`

**Test Cases:**

```bash
cat > /var/httpd/example.com/_templates/variables.html.tmpl <<'EOF'
<html>
<body>
  <p>Simple: <{user_name}></p>
  <p>Default: <{missing_var|'Anonymous'}></p>
  <p>Nested: <{site.<{env}>.url}></p>
  <p>Expression: <{calc: 10 + 5}></p>
</body>
</html>
EOF
```

**Pass Criteria:**
- ✅ Simple variables substituted
- ✅ Default values used when missing
- ✅ Nested variable references resolved
- ✅ Mathematical expressions evaluated

---

### 3.3 Command Execution Test

**Syntax:** `<[command_name:arg1:arg2]>`

**Test Cases:**

```bash
cat > /var/httpd/example.com/_templates/commands.html.tmpl <<'EOF'
<html>
<body>
  <p>Get content: <[get_file:/path/to/file]></p>
  <p>Database query: <[db_query:SELECT * FROM users]></p>
  <p>Parallel commands:</p>
  <ul>
    <li><[fetch_data:user_123]></li>
    <li><[fetch_data:user_456]></li>
    <li><[fetch_data:user_789]></li>
  </ul>
</body>
</html>
EOF
```

**Pass Criteria:**
- ✅ Commands execute in order
- ✅ Results substituted in template
- ✅ Parallel commands (up to 16) execute concurrently
- ✅ Error handling for failed commands
- ✅ Timeouts respected

---

## Part 4: HTTPS Certificate Auto-Update Testing

### 4.1 ACME Certificate Generation Test

**Objective:** Verify Let's Encrypt integration for certificate generation

**Module Reference:** `modules/letsencrypt.base` and `modules/letsencrypt.child.*`

**Configuration:**
```
ACME Server: http://localhost:8555/directory
Account Key: /var/cache/letsencrypt/account.key
Challenge Type: HTTP-01
```

**Test Execution:**

```bash
# 1. Verify ACME server is accessible
curl -v http://localhost:8555/directory

# Expected Response:
# HTTP/1.1 200 OK
# {
#   "newNonce": "...",
#   "newAccount": "...",
#   "newOrder": "...",
#   ...
# }

# 2. Trigger certificate request for test domain
# (Implementation depends on letsencrypt zenka interface)
p7 letsencrypt request-certificate test.example.com

# 3. Monitor ACME challenge process
# Watch logs: tail -f /var/log/protocol-7/letsencrypt.log

# Expected steps:
# [1] Create order for test.example.com
# [2] Get authorization challenges (HTTP-01)
# [3] Place challenge file at /.well-known/acme-challenge/*
# [4] Notify ACME server to validate
# [5] Download certificate
# [6] Symlink certificate to /var/httpd/_certs/live/test.example.com/
```

**Pass Criteria:**
- ✅ ACME server connectivity confirmed
- ✅ Account key properly generated
- ✅ Certificate order created
- ✅ HTTP-01 challenge accepted
- ✅ Certificate downloaded and validated
- ✅ Symlink created in `/var/httpd/_certs/live/`

---

### 4.2 Certificate Symlink Management Test

**Objective:** Verify certificate symlink updates don't break HTTPS

**Architecture:**
```
/var/httpd/_certs/
├── archive/
│   ├── example.com/
│   │   ├── cert1.pem (v1.0)
│   │   ├── cert2.pem (v1.1)
│   │   └── cert3.pem (v1.2)
│   └── ...
│
└── live/
    ├── example.com/
    │   ├── cert.pem → ../archive/example.com/cert3.pem
    │   ├── chain.pem → ../archive/example.com/chain3.pem
    │   ├── fullchain.pem → ../archive/example.com/fullchain3.pem
    │   └── privkey.pem → ../archive/example.com/privkey3.pem
    └── ...
```

**Test Execution:**

```bash
# 1. Get current certificate version
ls -la /var/httpd/_certs/live/example.com/cert.pem

# 2. Request certificate renewal
p7 letsencrypt renew-certificate example.com

# 3. Verify HTTPS still works during renewal
curl -k -v https://example.com/

# Expected:
# - HTTPS connection successful
# - Certificate valid (not expired)
# - No service interruption

# 4. Verify symlink points to new certificate
ls -la /var/httpd/_certs/live/example.com/cert.pem
# Should point to newer version in archive/

# 5. Verify old certificate still accessible
# (for rollback if needed)
ls -la /var/httpd/_certs/archive/example.com/
# Should show multiple cert versions
```

**Pass Criteria:**
- ✅ Symlink updates work without downtime
- ✅ New certificate becomes active immediately
- ✅ Old certificates retained for rollback
- ✅ HTTPS connections uninterrupted during update

---

### 4.3 Certificate Expiration Monitoring Test

**Objective:** Verify certificate expiration detection and renewal triggers

**Configuration:**
```
Renewal check interval: Configurable (default: daily)
Renewal threshold: 30 days before expiration
Monitoring: p7-log zenka with forensics enabled
```

**Test Execution:**

```bash
# 1. Check certificate expiration date
openssl x509 -in /var/httpd/_certs/live/example.com/cert.pem \
  -noout -dates

# 2. Verify monitoring logs
tail -f /var/log/protocol-7/letsencrypt.log

# Expected logs:
# [2025-11-14 21:45:00] Certificate check: example.com
# [2025-11-14 21:45:00] Days to expiration: 25
# [2025-11-14 21:45:00] Renewal required: YES

# 3. Force renewal trigger (test)
p7 letsencrypt check-expiration --verbose

# 4. Monitor automatic renewal
# Wait for scheduled renewal task or trigger manually
```

**Pass Criteria:**
- ✅ Expiration date correctly detected
- ✅ Renewal triggered when < 30 days to expiration
- ✅ Renewal completed before expiration
- ✅ Monitoring logs comprehensive and accurate

---

## Part 5: Skin & Menu System Testing

### 5.1 Skin Resolution Test

**Module Reference:** `modules/web.skin_resolver`

**Available Skins:**
- Default (fallback)
- Dark mode variant
- Mobile-responsive variant

**Test Setup:**

```bash
# Create skin hierarchy
mkdir -p /var/httpd/example.com/_skins/default
mkdir -p /var/httpd/example.com/_skins/dark
mkdir -p /var/httpd/example.com/_skins/mobile

# Create skin files
cat > /var/httpd/example.com/_skins/default/style.css <<'EOF'
body { background: white; color: black; }
EOF

cat > /var/httpd/example.com/_skins/dark/style.css <<'EOF'
body { background: #333; color: #fff; }
EOF

cat > /var/httpd/example.com/_skins/mobile/style.css <<'EOF'
@media (max-width: 768px) {
  body { font-size: 14px; }
}
EOF
```

**Test Execution:**

```bash
# Test 1: Request with default skin
curl -v http://example.com/style.css

# Expected:
# HTTP/1.1 200 OK
# CSS with default skin (white background)

# Test 2: Request with dark skin
curl -v http://example.com/style.css -H "X-Skin: dark"

# Expected:
# HTTP/1.1 200 OK
# CSS with dark skin (#333 background)

# Test 3: Request with mobile skin
curl -v http://example.com/style.css \
  -H "X-Skin: mobile" \
  -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS)"

# Expected:
# HTTP/1.1 200 OK
# CSS with mobile optimizations
```

**Pass Criteria:**
- ✅ Default skin serves when none requested
- ✅ Specific skin serves when requested
- ✅ Mobile skin applies for mobile user agents
- ✅ Skin cascading works correctly
- ✅ Caching respects skin selection

---

### 5.2 Menu Generation Test

**Module Reference:** `modules/web.menu_generator`

**Test Setup:**

```bash
# Create directory structure for menu generation
mkdir -p /var/httpd/example.com/pages/products/electronics/laptops
mkdir -p /var/httpd/example.com/pages/products/electronics/phones
mkdir -p /var/httpd/example.com/pages/products/furniture
mkdir -p /var/httpd/example.com/pages/about

# Create content files
cat > /var/httpd/example.com/pages/products/electronics/laptops/index.html <<'EOF'
<h1>Laptops</h1>
<p>High-performance computing devices</p>
EOF

# Create metadata (optional)
cat > /var/httpd/example.com/pages/.menu.json <<'EOF'
{
  "products": { "label": "Products", "icon": "shopping" },
  "electronics": { "label": "Electronics", "icon": "circuit" },
  "laptops": { "label": "Laptops", "priority": 1 },
  "phones": { "label": "Phones", "priority": 2 }
}
EOF
```

**Test Execution:**

```bash
# Test 1: Generate menu from filesystem
curl -v http://example.com/api/menu.json

# Expected Response:
# {
#   "items": [
#     {
#       "label": "Products",
#       "url": "/pages/products/",
#       "children": [
#         {
#           "label": "Electronics",
#           "url": "/pages/products/electronics/",
#           "children": [
#             { "label": "Laptops", "url": "/pages/products/electronics/laptops/" },
#             { "label": "Phones", "url": "/pages/products/electronics/phones/" }
#           ]
#         },
#         { "label": "Furniture", "url": "/pages/products/furniture/" }
#       ]
#     },
#     { "label": "About", "url": "/pages/about/" }
#   ]
# }

# Test 2: Menu with active page highlighting
curl -v http://example.com/api/menu.json?current=/pages/products/electronics/laptops/

# Expected:
# Laptops item should have "active": true attribute
```

**Pass Criteria:**
- ✅ Menu structure auto-generated from directories
- ✅ Metadata correctly applied (labels, icons, priority)
- ✅ Nested structure preserved
- ✅ Current page highlighted
- ✅ Menu cacheable for performance

---

## Part 6: Test Execution & Results Documentation

### 6.1 Test Automation Script

Create `/home/user/protocol-7/tests/integration_test_suite.pl`:

```perl
#!/usr/bin/env perl
# Integration Test Suite for HTTPS Zenka System
# Tests all critical routes and functionality

use strict;
use warnings;
use LWP::UserAgent;
use JSON::XS;
use Time::HiRes qw(gettimeofday tv_interval);

my $ua = LWP::UserAgent->new(
    timeout => 10,
    ssl_opts => { verify_hostname => 0 }
);

my @test_cases = (
    # Route 1: ACME Challenges
    {
        name => "ACME Challenge Route",
        method => "GET",
        url => "http://localhost/.well-known/acme-challenge/test_token",
        expected_status => 200
    },
    # Route 2: API Endpoints
    {
        name => "API Endpoint Route",
        method => "GET",
        url => "http://localhost/api/status.json",
        expected_status => 200
    },
    # ... more test cases
);

my $passed = 0;
my $failed = 0;

foreach my $test (@test_cases) {
    print "Testing: $test->{name}... ";

    my $start = [gettimeofday];
    my $response = $ua->$test->{method}($test->{url});
    my $elapsed = tv_interval($start);

    if ($response->code == $test->{expected_status}) {
        print "✅ PASS ($elapsed s)\n";
        $passed++;
    } else {
        print "❌ FAIL (Expected $test->{expected_status}, got $response->code)\n";
        $failed++;
    }
}

print "\n=== Test Summary ===\n";
print "Passed: $passed\n";
print "Failed: $failed\n";
print "Total: " . ($passed + $failed) . "\n";
```

### 6.2 Results Documentation Template

```markdown
# Integration Test Results - 2025-11-14

## Route Dispatcher Tests

### Route 1: ACME Challenges
- Status: ✅ PASS
- Response Time: 45ms
- Cache: Disabled (as expected)

### Route 2: API Endpoints
- Status: ✅ PASS
- Response Time: 32ms
- Cache: 5-minute TTL

### Route 3: Template Content
- Status: ✅ PASS
- Response Time: 125ms (first request)
- Response Time: 12ms (cached)

### Route 4: Static Files
- Status: ✅ PASS
- Response Time: 15ms
- Cache: 1-hour TTL

## Template Processing Tests
- ✅ Recursive template processing
- ✅ Meta variable substitution
- ✅ Command execution
- ✅ Caching

## Certificate Tests
- ✅ ACME integration
- ✅ Certificate generation
- ✅ Symlink management
- ✅ Expiration monitoring

## Overall Result: ✅ ALL TESTS PASSED
```

---

## Part 7: Troubleshooting Guide

### Common Issues & Solutions

**Issue 1: "Port 80 already in use"**
```bash
# Find process using port 80
lsof -i :80
# Kill and restart
kill -9 <PID>
systemctl restart httpd  # or service httpd restart
```

**Issue 2: "Template not found"**
```bash
# Check 3-level resolution order
# 1. /var/httpd/{vhost}/{path}/_templates/{file}.tmpl
# 2. /var/httpd/{vhost}/_templates/{path}/{file}.tmpl
# 3. /var/httpd/_global_templates/{path}/{file}.tmpl

# Verify file permissions
ls -la /var/httpd/example.com/_templates/

# Check httpd error logs
tail -f /var/log/protocol-7/httpd.log
```

**Issue 3: "Certificate not renewing"**
```bash
# Check ACME server connectivity
curl http://localhost:8555/directory

# Verify Let's Encrypt logs
tail -f /var/log/protocol-7/letsencrypt.log

# Check certificate expiration
openssl x509 -in /var/httpd/_certs/live/*/cert.pem -noout -dates

# Force renewal
p7 letsencrypt renew-certificate --force example.com
```

---

## Summary

This guide provides comprehensive testing procedures for Phase 4 integration testing. All tests should be executed in order, with results documented for the final integration verification report.

**Next Steps:**
1. Execute all test cases in Part 2-5
2. Document results using the template in Part 6.2
3. Address any failures using the troubleshooting guide
4. Create final integration verification report
5. Prepare for Phase 4.4 (Session handoff documentation)

---

**Document Version:** 1.0
**Created:** 2025-11-14
**Status:** ✅ READY FOR EXECUTION
