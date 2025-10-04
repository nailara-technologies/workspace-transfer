# Checkpoint Key Resolution - Quick Reference

**How Claude handles encryption keys automatically**

---

## 🔑 Key Resolution Priority

When Claude needs to encrypt/decrypt a checkpoint:

```
1. Conversation Context (explicit)
   ↓ if not found
2. Project Instructions (automatic)
   ↓ if not found
3. Ask User (fallback)
```

---

## ✅ Recommended Setup

**One-time setup in Claude Projects custom instructions:**

```
CHECKPOINT_KEY=your-secret-key-here
```

**Result:** All encryption/decryption works automatically in every session!

---

## 🔄 How It Works

**User says:** "Create an encrypted checkpoint"

**Claude does automatically:**
```bash
# 1. Sees CHECKPOINT_KEY in project instructions
# 2. Sets environment variable
export CHECKPOINT_KEY="your-secret-key-here"

# 3. Runs script (which checks environment)
perl scripts/encrypt-checkpoint.pl --input=checkpoint.md
```

**User doesn't need to:**
- ❌ Provide the key each time
- ❌ Remember to set environment variables
- ❌ Manually reference the key

---

## 🎯 Override Behavior

**When you need a different key:**

```
User: "Encrypt this with key ABC123"

Claude: [uses ABC123, ignores project default]
```

**Priority rule:** Conversation context > Project instructions

---

## 🔒 Security Benefits

- ✅ Key stored securely in Projects (not in code/commits)
- ✅ Transparent handling (no manual steps)
- ✅ Works across all sessions
- ✅ Can override when needed
- ✅ Fallback to asking if key missing

---

## 📝 Examples

### Normal Use (Automatic)
```
User: "Create checkpoint"
Claude: [creates checkpoint]

User: "Encrypt it"
Claude: [uses CHECKPOINT_KEY from instructions automatically]
       ✓ Encrypted

User: "Decrypt it"
Claude: [uses same key automatically]
       ✓ Decrypted
```

### With Override
```
User: "Encrypt with key TEMP123"
Claude: [uses TEMP123 instead of default]
       ✓ Encrypted with TEMP123

User: "Decrypt" 
Claude: [asks: which key? TEMP123 or default?]
User: "TEMP123"
Claude: ✓ Decrypted
```

### No Key Configured
```
User: "Encrypt checkpoint"
Claude: "I don't see CHECKPOINT_KEY in project instructions.
        Please provide the encryption key:"
User: "ABC123"
Claude: ✓ Encrypted with ABC123
```

---

## 🛠️ For Script Developers

**The Perl scripts check in this order:**

1. `--key` parameter (command line)
2. `--key-file` parameter (file path)
3. `$ENV{CHECKPOINT_KEY}` (environment variable)
4. Interactive prompt (stdin with hidden input)

**Claude's role:** Bridge between project instructions → environment variable

---

## ✨ Best Practice

**Setup:**
```
1. Add to Claude Projects custom instructions:
   CHECKPOINT_KEY=your-strong-key-here

2. Use encryption naturally:
   "Encrypt this checkpoint"
   "Decrypt last checkpoint"
   
3. That's it! Claude handles the rest automatically.
```

---

**Status**: Default behavior as of 2025-10-04  
**Benefit**: Zero-friction encrypted checkpoints

---

*"Set once in projects, use everywhere automatically."*
