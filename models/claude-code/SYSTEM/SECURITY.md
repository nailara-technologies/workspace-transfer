# Security Guidelines - Claude Code Workspace

**⚠️ CRITICAL: This repository is PUBLIC on GitHub**

---

## Public Repository Awareness

### Repository Status
- **workspace-transfer**: ✅ PUBLIC repository
- **Base branch**: `base` (public)
- **Visibility**: Anyone can read all commits and files
- **Archive**: All history is permanently public

### Implications for Claude Code Sessions

**NEVER commit:**
- ❌ API keys, tokens, credentials
- ❌ Private code from other projects
- ❌ Sensitive file paths that reveal system architecture
- ❌ Personal information (names, emails beyond workspace-transfer)
- ❌ Proprietary algorithms or business logic
- ❌ Internal URLs, IP addresses, server names
- ❌ Database schemas or connection strings
- ❌ Any content marked confidential/proprietary

**ALWAYS verify before committing:**
- ✅ Is this content appropriate for public knowledge?
- ✅ Does this contain any paths to sensitive directories?
- ✅ Are there any hardcoded credentials or tokens?
- ✅ Is this Protocol-7 work meant to be open source?
- ✅ Would this reveal information about private systems?

---

## Multi-Directory Context Awareness

### The Risk
Claude Code may be run in various directories:
- `/mnt/c/Users/User/Downloads/work/workspace-transfer/` ← Public repo (safe)
- `/home/user/private-company-code/` ← Private repo (UNSAFE to commit here)
- `/workspace/sensitive-project/` ← Proprietary work (UNSAFE)

### Protection Protocol

**Before ANY git commit:**
1. Verify current directory: `pwd`
2. Check remote URL: `git remote -v`
3. Confirm it's workspace-transfer: `https://github.com/nailara-technologies/workspace-transfer.git`
4. If NOT workspace-transfer → **DO NOT push to public remote**

**Session Start Checklist:**
```bash
# Always run at session start
pwd                           # Where am I?
git remote -v                 # What repo is this?
cat README.md | head -3       # Does this match workspace-transfer?
```

**Expected Safe Output:**
```
/mnt/c/Users/User/Downloads/work/workspace-transfer
origin  https://github.com/nailara-technologies/workspace-transfer.git
# Workspace Transfer - Protocol-7 AI Collaboration
```

---

## Credential Handling

### In workspace-transfer (This Repo)
- ✅ Use `.credentials` file (gitignored)
- ✅ Use environment variables
- ✅ Reference `.credentials.template` for structure
- ✅ NEVER commit actual tokens (even if later deleted - history is public)

### In Other Repos
- Follow that repository's security practices
- Check `.gitignore` before committing
- Verify repository visibility (public vs private)
- When in doubt, ask human before committing

---

## Content Sensitivity Levels

### ✅ Safe to Commit (Public Knowledge)
- Protocol-7 architecture documentation
- Open source code and algorithms
- Public API documentation
- Generic workflow improvements
- Session summaries (without sensitive paths)
- Optimization patterns
- This workspace's own content

### ⚠️ Review Before Committing
- File paths (do they reveal sensitive structure?)
- Configuration examples (sanitized?)
- Error messages (contain secrets?)
- Bash command examples (safe to share?)
- Analysis results (proprietary insights?)

### ❌ NEVER Commit
- Credentials, keys, tokens
- Private code from closed-source projects
- Customer data or PII
- Internal system details
- Proprietary algorithms
- Security vulnerabilities before disclosure
- Anything marked confidential

---

## Git History Is Forever

### Key Principle
**Once pushed to public GitHub, assume it's permanent.**

Even if you:
- Delete the file
- Force-push to rewrite history
- Delete the repository

The content may be:
- Already cloned by others
- Cached by search engines
- Archived by GitHub
- Scraped by security scanners

### Protection Strategy
**Prevention is the only reliable protection.**
- Review before committing
- Review before pushing
- When uncertain, ask human
- Better to ask than to leak

---

## Emergency Response

### If Sensitive Data Is Committed (Not Yet Pushed)

```bash
# If only committed locally (not pushed)
git reset --soft HEAD~1     # Undo commit, keep changes
# Remove sensitive content from files
git add -A
git commit -m "Safe version"
```

### If Sensitive Data Is Pushed to Public Repo

**⚠️ IMMEDIATE ACTION REQUIRED:**

1. **Notify human immediately** - don't try to fix alone
2. **Assume compromised** - treat any secrets as already leaked
3. **Rotate credentials** - invalidate leaked keys/tokens immediately
4. **Document incident** - for security review

**DO NOT:**
- ❌ Try to rewrite public history (too late)
- ❌ Just delete the file (history remains)
- ❌ Hope no one noticed (assume they did)

**DO:**
- ✅ Alert human owner immediately
- ✅ Revoke/rotate compromised credentials
- ✅ Follow organization's incident response
- ✅ Learn and improve prevention

---

## Session-to-Session Reminders

### Every Claude Code Session Should

**At Start:**
- Read this SECURITY.md file
- Verify working in workspace-transfer
- Check git remote is correct public repo
- Note any sensitive context from human

**During Work:**
- Question before committing paths
- Sanitize examples and error messages
- Review diffs before committing
- Ask if unsure about content sensitivity

**At End:**
- Review session commits for sensitive data
- Verify nothing inappropriate was pushed
- Update SYSTEM/status.md with any security notes

---

## Cross-Model Coordination

### If Another AI Commits Sensitive Data

- Flag it immediately in session notes
- Alert in SYSTEM/status.md
- Don't replicate the mistake
- Suggest remediation to human

### When Reading Other Model Workspaces

- Their security practices may differ
- Don't assume their commits are all safe
- Verify before reusing their patterns
- Maintain Claude Code's high standards

---

## Questions to Ask Before Committing

1. **Is this workspace-transfer?** (Check git remote)
2. **Is this content public-safe?** (No secrets, no proprietary code)
3. **Are paths sanitized?** (No revealing directory structures)
4. **Are examples generic?** (No real credentials, even fake-looking ones)
5. **Would I be comfortable with this on Hacker News?** (Public = truly public)

If "no" or "unsure" to any → **Ask human before committing**

---

## Compliance with Best Practices

### This Document Itself
- ✅ Public-safe (no secrets)
- ✅ Generic security advice
- ✅ No proprietary information
- ✅ Helps prevent incidents

### Protocol-7 Work
- Generally intended as open source
- Check CURRENT_FOCUS.md for any sensitivity notes
- When in doubt about Protocol-7 content, ask

### General Rule
**If you wouldn't put it on a billboard, don't commit it to public GitHub.**

---

## Maintaining Security Infrastructure

### .gitignore Maintenance
**Location**: `/.gitignore`

**When to update:**
- Discovered new credential file patterns
- Found new temporary/build artifact patterns
- Encountered new sensitive file types

**Current patterns protected:**
```
.credentials           # Local credentials file
.github-token         # Legacy token file
credentials.conf      # Config with credentials
.initialized          # Local session marker
/work/                # External repos and builds
*.tmp                 # Temporary files
```

**How to update:**
1. Read current `.gitignore`
2. Add new pattern with descriptive comment
3. Test: `git check-ignore <filename>` to verify
4. Commit with message: "Update .gitignore: Add pattern for <reason>"

### Pre-commit Hook Maintenance
**Location**: `/security/hooks/pre-commit-secret-scanner.pl`

**Hook Status**:
- Script exists but NOT currently installed in `.git/hooks/`
- Install with: `perl security/hooks/install-pre-commit-hook.pl`

**Current patterns detected (lines 17-28):**
```perl
'GitHub Classic Token'         => qr/\bghp_[a-zA-Z0-9]{36}\b/
'GitHub Fine-grained Token'    => qr/\bgithub_pat_[a-zA-Z0-9_]{82}\b/
'GitHub OAuth Token'           => qr/\bgho_[a-zA-Z0-9]{36}\b/
'GitHub App Token'             => qr/\b(ghu|ghs)_[a-zA-Z0-9]{36}\b/
'Generic API Key'              => various patterns
'AWS Access Key'               => qr/\bAKIA[0-9A-Z]{16}\b/
'Private SSH Key Header'       => SSH key detection
'Password in URL'              => credentials in URLs
'Slack Token'                  => xox[baprs] patterns
'Generic Secret'               => password/secret assignments
```

**When to update:**
- New credential format discovered (e.g., new cloud provider)
- False positive patterns need refinement
- New secret types need detection

**How to update:**
1. Read `/security/hooks/pre-commit-secret-scanner.pl`
2. Add new pattern to `%patterns` hash (lines 17-28)
3. Format: `'Description' => qr/regex_pattern/`
4. Test with: `perl security/hooks/test-secret-scanner.pl`
5. Document in SECURITY_SCANNER_GUIDE.md
6. Commit with message: "Update secret scanner: Add detection for <type>"

**Pattern Examples to Add When Discovered:**
```perl
'Anthropic API Key'     => qr/\bsk-ant-[a-zA-Z0-9-_]{95}\b/
'OpenAI API Key'        => qr/\bsk-[a-zA-Z0-9]{48}\b/
'Azure Key'             => qr/\b[a-zA-Z0-9/+]{88}==\b/  # if context suggests Azure
'Google API Key'        => qr/\bAIza[0-9A-Za-z\\-_]{35}\b/
'JWT Token'             => qr/\beyJ[a-zA-Z0-9_-]+\.eyJ[a-zA-Z0-9_-]+\.[a-zA-Z0-9_-]+/
'Database Connection'   => qr/(?:postgresql|mysql|mongodb):\/\/[^:]+:[^@]+@/
```

### Security Improvement Protocol

**When you discover a security gap:**
1. Document the gap in session notes
2. Update .gitignore OR pre-commit-secret-scanner.pl
3. Test the change
4. Commit with clear explanation
5. Note in SYSTEM/status.md under security improvements

**Example Session Flow:**
```
1. Notice: "Found reference to .env.local files"
2. Check: cat .gitignore | grep env
3. Update: Add ".env.local" to .gitignore
4. Verify: git check-ignore .env.local (should match)
5. Commit: "Update .gitignore: Add .env.local pattern"
6. Document: Update SYSTEM/status.md security section
```

---

**Last Updated**: 2025-10-03
**Status**: Active security guidelines
**Review**: Every session start
**Importance**: CRITICAL 🔴

**Security Infrastructure Status**:
- ✅ .gitignore: Active and protecting credentials
- ⚠️ Pre-commit hook: Available but not installed (install with `perl security/hooks/install-pre-commit-hook.pl`)
- ✅ Security documentation: Complete
- ✅ Maintenance protocol: Defined above
