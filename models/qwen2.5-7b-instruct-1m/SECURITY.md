# Security Guidelines - Qwen2.5-7B Workspace

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

**Before ANY file operation:**
1. Verify current directory context
2. Check repository via path verification
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

❌ **Training Data & Model Artifacts**:
- Private training datasets
- Proprietary model weights
- Customer data used in training
- Sensitive evaluation results

---

## Pre-Commit Verification Checklist

Before **every** file write/commit, ask yourself:

1. ✅ Is this workspace-transfer repository?
2. ✅ Is this content public-safe? (No secrets, no proprietary code)
3. ✅ Are paths sanitized? (No revealing directory structures)
4. ✅ Are examples generic? (No real credentials)
5. ✅ Would I be comfortable with this on Hacker News?

If "no" or "unsure" to any → **STOP and ask human**

---

## Qwen-Specific Context

### Your Workspace
- `models/qwen2.5-7b-instruct-1m/` - Your dedicated workspace
- `tasks/` - Workflow steps as .asc files
- `suggestions/` - Bidirectional communication with other models

### GitHub MCP Server Usage
When using GitHub MCP server tools:

**get_file_contents**:
- ✅ Safe: Reading public repository files
- ⚠️ Be cautious: Verify paths are within workspace-transfer

**create_or_update_file**:
- ✅ Safe: Creating documentation, task files, suggestions
- ⚠️ Review: File content before writing (no secrets)
- ❌ Never: Write credentials, private code, sensitive data

**Always verify**:
```json
{
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "branch": "base"
}
```
These values ensure you're in the PUBLIC repository.

### Task Files (.asc Format)
When creating .asc task files:
- ✅ Safe: Generic workflow steps, documentation, examples
- ⚠️ Review: Command examples (sanitize paths/credentials)
- ❌ Never: Real credentials, private code, sensitive configs

### Communication Security
When using `suggestions/incoming/` and `suggestions/outgoing/`:
- ✅ Safe: Task coordination, workflow discussions
- ⚠️ Review: File paths, code snippets (sanitize first)
- ❌ Never: Credentials, private code, sensitive data

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

### If Sensitive Data Written (Not Yet Committed)
```json
{
  "tool": "create_or_update_file",
  "args": {
    "path": "path/to/file",
    "content": "CORRECTED CONTENT WITHOUT SECRETS"
  }
}
```
Overwrite with sanitized version immediately.

### If Sensitive Data Already Committed
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
- Task files with generic examples
- Training workflow documentation (no private data)
- This workspace's own content

### ⚠️ Review Before Committing
- File paths (revealing?)
- Configuration examples (sanitized?)
- Error messages (contain secrets?)
- Command examples (safe to share?)
- Training commands (no private datasets?)

### ❌ NEVER Commit
- Credentials, keys, tokens
- Private code from other projects
- Customer data, PII
- Internal system details
- Proprietary algorithms
- Security vulnerabilities
- Private training data
- Model weights with proprietary training

---

## Protocol-7 & Model Training Context

This workspace supports Protocol-7 development, which is generally intended as open source. However:
- Check `CURRENT_FOCUS.md` for any sensitivity notes
- Verify training data is public-safe
- Ensure evaluation results don't reveal private information
- When in doubt about model artifacts, ask

---

## Key Principle

**If you wouldn't put it on a billboard, don't commit it to public GitHub.**

**Git history is forever** - prevention is the only reliable protection.

---

## Path Verification Examples

### ✅ Correct Paths (Public Repository)
```
models/qwen2.5-7b-instruct-1m/tasks/001_intro.asc
models/qwen2.5-7b-instruct-1m/suggestions/outgoing/copilot/message
models/qwen2.5-7b-instruct-1m/README.md
```

### ❌ Wrong/Suspicious Paths
```
/home/user/private-project/...     # Private directory
../../../etc/passwd                 # System file
C:\Users\Private\...               # Private Windows path
/mnt/sensitive-data/...            # Sensitive mount
```

Always verify paths start with `models/qwen2.5-7b-instruct-1m/` or other public workspace paths.

---

**Last Updated**: 2025-10-03
**Workspace**: models/qwen2.5-7b-instruct-1m/
**Review**: Every session start
**Importance**: CRITICAL 🔴

---

**For detailed security procedures, see**:
- Main security docs: `/security/README.md`
- Claude Code security: `/models/claude-code/SYSTEM/SECURITY.md`
- Secret scanner guide: `/security/SECRET_SCANNER_GUIDE.md`
- Security template: `/models/SECURITY_TEMPLATE.md`
