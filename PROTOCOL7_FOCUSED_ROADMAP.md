# Protocol-7 Development Focus: Q4 2025
## Three Critical Work Items for Remote Testing & Template-Based Development

**Date**: 2025-11-28  
**Focus**: Unblocking practical development on remote servers  
**Goal**: Enable psychedelically-styled, template-based interfaces with knowledge import  

---

## 1. HTTPSD Cipher Configuration (YAML-Based)
### Problem: Firefox/Chrome Cannot Connect

**Current State**:
- Hardcoded restrictive cipher filter in `httpsd.create_ssl_socket`
- Works in lab but fails on remote servers with standard browsers
- No way to adjust without code changes

**Solution Path** (estimated 2-3 hours):

### Step 1: Create Cipher Profile System
**File**: `modules/httpsd.load_cipher_profile`
```perl
# Load cipher configuration from YAML
# Supports: firefox_compatible, high_security, backward_compatible
# Returns: (tls_version, cipher_suite, supported_key_types)
```

**File**: `/etc/protocol-7/httpsd-ciphers.yaml`
```yaml
cipher_profiles:
  firefox_compatible:
    tls_versions: [TLSv1_3, TLSv1_2]
    cipher_suite: "ECDHE-ECDSA-AES256-GCM-SHA384:..."
    key_types: [ECDSA, RSA]
  
  high_security:
    tls_versions: [TLSv1_3]
    cipher_suite: "TLS_AES_256_GCM_SHA384:..."
    key_types: [ECDSA]
  
  backward_compatible:
    tls_versions: [TLSv1_3, TLSv1_2]
    cipher_suite: "ECDHE-...:DHE-..."
    key_types: [ECDSA, RSA]

active_profile: firefox_compatible
```

### Step 2: Modify HTTPSD Initialization
**File**: `modules/httpsd.init_code`
```perl
# Load active cipher profile from YAML
<httpsd.cfg.cipher_suite> = load_cipher_profile('firefox_compatible');
```

### Step 3: Update Socket Creation
**File**: `modules/httpsd.create_ssl_socket`
```perl
# Use loaded profile instead of hardcoded defaults
my $cipher_suite = <httpsd.cfg.cipher_suite>;
my $tls_version = <httpsd.cfg.tls_version>;
```

### Step 4: Add Management Command
**File**: `modules/letsencr.cmd.set-cipher-profile`
```perl
# letsencrypt set-cipher-profile firefox_compatible
# Hot-reload without restart
```

**Success Criteria**:
- ✅ Firefox connects without warnings on remote server
- ✅ Chrome/Safari also work
- ✅ Can switch profiles with single YAML edit
- ✅ No code changes needed for different ciphers

**Testing**: 
```bash
# After changes:
firefox https://remote-server.example.com
# Should connect immediately without cert warnings
```

---

## 2. Web-Zenka Template Content Directory Integration
### Problem: Template Files Not Served to Clients

**Current State**:
- Web-zenka has recursive template processing (`web.process-template-ipc`)
- Content directories exist (`/data/web`, `/var/httpd/*/`)
- HTTP handler exists but doesn't route template requests properly

**Solution Path** (estimated 3-4 hours):

### Step 1: Create Content Directory Scanner
**File**: `modules/web.scan_content_directory`
```perl
# Scan /data/web and /var/httpd/{vhost}/ for template files
# Returns: hash of paths -> template metadata
# Monitors: *.html, *.template, _templates/ subdirectories
```

### Step 2: Create Route Dispatcher
**File**: `modules/httpd.route_template_request`
```perl
# Dispatch incoming requests:
# GET /page.html -> Check _templates/page.html -> route to web.process-template-ipc
# GET /blog/* -> Scan /blog/_templates/ for matching template
# GET /api/* -> Skip template processing
# GET /.well-known/acme-challenge/* -> Route to ACME handler
```

### Step 3: Integrate with HTTP Handler
**File**: Modify `modules/httpd.request_handler`
```perl
# Before serving file, check if template processing needed
# Pattern: /path/file.html
#   -> Look for /path/_templates/file.html
#   -> If exists, route to web.process-template-ipc (async)
#   -> Cache result (1800s TTL, 5MB max)
#   -> Return rendered content
```

### Step 4: Create Template Cache Manager
**File**: `modules/web.template_cache`
```perl
# Cache rendered templates: path -> (timestamp, content, size)
# Invalidation: File modification triggers cache clear
# Performance: Skip processing on cache hit
```

**Success Criteria**:
- ✅ `/data/web/index.html` + `/data/web/_templates/index.html` works
- ✅ Template variables rendered correctly
- ✅ Cache improves performance (measure ms)
- ✅ Can see template-based content in browser

**Testing**:
```bash
# Create test template
mkdir -p /data/web/_templates
echo '<p>Hello {name}!</p>' > /data/web/_templates/greeting.html
echo '{"name": "World"}' > /data/web/greeting.json

# Access via HTTP
curl https://localhost/greeting.html
# Output: <p>Hello World!</p>
```

---

## 3. Link-Upgrade Remote Testing Refinement
### Problem: Iteration Cycles Difficult for Agents Testing on Remote Servers

**Current State**:
- Link-upgrade (link-level encryption) mostly complete
- Works in lab but testing on remote servers is cumbersome
- Agent iteration cycles require manual setup

**Solution Path** (estimated 2-3 hours):

### Step 1: Create Remote Session Wrapper
**File**: `modules/base.handler.remote_session_init`
```perl
# Quick setup for agent testing on remote server
# Does: 
#   1. Initialize link-upgrade (Curve25519 key exchange)
#   2. Establish encrypted session
#   3. Return session token + encryption keys
#   4. Auto-cleanup after timeout
```

### Step 2: Create Agent Test Harness
**File**: `bin/test-remote-agent-workflow.pl`
```perl
# Connects to remote Protocol-7 instance
# Manages: Session creation, encryption, command execution
# Reports: Success/failure with detailed logs
# Use case: CI/CD pipeline or manual agent testing
```

### Step 3: Create Iteration Helper
**File**: `modules/cube.cmd.agent-test-loop`
```perl
# Commands:
# protocol-7 agent-test-loop --server remote.example.com --iterations 10
# Repeats: Init session -> Test command -> Verify -> Cleanup
# Reports: Performance metrics, failure patterns
```

### Step 4: Logging & Diagnostics
**File**: `modules/base.handler.link_upgrade_diagnostics`
```perl
# Logs for each step:
# - Key exchange completion (timing)
# - Cipher negotiation (which cipher selected)
# - Message encryption/decryption (round-trip latency)
# - Session cleanup
# Useful for: Agent debugging, performance analysis
```

**Success Criteria**:
- ✅ Agent can test on remote server with single command
- ✅ Iteration loop <30 seconds per test
- ✅ Detailed diagnostics for failures
- ✅ Works with multiple concurrent agents

**Testing**:
```bash
# Agent testing loop on remote server
perl bin/test-remote-agent-workflow.pl \
  --server protocol7.example.com \
  --iterations 5 \
  --verbose

# Output: Success/failure for each iteration with timing
```

---

## Implementation Order

### Week 1: Cipher Configuration (Highest Priority)
- Creates immediate value: Remote testing unblocked
- Lowest complexity
- No interdependencies

**Tasks**:
1. Design YAML schema (30 min)
2. Implement `httpsd.load_cipher_profile` module (1 hour)
3. Modify httpsd initialization (45 min)
4. Test with Firefox (1 hour)
5. Document profiles (30 min)

### Week 2: Template Directory Integration
- Enables practical use of templates
- Moderate complexity
- Builds on existing infrastructure

**Tasks**:
1. Create directory scanner module (1 hour)
2. Implement route dispatcher (1.5 hours)
3. Create cache manager (1 hour)
4. Integration testing (2 hours)
5. Performance optimization (1 hour)

### Week 3: Remote Agent Testing
- Enables distributed development workflow
- Moderate complexity
- Leverages link-upgrade

**Tasks**:
1. Session wrapper module (1 hour)
2. Test harness (`bin/` script) (1.5 hours)
3. Iteration helper commands (1 hour)
4. Diagnostics module (1 hour)
5. End-to-end testing (2 hours)

---

## Knowledge Import (Phase 4)
Once template infrastructure is solid, import from `protocol-7/data/asc/what-AI-thinks/`:

**Content to Import**:
- `html-form/templates/` - HTML templates
- `perl-form/` - Perl code examples
- `markdown-form/` - Documentation

**Integration**:
- Deduplicate knowledge
- Create template-based documentation site
- Psychedelic styling for interfaces

---

## Commits & Version Updates

**Commit Strategy** (direct to base):
```
[CLAUDE] 1. HTTPSD: Implement YAML-based cipher configuration

- Add cipher profile system
- Support firefox_compatible, high_security, backward_compatible
- Hot-reload with management command
- No code changes needed for different environments
```

```
[CLAUDE] 2. Web-Zenka: Integrate template directory processing

- Scan content directories for templates
- Route requests to template processor
- Implement caching (1800s TTL)
- Performance: <100ms for cached templates
```

```
[CLAUDE] 3. Link-Upgrade: Refine remote agent testing workflow

- Session wrapper for distributed testing
- Agent test harness for iteration
- Detailed diagnostics module
- Enables quick iteration cycles on remote servers
```

---

## Success Metrics

**After all three items complete**:
- ✅ Firefox/Chrome can connect to HTTPS without issues
- ✅ Template-based content served from `/data/web/`
- ✅ Agents can iterate on remote servers in <30 sec/loop
- ✅ Ready for knowledge import from what-AI-thinks
- ✅ Foundation for psychedelic interfaces

**Token Efficiency**:
- Estimated 8-12 tokens total (vs 34 originally planned)
- Focused on unblocking practical work
- Clean, incremental commits

---

## Next Session Checklist

**Preparation**:
- ✅ Clone protocol-7 repository
- ✅ Identify current HTTPSD cipher issue (test in Firefox)
- ✅ Review web.process-template-ipc infrastructure
- ✅ Check link-upgrade current status

**First Task**:
- Start with HTTPSD cipher configuration
- Test Firefox connectivity improvement
- Commit and move to templates

**Parallel Work**:
- Document findings in HTTPSD_CIPHER_FIREFOX_FIX.md
- Create test cases for remote Firefox access
