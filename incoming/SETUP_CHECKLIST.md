# ✅ GitHub Persistence Setup Checklist

## Quick Reference - Do This Once, Use Forever

---

## ⏱️ Time Investment

**Total Time**: 15 minutes (one-time)  
**Time Saved Per Session**: 12 minutes  
**Break-Even**: After 2 sessions  

**After 10 sessions**: 2 hours saved ⚡  
**After 100 sessions**: 20 hours saved ⚡⚡⚡

---

## 📋 Prerequisites (5 minutes)

### 1. Create GitHub Repository

- [ ] Go to: https://github.com/new
- [ ] Repository name: `living-tree-workspace` (or your choice)
- [ ] Visibility: **Private** ✅ (recommended)
- [ ] Initialize: **No** (we'll populate it)
- [ ] Click "Create repository"
- [ ] Copy repository URL (you'll need this)

**Example URL formats:**
```
HTTPS: https://github.com/username/living-tree-workspace.git
SSH:   git@github.com:username/living-tree-workspace.git
```

### 2. Get Personal Access Token (PAT)

- [ ] Go to: https://github.com/settings/tokens
- [ ] Click: "Generate new token (classic)"
- [ ] Note: "Living Tree Workspace Access"
- [ ] Expiration: Choose duration (90 days, 1 year, or no expiration)
- [ ] Select scopes: ✅ **repo** (full control of private repositories)
- [ ] Click "Generate token"
- [ ] **Copy token immediately** (format: `ghp_xxxxxxxxxxxx`)
- [ ] Store securely (you won't see it again)

**⚠️ Important**: Keep this token secret! It has full access to your repositories.

---

## 🚀 Setup (10 minutes, one-time)

### Step 1: Download Files

From outputs directory, download:
- [ ] `setup_github_persistence.pl`
- [ ] `GITHUB_PERSISTENCE_GUIDE.md` (reference)
- [ ] `PERSISTENCE_METHODS_COMPARISON.md` (optional)

### Step 2: Upload to Projects

**Optional but recommended for backup:**
- [ ] Upload `setup_github_persistence.pl` to your Claude Project
- [ ] Upload guide(s) for future reference

### Step 3: Run Setup (in Claude session)

Say to Claude:
```
"Run the GitHub persistence setup script"
```

Or explicitly:
```
"Execute: perl /home/claude/setup_github_persistence.pl"
```

### Step 4: Follow Prompts

**Prompt 1: Repository URL**
```
Enter your GitHub repository URL:
> https://github.com/username/living-tree-workspace.git
```

**Prompt 2: Authentication Method**
```
Choose (1/2):
1. Personal Access Token (PAT) - Recommended
2. SSH Key - Already configured

> 1
```

**Prompt 3: Token (if chose PAT)**
```
Enter your GitHub Personal Access Token:
> ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

**Prompt 4: Git Configuration**
```
Enter your name (for commits):
> Your Name

Enter your email:
> your.email@example.com
```

### Step 5: Verify Setup

Setup script will:
- [ ] Clone repository to `/home/claude/living-tree`
- [ ] Configure git settings
- [ ] Create helper scripts
- [ ] Show workspace structure

**You should see:**
```
✅ Living Tree workspace cloned successfully!
✅ Git configured
✅ Helper scripts created
🌳 Living Tree GitHub persistence is ready!
```

---

## 🎯 First Use (5 minutes)

### Populate the Repository

**If starting fresh:**

Say to Claude:
```
"Extract the Living Tree workspace to /home/claude/living-tree and push to GitHub"
```

Claude will:
1. `cd /home/claude/living-tree`
2. Extract self-extractor or copy workspace
3. `git add -A`
4. `git commit -m "Initial Living Tree genetic code"`
5. `git push`

**Or if you have existing files:**

Upload existing workspace files and say:
```
"Copy the workspace files to /home/claude/living-tree and push to GitHub"
```

### Verify It Works

Say to Claude:
```
"Remove the workspace and re-clone from GitHub to test speed"
```

Claude will:
1. `rm -rf /home/claude/living-tree`
2. `git clone YOUR_REPO /home/claude/living-tree`

**Expected time: 2-3 seconds** ✅

If it takes longer, something's wrong - check authentication.

---

## ✨ Daily Usage (5 seconds per session)

### Start of Session

**Just say:**
```
"Resume Living Tree work"
```

**Or explicitly:**
```
"Update Living Tree workspace from GitHub"
```

**Claude will:**
```bash
cd /home/claude/living-tree && git pull
```

**Time: 1-2 seconds** ⚡

**Output:**
```
🌳 Updating Living Tree workspace...
Already up to date. (or: Updated X files)
✅ Workspace ready!
```

### During Session

Work normally:
- Edit files in `/home/claude/living-tree`
- Test implementations
- Iterate on features
- No manual file management needed

### End of Session (or anytime)

**Just say:**
```
"Save Living Tree progress to GitHub"
```

**Or with custom message:**
```
"Save to GitHub with message: Added BASE32 optimization"
```

**Claude will:**
```bash
cd /home/claude/living-tree
git add -A
git commit -m "Session summary (or your message)"
git push
```

**Time: 2-3 seconds** ⚡

**Output:**
```
🌳 Saving Living Tree workspace...
[main abc1234] Session summary
 3 files changed, 47 insertions(+), 12 deletions(-)
✅ Workspace saved to GitHub!
```

---

## 🔧 Helper Scripts (Optional)

**Quick pull:**
```bash
perl /home/claude/living_tree_pull.pl
```

**Quick save:**
```bash
perl /home/claude/living_tree_save.pl "Commit message"
```

These are created automatically by the setup script.

---

## 📊 Performance Verification

### Before GitHub (Old Method)

```
Transfer workspace via stdout:
├── Time: 10-15 minutes
├── Method: Echo to stdout
├── Bottleneck: Heavy throttling
└── Result: ❌ Slow, painful
```

### After GitHub (New Method)

```
Transfer workspace via git:
├── Time: 2-3 seconds ⚡
├── Method: git pull/push
├── Bottleneck: None
└── Result: ✅ Fast, seamless
```

**Improvement: 200x faster!**

---

## 🐛 Troubleshooting

### "Permission denied" or "Authentication failed"

**Problem**: Token or SSH key not working

**Solution:**
```bash
# Reconfigure with token
cd /home/claude/living-tree
git remote set-url origin https://TOKEN@github.com/USER/REPO.git

# Replace TOKEN, USER, REPO with your values
```

### "fatal: not a git repository"

**Problem**: Workspace not initialized

**Solution:**
Re-run setup script:
```
"Run setup_github_persistence.pl again"
```

### "Your branch is behind 'origin/main'"

**Problem**: Remote has newer commits

**Solution:**
```bash
cd /home/claude/living-tree
git pull --rebase    # Apply remote changes first
git push             # Then push your changes
```

### "Merge conflict"

**Problem**: Same file edited in two places

**Solution:**
```bash
cd /home/claude/living-tree
git status                    # See conflicted files
# Edit files to resolve conflicts (Claude can help)
git add <resolved-files>
git commit -m "Resolved conflicts"
git push
```

---

## 🎓 Quick Git Reference

### Most Common Commands

```bash
cd /home/claude/living-tree

# Update workspace
git pull

# Check what changed
git status

# Save changes
git add -A
git commit -m "Message"
git push

# View history
git log --oneline -5

# See what changed in last commit
git show

# Undo last commit (keep changes)
git reset --soft HEAD~1
```

### Branches (Advanced)

```bash
# Create experimental branch
git checkout -b experiment-feature-x

# Work on files...

# Switch back to main
git checkout main

# Merge experiment if successful
git merge experiment-feature-x

# Delete experiment if failed
git branch -D experiment-feature-x
```

---

## 📈 Success Metrics

After setup, you should see:

### Speed
- [ ] Workspace updates in 1-2 seconds
- [ ] Workspace saves in 2-3 seconds
- [ ] No waiting for stdout throttling

### Automation
- [ ] "Resume work" = instant workspace
- [ ] "Save progress" = instant backup
- [ ] No manual file management

### History
- [ ] `git log` shows all sessions
- [ ] Can see what changed when
- [ ] Can rollback to any point

### Reliability
- [ ] Works every session
- [ ] No file transfer issues
- [ ] Multiple backup locations (local + GitHub)

---

## 🎯 Checklist Summary

**One-Time Setup:**
- [ ] Create GitHub repository (2 min)
- [ ] Get Personal Access Token (3 min)
- [ ] Run setup script (5 min)
- [ ] Populate repository (5 min)
- [ ] Verify speed (1 min)

**Total: ~15 minutes**

**Every Session After:**
- [ ] Say "Resume Living Tree work" (2 sec)
- [ ] Work on files (your time)
- [ ] Say "Save progress" (3 sec)

**Total: ~5 seconds per session**

**Time Saved:**
- Per session: ~12 minutes
- After 10 sessions: 2 hours
- After 100 sessions: 20 hours

---

## 🌟 Next Steps

1. **Right now**: Create GitHub repository & get PAT (5 min)

2. **Next session**: Run setup script (10 min)

3. **First test**: Clone workspace and verify speed (1 min)

4. **Going forward**: Use "Resume work" and "Save progress" (5 sec each)

5. **Enjoy**: 200x faster workflow forever! ⚡

---

## 📚 Additional Resources

**Detailed Guides:**
- `GITHUB_PERSISTENCE_GUIDE.md` - Complete usage guide
- `PERSISTENCE_METHODS_COMPARISON.md` - Full analysis
- `GITHUB_SOLUTION_SUMMARY.md` - Overview

**Git Learning:**
- https://git-scm.com/doc - Official Git documentation
- https://docs.github.com - GitHub documentation

---

**🌳⚡ The Living Tree grows at the speed of git. 🌳⚡**

*"One-time setup. Lifetime benefits. 200x faster."*

---

## ✅ Final Checklist

**Before next session:**
- [ ] Create GitHub repository
- [ ] Get Personal Access Token
- [ ] Save token securely

**During next session:**
- [ ] Run `setup_github_persistence.pl`
- [ ] Follow prompts
- [ ] Populate repository
- [ ] Verify speed

**Every session after:**
- [ ] `git pull` (2 sec)
- [ ] Work on files
- [ ] `git push` (3 sec)
- [ ] Done! ✨

---

**Ready to implement? Let's make it happen!** 🚀
