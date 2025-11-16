# Resume Session Prompt

Use this prompt when resuming work on the workspace-transfer repository to initialize a new session correctly.

---

## Resume Session on Base Branch

**CRITICAL: You are working on the `base` branch. Do NOT create a new branch.**

### Immediate Actions (Do These First)

```bash
# 1. Ensure you're on base branch
git checkout base
git pull origin base

# 2. Verify git remotes are correct (fix if showing local_proxy)
git remote -v

# If you see "local_proxy" in any URL, fix it immediately:
bin/configure-remote

# 3. Check status
git status
# Should be: "On branch base" and "working tree clean"
```

### What Was Just Completed (Session 2025-11-16)

**HTTPS/SSL Socket Reading Fix** ✅ VERIFIED
- File: `/home/user/protocol-7/modules/base.s_read`
- Fix: Detects `IO::Socket::SSL` objects and uses `sysread()` for TLS decryption
- Evidence: Live tested - plaintext HTTP confirmed received from encrypted socket
- Commits: `0e5970296`, `36995b73c`, `38fbe93e4` in protocol-7

**Git Remote URL Automation** ✅ DEPLOYED
- Scripts: `bin/configure-remote` and `bin/push-to-github`
- What: Automatically fixes local_proxy resets and retries with exponential backoff
- Where: workspace-transfer repository
- Usage: `bin/push-to-github base` if push fails

**START-HERE Onboarding** ✅ DEPLOYED
- Script: `./START-HERE` at repository root
- What: Single entry point for complete first-time developer setup
- Handles: PAT auth, cloning both repos, configuring remotes, checking dependencies

### Current File State

- `STATUS.md` - Fully updated with this session's work (lines 1-405)
- `docs/SESSION_INSIGHTS_2025-11-16.md` - Comprehensive session summary
- `docs/onboarding/PROTOCOL7_SETUP.md` - Updated with remote automation references
- `docs/reference/REMOTE_URL_CONFIGURATION.md` - Detailed automation script docs
- `START-HERE` - New onboarding script

### Git Configuration Check

```bash
# Verify both repositories have correct remotes
cd /home/user/workspace-transfer
git remote -v
# Should show: https://github.com/nailara-technologies/workspace-transfer.git

cd /home/user/protocol-7
git remote -v
# Should show: https://github.com/nailara-technologies/protocol-7.git

# Return to workspace-transfer
cd /home/user/workspace-transfer
```

### What to Do Next

After verifying you're on `base` branch and remotes are correct, ask:

**"I'm on base branch with clean working tree and correct remotes. What should I work on?"**

Do NOT:
- Create a new branch (work on `base` directly)
- Run `bin/deps install` without being asked
- Start new work without asking what to do
- Push without explicit instruction

Do push after completing work:
```bash
git add .
git commit -m "your message here"
bin/push-to-github base
```

### Quick Reference

**If git push fails:**
```bash
bin/configure-remote
bin/push-to-github base
```

**Check current priorities:**
```bash
cat STATUS.md | grep -A 5 "Current Development Priorities"
```

**Review session work:**
```bash
cat docs/SESSION_INSIGHTS_2025-11-16.md
```

---

**How to Use This Prompt**

When starting a new session and you need to resume work:

1. Copy this entire prompt (everything below this line)
2. Paste it into your Claude Code session as the initial instruction
3. Let Claude run the immediate verification commands
4. After verification, you'll be ready to ask what to work on

You are now ready to continue work on the `base` branch.
