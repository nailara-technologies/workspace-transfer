# Security Guidelines - Model Workspace

**⚠️ CRITICAL: This repository is PUBLIC on GitHub**

---

## Public Repository Awareness

### Repository Status
- **workspace-transfer**: ✅ PUBLIC repository
- **Base branch**: `base` (public)
- **Visibility**: Anyone can read all commits and files
- **Archive**: All history is permanently public

---

## Multi-Directory Context Awareness

### Important Warning
You may be working in different directories across sessions:
- `workspace-transfer/` ← PUBLIC repository (this one)
- Other private repositories ← NOT PUBLIC

**Before committing ANYTHING:**
1. Verify current directory: `pwd` or check context
2. Check git remote to confirm this is workspace-transfer
3. Ensure content is appropriate for PUBLIC visibility

---

## What NEVER to Commit

❌ **Credentials & Keys**:
- API keys, tokens, passwords
- SSH private keys
- Access tokens (GitHub, cloud providers, AI services)
- Authentication credentials

❌ **Sensitive Paths & Information**:
- Private code from other projects
- File paths revealing sensitive system architecture
- Internal URLs, IP addresses, server names
- Personal information beyond workspace-transfer context

❌ **Proprietary Content**:
- Proprietary algorithms or business logic
- Customer data or PII
- Internal company information
- Security vulnerabilities (before responsible disclosure)

---

## Pre-Commit Verification Checklist

Before **every** commit, ask yourself:

1. ✅ Is this workspace-transfer repository? (Check git remote)
2. ✅ Is this content public-safe? (No secrets, no proprietary code)
3. ✅ Are paths sanitized? (No revealing directory structures)
4. ✅ Are examples generic? (No real credentials)
5. ✅ Would I be comfortable with this on Hacker News?

If "no" or "unsure" to any → **STOP and ask human**

---

## Security Infrastructure

### .gitignore Protection
Location: `/.gitignore`

**Current protections**:
- `.credentials`, `.github-token`, `credentials.conf`
- `.initialized` (local session markers)
- `/work/` (external repos and builds)
- `*.tmp` (temporary files)

**Maintenance**: If you discover new credential file patterns, update .gitignore

### Pre-commit Hook (Secret Scanner)
Location: `/security/hooks/pre-commit-secret-scanner.pl`

**Status**: Available but NOT installed by default
**Install**: `perl security/hooks/install-pre-commit-hook.pl`

**Detects**:
- GitHub tokens (classic, fine-grained, OAuth, App)
- AWS access keys
- SSH private keys
- Passwords in URLs
- Slack tokens
- Generic secrets/passwords

**Maintenance**: If you discover new credential formats, update the scanner patterns

See `/security/README.md` and `/models/claude-code/SYSTEM/SECURITY.md` for detailed documentation.

---

## Emergency Response

### If Sensitive Data Committed (Not Yet Pushed)
```bash
# Undo commit, keep changes
git reset --soft HEAD~1
# Remove sensitive content from files
# Recommit clean version
```

### If Sensitive Data Already Pushed
**⚠️ IMMEDIATE ACTION:**
1. **Alert human immediately** - don't try to fix alone
2. **Assume compromised** - rotate all leaked credentials
3. **Don't rewrite history** - too late, already public
4. **Document incident** - for security review

---

## Content Sensitivity Levels

### ✅ Safe to Commit
- Protocol-7 architecture documentation
- Open source code and algorithms
- Public API documentation
- Generic workflow improvements
- Session summaries (without sensitive paths)
- This workspace's own content

### ⚠️ Review Before Committing
- File paths (revealing?)
- Configuration examples (sanitized?)
- Error messages (contain secrets?)
- Command examples (safe to share?)

### ❌ NEVER Commit
- Credentials, keys, tokens
- Private code from other projects
- Customer data, PII
- Internal system details
- Proprietary algorithms
- Security vulnerabilities

---

## Model-Specific Guidelines

### For CLI Models (Claude Code, etc.)
- Verify `git remote -v` before committing
- Check `pwd` to ensure in correct directory
- Review diffs before pushing

### For File-Based Models (via MCP, etc.)
- Double-check paths before file operations
- Verify repository context in prompts
- Use get_file_contents to verify before writes

### For All Models
- Read this SECURITY.md at session start
- Question before committing any paths
- Sanitize examples and error messages
- When unsure, ask human first

---

## Protocol-7 Context

This workspace supports Protocol-7 development, which is generally intended as open source. However:
- Check `CURRENT_FOCUS.md` for any sensitivity notes
- Verify specific features are meant to be public
- When in doubt about Protocol-7 content, ask

---

## Key Principle

**If you wouldn't put it on a billboard, don't commit it to public GitHub.**

**Git history is forever** - prevention is the only reliable protection.

---

**Last Updated**: 2025-10-03
**Applies To**: All model workspaces in this repository
**Review**: Every session start
**Importance**: CRITICAL 🔴

---

**For detailed security procedures, see**:
- Main security docs: `/security/README.md`
- Claude Code security: `/models/claude-code/SYSTEM/SECURITY.md`
- Secret scanner guide: `/security/SECRET_SCANNER_GUIDE.md`
