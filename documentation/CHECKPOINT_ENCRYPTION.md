# Checkpoint Encryption - Quick Reference

**Phase 0.5**: Secure checkpoint storage with Twofish encryption  
**Status**: ✅ Implemented  
**Priority**: 🔴 CRITICAL for production use

---

## ⚠️ Why Encryption?

**Problem**: Checkpoints may contain sensitive data:
- API keys, tokens, credentials
- Private repository information
- Confidential project details
- Internal architecture secrets

**Danger**: workspace-transfer is PUBLIC on GitHub
- All commits visible to everyone
- Unencrypted checkpoints = exposed secrets
- Cannot be fully deleted from git history

**Solution**: Encrypt before committing!

---

## 🔒 Quick Start

### 1. Create Encrypted Checkpoint

```bash
# Export checkpoint (unencrypted)
perl scripts/export-context-checkpoint.pl --session-name=my-work

# Encrypt it
perl scripts/encrypt-checkpoint.pl --input=context-checkpoints/CHECKPOINT_*.md

# Result: CHECKPOINT_*.enc (safe to commit!)
```

### 2. Use Encrypted Checkpoint

```bash
# Session startup auto-detects encrypted checkpoints
perl scripts/session-startup.pl

# Or decrypt manually
perl scripts/decrypt-checkpoint.pl --input=checkpoint.enc
```

---

## 🛡️ Encryption Details

**Algorithm**: Twofish-256  
**Mode**: CBC (Cipher Block Chaining)  
**Encoding**: BASE32 (text-safe, git-friendly)  
**Key Derivation**: SHA-256 from passphrase

**File Format**:
```
# ENCRYPTED CHECKPOINT
# Algorithm: Twofish-256 (CBC mode)
# Encoding: BASE32

---BEGIN ENCRYPTED CHECKPOINT---
<BASE32 encoded ciphertext>
---END ENCRYPTED CHECKPOINT---
```

---

## 🔑 Key Management

### How Keys Are Resolved

**When Claude runs encryption/decryption scripts, keys are resolved in this priority order:**

1. **Explicit key in conversation context** (highest priority)
   - User says: "Use key ABC123 for this checkpoint"
   - Claude uses ABC123 for that specific operation

2. **Key in Project custom instructions** (automatic)
   - If `CHECKPOINT_KEY=...` present in project instructions
   - Claude automatically sets: `export CHECKPOINT_KEY="..."`
   - **No user action required** - happens transparently

3. **Ask user** (fallback)
   - If no key in context or instructions
   - Claude prompts: "Please provide decryption key"
   - User can provide key or key file location

**This means:**
- ✅ Set key once in Project instructions → Works automatically in all sessions
- ✅ Override with different key in chat → Uses specified key instead
- ✅ No key anywhere → Claude asks (secure fallback)

### Key Sources (Perl Script Priority Order)

**Note:** The Perl scripts themselves check these sources. Claude bridges between project instructions and environment variables automatically.

1. **--key-file** (recommended for local work)
   ```bash
   echo "my-secret-key" > .checkpoint-key
   perl scripts/encrypt-checkpoint.pl --input=checkpoint.md --key-file=.checkpoint-key
   ```

2. **CHECKPOINT_KEY environment variable** (auto-set by Claude)
   ```bash
   export CHECKPOINT_KEY="my-secret-key"
   perl scripts/encrypt-checkpoint.pl --input=checkpoint.md
   ```

3. **Interactive prompt** (manual fallback)
   ```bash
   perl scripts/encrypt-checkpoint.pl --input=checkpoint.md
   # Prompts for key (no echo)
   ```

### Storage Recommendations

**Best**: Claude Projects custom instructions
- Add key to Projects custom instructions: `CHECKPOINT_KEY=your-key-here`
- Claude automatically uses it in all sessions
- Not visible in code/commits
- **Recommended workflow**: Set once, works everywhere

**Good**: Local .checkpoint-key file
- Keep in .gitignore
- Never commit this file!
- Share securely with team
- Useful for local development

**Acceptable**: Environment variable
- Set in ~/.bashrc or session
- Not persisted in git
- Easy to use locally

**Avoid**: --key parameter
- Visible in process list (ps aux)
- Logged in shell history
- Security risk

---

## 📋 Common Workflows

### With Claude Projects (Recommended - Automatic)

**Setup once in Projects custom instructions:**
```
CHECKPOINT_KEY=7AW00I004BQT4
```

**Then use naturally in conversations:**

```
User: "Create an encrypted checkpoint for today's work"

Claude: [automatically uses CHECKPOINT_KEY from instructions]
  export CHECKPOINT_KEY="7AW00I004BQT4"
  perl scripts/export-context-checkpoint.pl --session-name=daily-work
  perl scripts/encrypt-checkpoint.pl --input=context-checkpoints/CHECKPOINT_*_daily-work.md
  ✓ Checkpoint encrypted

User: "Decrypt that checkpoint"

Claude: [automatically uses same key]
  export CHECKPOINT_KEY="7AW00I004BQT4"
  perl scripts/decrypt-checkpoint.pl --input=context-checkpoints/CHECKPOINT_*_daily-work.enc
  ✓ Checkpoint decrypted
```

**Benefits:**
- ✅ No manual key management needed
- ✅ Works across all sessions automatically
- ✅ Claude handles environment variable bridging
- ✅ Secure (key not exposed in chat or commits)

### Override Key for Specific Use

**If you need a different key for one checkpoint:**

```
User: "Encrypt this with key ABC123 instead"

Claude: [uses specified key, not default]
  export CHECKPOINT_KEY="ABC123"
  perl scripts/encrypt-checkpoint.pl --input=checkpoint.md
```

**The conversation context takes priority over project instructions.**

### Daily Work Checkpoint

```bash
# End of day - create and encrypt
perl scripts/export-context-checkpoint.pl --session-name=daily-work
perl scripts/encrypt-checkpoint.pl \
  --input=context-checkpoints/CHECKPOINT_*_daily-work.md \
  --key-file=.checkpoint-key

# Commit encrypted version
git add context-checkpoints/*.enc
git commit -m "Daily checkpoint (encrypted)"
git push

# Next day - session startup auto-restores
perl scripts/session-startup.pl
```

### Feature Work with Encryption

```bash
# Start feature - set key once
export CHECKPOINT_KEY="my-project-key"

# During work - create checkpoints as usual
perl scripts/export-context-checkpoint.pl --session-name=feature-x

# Encrypt when done
perl scripts/encrypt-checkpoint.pl --input=context-checkpoints/CHECKPOINT_*_feature-x.md

# Cleanup - remove unencrypted
rm context-checkpoints/CHECKPOINT_*_feature-x.md

# Commit only encrypted
git add context-checkpoints/*.enc
git commit -m "Feature X checkpoint (encrypted)"
```

### Team Collaboration

```bash
# Team member creates encrypted checkpoint
perl scripts/export-context-checkpoint.pl --session-name=team-handoff
perl scripts/encrypt-checkpoint.pl \
  --input=context-checkpoints/CHECKPOINT_*_team-handoff.md \
  --key-file=.team-checkpoint-key

# Commit encrypted checkpoint
git add context-checkpoints/*.enc
git commit -m "Team handoff checkpoint"
git push

# Other team member pulls and decrypts
git pull
perl scripts/decrypt-checkpoint.pl \
  --input=context-checkpoints/CHECKPOINT_*_team-handoff.enc \
  --key-file=.team-checkpoint-key
```

---

## 🚀 Session Startup with Auto-Restore

### Interactive Selection

```bash
perl scripts/session-startup.pl

# Output:
# 📋 Found 5 checkpoint(s)
# 
# Named Sessions:
#   1. elf-work (latest: 2025-10-04 14:30:22)
#   2. feature-x (latest: 2025-10-04 12:15:00)
# 
# Recent Unnamed:
#   3. 2025-10-04 10:00:00
# 
# Options:
#   [number] - Restore specific checkpoint
#   [l]ist   - List all checkpoints
#   [s]kip   - Continue without restoring
#   [q]uit   - Exit
# 
# Select option: 1
```

**Features**:
- Auto-detects both encrypted and unencrypted
- Groups by session name
- Shows recent unnamed checkpoints
- Decrypts automatically (prompts for key if needed)
- Displays full checkpoint content

---

## ⚡ Integration Tips

### With export-context-checkpoint.pl

**Option 1**: Export then encrypt separately
```bash
perl scripts/export-context-checkpoint.pl --session-name=work
perl scripts/encrypt-checkpoint.pl --input=context-checkpoints/CHECKPOINT_*_work.md
```

**Option 2**: Add --encrypt flag (future enhancement)
```bash
# Not yet implemented - TODO
perl scripts/export-context-checkpoint.pl --session-name=work --encrypt
```

### With Git Workflow

**Automated encryption on commit** (future git hook):
```bash
# .git/hooks/pre-commit (future)
#!/bin/bash
for file in context-checkpoints/*.md; do
  if [[ ! "$file" =~ EXAMPLE ]]; then
    perl scripts/encrypt-checkpoint.pl --input="$file"
    git add "${file%.md}.enc"
  fi
done
```

---

## 🔒 Security Best Practices

### DO:
✅ Encrypt all checkpoints with sensitive data  
✅ Use strong, unique keys  
✅ Store keys in Projects environment  
✅ Keep .checkpoint-key in .gitignore  
✅ Use --key-file or environment variables  
✅ Commit only .enc files to git  
✅ Delete unencrypted .md after encrypting

### DON'T:
❌ Commit unencrypted checkpoints with secrets  
❌ Use weak or guessable keys  
❌ Commit .checkpoint-key file  
❌ Use --key parameter (visible in ps)  
❌ Share keys in public channels  
❌ Reuse keys across projects  
❌ Leave decrypted files in git staging

---

## 🔍 Troubleshooting

### Decryption fails / wrong key

**Symptom**: "Error: Decryption failed (wrong key or corrupted file)"  
**Cause**: Using different key than encryption  
**Solution**: Verify key is correct, try key file or env var

### Checkpoint not auto-detected

**Symptom**: session-startup.pl doesn't find checkpoint  
**Cause**: Wrong directory or file extension  
**Solution**: 
- Check `context-checkpoints/` directory exists
- Verify filename: `CHECKPOINT_YYYYMMDD_HHMMSS[_name].{md,enc}`
- Run `ls context-checkpoints/` to verify

### Key not found in Projects

**Symptom**: Prompt for key despite having Projects setup  
**Cause**: Key not in custom instructions  
**Solution**: Add to Projects custom instructions:
```
CHECKPOINT_KEY=your-secret-key-here
```

---

## 📊 File Types

| Extension | Description | Git Safe? | Auto-Decrypt? |
|-----------|-------------|-----------|---------------|
| .md | Unencrypted checkpoint | ❌ NO | N/A |
| .enc | Encrypted checkpoint | ✅ YES | ✅ YES |
| *EXAMPLE*.md | Example/template | ✅ YES | N/A |

**.gitignore rules**:
```gitignore
context-checkpoints/*.md              # Block unencrypted
!context-checkpoints/.gitkeep         # Allow readme
!context-checkpoints/*EXAMPLE*.md     # Allow examples
!context-checkpoints/*.enc            # Allow encrypted
```

---

## 🎯 Next Steps: C25519 Public Key

**Phase 0.6** (planned):
- Asymmetric encryption with Curve25519
- Public key in repository (safe to commit)
- Private key in secure storage only
- Team members encrypt with public key
- Only you can decrypt with private key

**Benefits**:
- No shared secret needed
- Each user has own keypair
- Forward secrecy
- Audit trail (who encrypted what)

---

**Status**: ✅ Phase 0.5 complete  
**Security**: 🔒 Twofish-256 encryption ready  
**Next**: 🚀 Use it now for safe checkpoint storage!

---

*"Encrypt state, commit safely, restore securely."*
