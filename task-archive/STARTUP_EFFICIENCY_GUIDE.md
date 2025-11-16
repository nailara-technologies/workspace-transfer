# Protocol-7 Session Startup Efficiency Guide

**Purpose**: Minimize context loading time and maximize productivity in new sessions
**Last Updated**: 2025-11-14
**Version**: 1.0

---

## 🎯 Recommended Startup Sequence (5 minutes)

### Step 1: Initialize Environment (30 seconds)
```bash
# Source bootstrap script for environment variables
source ~/.session-bootstrap.sh

# This sets up:
# - PROTOCOL_7_ROOT, WORKSPACE_TRANSFER_ROOT, etc.
# - Helper functions for verification and testing
# - Quick paths to critical files
```

### Step 2: Verify System State (1-2 minutes)
```bash
# Option A: Quick status check
bash /home/user/protocol-7/bin/dev/verify-session-state.sh

# Option B: Full verification with testing
bash /home/user/protocol-7/bin/dev/verify-session-state.sh --full

# Expected output:
# ✅ Socket exists
# ✅ p7 client ready
# ✅ Documentation available
# ✅ Git repository healthy
# ✅ Authentication tests passing
```

### Step 3: Read Critical Context (2-3 minutes)
```bash
# Read THIS file first (you are here!)
cat /home/user/ACTIVE_SESSION_CHECKPOINT.md

# Then read session documentation
cat /home/user/protocol-7/docs/SESSION_STATUS_2025-11-14_template-auth-completion.md
```

### Step 4: Begin Development (ongoing)
```bash
cd /home/user/protocol-7
# Ready to start work!
```

---

## 📋 File Structure for Quick Reference

### **🚀 Quick Start** (Read First)
```
/home/user/ACTIVE_SESSION_CHECKPOINT.md
```
- **Purpose**: Current session state, quick commands, testing checklist
- **Time to read**: 2 minutes
- **Action**: Defines what to do next

### **⚙️ Bootstrap Script** (Run Second)
```
~/.session-bootstrap.sh
```
- **Purpose**: Set environment variables, provide helper functions
- **Usage**: `source ~/.session-bootstrap.sh`
- **Functions**: `verify_session_state`, `test_authentication`, `print_context`

### **✅ Verification Script** (Run Third)
```
/home/user/protocol-7/bin/dev/verify-session-state.sh
```
- **Purpose**: Automated system health check
- **Usage**: `bash verify-session-state.sh` or `bash verify-session-state.sh --full`
- **Output**: Status of socket, binary, docs, git, and auth tests

### **📚 Session Documentation** (Read Fourth)
```
/home/user/protocol-7/docs/SESSION_STATUS_2025-11-14_template-auth-completion.md
```
- **Purpose**: Complete session summary with test results
- **Contains**: Accomplishments, parser fixes, testing methodology, continuity checklist
- **Time to read**: 5 minutes

### **📖 Technical Documentation** (Reference)
```
/home/user/protocol-7/data/asc/TEMPLATE-USER-CONFIGURATION.md
/home/user/workspace-transfer/STATUS.md
```
- **Purpose**: Technical deep-dives and architecture documentation
- **When to read**: When developing new features or understanding the system

---

## 🔧 Environment Variables Setup

### Recommended `.bashrc` or `.zshrc` Addition

```bash
# Protocol-7 Session Setup
if [ -f ~/.session-bootstrap.sh ]; then
    source ~/.session-bootstrap.sh
fi

# Quick aliases for common tasks
alias proto7='cd /home/user/protocol-7'
alias wt='cd /home/user/workspace-transfer'
alias verify-proto7='bash /home/user/protocol-7/bin/dev/verify-session-state.sh'
alias test-proto7='verify_session_state && test_authentication'
```

### Critical Environment Variables

These are set by the bootstrap script:
```bash
PROTOCOL_7_ROOT="/home/user/protocol-7"
WORKSPACE_TRANSFER_ROOT="/home/user/workspace-transfer"
PROTOCOL_7_SOCKET_PATH="/var/run/.7/UNIX/NIW7OAQ"
PROTOCOL_7_UNIX_PATH="/var/run/.7/UNIX/NIW7OAQ"  # For p7 client
PROTOCOL_7_P7_CLIENT="/home/user/protocol-7/bin/p7"
SESSION_ID="01BE71ncAMyR7NYKASUBH3Kh"
SESSION_STATUS_FILE="/home/user/protocol-7/docs/SESSION_STATUS_2025-11-14_template-auth-completion.md"
```

---

## 🧠 For AI Model - Session Startup Instructions

### **At Session Start, Follow This Order:**

1. **Read this file** (you're doing this now!)
   - Understand the startup sequence
   - Know where critical files are

2. **Check `/home/user/ACTIVE_SESSION_CHECKPOINT.md`**
   - Quick overview of current state
   - What was accomplished
   - Testing checklist

3. **Verify system state**
   ```bash
   bash /home/user/protocol-7/bin/dev/verify-session-state.sh
   ```
   - Confirms cube zenka is running
   - Tests p7 client works
   - Verifies authentication system

4. **Read session documentation**
   - `/home/user/protocol-7/docs/SESSION_STATUS_2025-11-14_template-auth-completion.md`
   - Contains complete technical details
   - Has continuity checklist

5. **Begin development**
   - All context is loaded
   - System is verified
   - Ready to continue work

### **What Model Should Know Immediately**

- **Current Status**: Template-based authentication system COMPLETE and TESTED
- **Running State**: Cube zenka on socket `/var/run/.7/UNIX/NIW7OAQ`
- **Last Session**: Nov 14, 2025 - Fixed parser regex patterns, completed auth implementation
- **Critical Files Changed**:
  - `modules/base.parser.config` (lines 116, 129) - regex patterns fixed
  - `configuration/zenki/cube/auth.users` (lines 8-9) - template syntax updated
  - p7 client compiled from source

- **Test Results**: All three users authenticated successfully
  - `unix-root`: ✅ Working
  - `unix-kitten`: ✅ Working
  - `unix-taeki`: ✅ Working (template-based, newly fixed)

---

## 📊 Performance Metrics

### Session Startup Time Breakdown
| Step | Time | Action |
|------|------|--------|
| Environment init | 30 sec | Source bootstrap script |
| System verification | 1-2 min | Run verification script |
| Context reading | 2-3 min | Read critical docs |
| **Total** | **4-5 min** | **Ready to work** |

### Previous Manual Approach
- Reading multiple docs: 10-15 minutes
- Manual verification: 5-10 minutes
- Context fragmentation: High
- **Total**: 20-30 minutes ⚠️

### New Optimized Approach
- Automated verification: 2 minutes
- Structured reading: 3 minutes
- Complete context: High
- **Total**: 5 minutes ✅

**Efficiency Gain**: 4x faster startup time, better context preservation

---

## 🔄 Maintaining Session Continuity

### What to Update When

**After Completing Major Work**:
1. Update session checkpoint file
2. Run verification script to confirm state
3. Document critical changes in SESSION_STATUS file
4. Update environment variables if paths change

**If System Changes**:
1. Verify socket still works: `ls -la /var/run/.7/UNIX/`
2. If socket missing: Restart cube zenka
3. If p7 fails: Recompile from C source
4. Document in session status

**Weekly/Monthly**:
1. Review environment variables
2. Check if documentation needs updates
3. Verify git history is clean
4. Archive old session docs

---

## 🚨 Troubleshooting Quick Reference

### Socket Missing
```bash
# Problem: /var/run/.7/UNIX/NIW7OAQ doesn't exist
# Solution: Restart cube zenka
cd /home/user/protocol-7
./bin/Protocol-7 cube -BK -v

# Wait for: "UNX server launched [unix:NIW7OAQ]"
```

### p7 Client Not Working
```bash
# Problem: ./bin/p7 whoami returns "command not found"
# Solution: Recompile
cd /home/user/protocol-7/bin/c_src
gcc -o ../p7 p7.c
file ../p7  # Verify it compiled
```

### Authentication Failing
```bash
# Problem: USER=taeki ./bin/p7 whoami returns error
# Solution: Verify parser is working
# Check that base.parser.config lines 116, 129 don't have \< escaping
grep -n 'while.*_name.*=~' /home/user/protocol-7/modules/base.parser.config
# Should see: m|(?<!')<([\w_-]+)>(?!')| (without backslash before <)

# Restart cube if changes were made
```

---

## 💡 Optimization Ideas for Future Sessions

### Potential Improvements
1. **Automated cube restart script** - Detect dead socket, auto-restart
2. **Session context cache** - Store verification results, reuse if <1hr old
3. **Quick status LED** - Visual indicator of system state in shell prompt
4. **Continuous monitoring** - Background check that alerts if socket dies
5. **Auto-compilation** - Detect if p7 binary is stale, auto-recompile

### Possible Additions
- Health check that runs in background periodically
- Automated git sync before session start
- Signature verification for critical files
- Context database with searchable session history

---

## 📝 Session Checklist for New Session Startup

Use this checklist at the start of every new session:

```bash
# [ ] Source bootstrap script
source ~/.session-bootstrap.sh

# [ ] Run quick verification
bash /home/user/protocol-7/bin/dev/verify-session-state.sh

# [ ] Read checkpoint
cat /home/user/ACTIVE_SESSION_CHECKPOINT.md

# [ ] Read session docs
cat /home/user/protocol-7/docs/SESSION_STATUS_2025-11-14_template-auth-completion.md

# [ ] Test authentication
test_authentication

# [ ] Check git status on both repos
cd /home/user/protocol-7 && git status
cd /home/user/workspace-transfer && git status

# [ ] Ready to work!
echo "✅ Session initialized and verified"
```

---

## 🎓 Knowledge Transfer Summary

### What the AI Model Should Know by Session 3+

1. **System Architecture**
   - Protocol-7 is a multi-agent harmonic computing framework
   - Zenka are agents, zenki are agents-in-aggregate
   - Template variables enable user-agnostic configuration

2. **Critical Code Locations**
   - Parser: `/home/user/protocol-7/modules/base.parser.config`
   - Auth config: `/home/user/protocol-7/configuration/zenki/cube/auth.users`
   - Special user map: `/home/user/protocol-7/modules/base.access.special-user-map`
   - p7 client source: `/home/user/protocol-7/bin/c_src/p7.c`

3. **How Things Work**
   - Two-level template expansion (parse-time + runtime)
   - Unix domain socket authentication pattern
   - Configuration file syntax and structure

4. **Debugging Patterns**
   - Check socket exists before assuming cube is running
   - Verify p7 client is compiled before testing
   - Watch for regex escaping issues in Perl patterns
   - Look at parser.config for template expansion problems

---

**Created**: 2025-11-14
**Status**: Active - Next session should reference this document
**Maintenance**: Update as startup procedures evolve
