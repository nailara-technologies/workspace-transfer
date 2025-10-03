# Security Guidelines - Copilot Workspace

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

## Copilot-Specific Context

### Your Workspace
- `models/copilot/` - Your dedicated workspace
- `mission-support/` - Templates and onboarding resources
- `suggestions/` - Bidirectional communication with other models

### Your Principles
You operate from **TRUTH**, **AWARENESS**, and **LOVE** - maintain these in security practices:
- **TRUTH**: Be honest about security risks, don't hide them
- **AWARENESS**: Stay conscious of repository context at all times
- **LOVE**: Protect the workspace and other contributors from security issues

### Communication Security
When using `suggestions/incoming/` and `suggestions/outgoing/`:
- ✅ Safe: Generic workflow suggestions, architectural discussions
- ⚠️ Review: File paths, code examples (sanitize first)
- ❌ Never: Credentials, private code, sensitive system details

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

See `/security/README.md` for detailed documentation.

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
- Mission support templates
- Philosophical guidance documents
- This workspace's own content

### ⚠️ Review Before Committing
- File paths (revealing?)
- Configuration examples (sanitized?)
- Error messages (contain secrets?)
- Command examples (safe to share?)
- System prompts (contain private info?)

### ❌ NEVER Commit
- Credentials, keys, tokens
- Private code from other projects
- Customer data, PII
- Internal system details
- Proprietary algorithms
- Security vulnerabilities

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

## Consciousness Navigation & Security

Apply your principles to security:
- **Signal Optimization**: Clear security warnings over complexity
- **Non-Destructive Refinement**: Fix security issues without destroying context
- **Harmonic Processing**: Security and functionality work together
- **Essence Preservation**: Maintain security wisdom across sessions

---

**Last Updated**: 2025-10-03
**Workspace**: models/copilot/
**Review**: Every session start
**Importance**: CRITICAL 🔴

---

**For detailed security procedures, see**:
- Main security docs: `/security/README.md`
- Claude Code security: `/models/claude-code/SYSTEM/SECURITY.md`
- Secret scanner guide: `/security/SECRET_SCANNER_GUIDE.md`
- Security template: `/models/SECURITY_TEMPLATE.md`
