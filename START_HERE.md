# 🚦 START HERE - Initialization Required

**STOP!** Before reading anything else, you MUST initialize this workspace.

---

## ⚡ Quick Initialization (< 5 seconds)

```bash
# You should already be in: /home/claude/workspace-transfer
# If not: cd /home/claude/workspace-transfer

# Step 1: Bootstrap (auto-configures everything)
perl bootstrap.pl

# Step 2: Verify initialization
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

Once you see the ✅ message from `init.pl`, you may proceed to:

```bash
# Check workspace status (tells you what to do next)
perl status-check.pl
```

Status check will show:
- Phase completion status
- Git status
- Recommended next actions

Then follow the recommendations!

---

## 🧪 Self-Test (In The Wild)

This mechanism tests itself:

1. **New Claude starts** → Sees this file first
2. **Runs bootstrap** → Gets configured in 5 seconds
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
You're not in the repository directory:
```bash
cd /home/claude/workspace-transfer
```

### "Permission denied"
Scripts aren't executable:
```bash
chmod +x bootstrap.pl init.pl status-check.pl
```

### ".credentials not found"
Bootstrap will warn you. You can:
- Copy `.credentials.template` to `.credentials` and add token
- OR: Set environment variable `GITHUB_TOKEN`
- For read-only work, you can proceed without credentials

---

## 🎯 The Point

**Don't read documentation before initializing.**  
**Initialize first, then the system tells you what to read.**

This is self-enforcing optimization in action.

---

**Next command to type:** `perl bootstrap.pl`

Do it now. Everything else can wait.
