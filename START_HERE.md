# 🚦 START HERE - Initialization Required

**STOP!** Before reading anything else, you MUST initialize this workspace.

Works on: Claude Console • Claude Code Web • Local machines

---

## ⚡ Quick Initialization (< 5 seconds)

```bash
# Step 1: Navigate to workspace-transfer directory
# If you just cloned:
#   cd workspace-transfer
# If it already exists:
#   cd ~/workspace-transfer  (or wherever you cloned it)

# Step 2: Bootstrap (auto-configures everything)
perl bootstrap.pl

# Step 3: Verify initialization
perl init.pl
```

**Expected output:**
```
✅ Already initialized - you may proceed
```

---

## 🛑 Why This Matters

### Problem:
Reading documentation before initialization **wastes tokens** on setup information you won't need after bootstrapping.

### Solution:
Bootstrap creates `.initialized` marker → unlocks full documentation access → you start with clean token budget for actual work.

### Analogy:
Don't read the assembly manual while the car is being assembled by the factory. Wait for the "ready" signal, then drive.

---

## ✅ After Initialization

Once you see the ✅ message from `init.pl`, proceed through the quality gates:

```bash
# Step 1: Check workspace status
perl status-check.pl

# Step 2: Creative excellence checkpoint (IMPORTANT)
perl creative-checkpoint.pl
```

**The creative checkpoint** elevates your thinking before work begins:
- ✨ Raises quality from "nice to have" to "standard"
- 🌀 Encourages Protocol-7 integration awareness
- 🚀 Highlights compound efficiency principles
- 💎 Sets expectation for excellence

**After the checkpoint**, follow the recommendations from status-check.pl!

---

## 🧪 Self-Test (In The Wild)

This mechanism tests itself across all environments:

1. **New Claude starts** → Sees this file first
2. **Runs bootstrap** → Gets configured in 5 seconds (detects environment)
3. **Runs init.pl** → Gets green light
4. **Runs status-check** → Gets told what to do
5. **Follows instructions** → Actually works on task

**Token efficiency:**
- ❌ Old way: 80 seconds setup + reading all docs = ~5,000 tokens wasted
- ✅ New way: 5 seconds setup + targeted reading = ~500 tokens used

**Savings: 90% of setup overhead eliminated**

---

## 📋 If You're Already Initialized

Already ran bootstrap? Just verify:

```bash
perl init.pl
# Should show: ✅ Already initialized
```

Then proceed directly to:
```bash
perl status-check.pl
# Follow the recommendations shown
```

---

## 🔧 Troubleshooting

### "Cannot find bootstrap.pl"
You're not in the repository directory. Find it first:
```bash
# If you just cloned:
cd workspace-transfer

# If it exists elsewhere:
cd ~/workspace-transfer
ls -la bootstrap.pl  # verify file exists
```

### "Permission denied"
Scripts aren't executable:
```bash
chmod +x bootstrap.pl init.pl status-check.pl
```

### ".credentials not found"
Bootstrap will guide you. Choose the best method for your environment:

**Claude Console / Claude Code Web:**
- ✅ Automatic - Uses Anthropic JWT proxy (no action needed)

**Local Machine:**
- Option 1: Create `.credentials` file (see `.credentials.template`)
- Option 2: Set `GITHUB_TOKEN` environment variable
- Option 3: Use SSH keys (git should auto-detect)

For read-only work, you can proceed without credentials.

---

## 🌍 Environment Detection

Bootstrap automatically detects which environment you're in:

- **Claude Console**: `/home/claude` (full automatic setup)
- **Claude Code Web**: `/home/user` (full automatic setup)
- **Local Machine**: Any path (uses SSH or provided credentials)

All paths are resolved dynamically. No need to hardcode anything.

---

## 🎯 The Point

**Don't read documentation before initializing.**  
**Initialize first, then the system tells you what to read.**

This is self-enforcing optimization in action.

---

**Next command to type:** `perl bootstrap.pl`

Do it now. Everything else can wait.
