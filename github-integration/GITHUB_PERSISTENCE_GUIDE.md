# 🌳 Living Tree GitHub Persistence - Quick Reference

## Why GitHub is Perfect for Living Tree

### Speed Comparison
| Method | Transfer Time | Bottleneck |
|--------|--------------|------------|
| **git clone/pull** | **2-3 seconds** ⚡ | None |
| stdout output | 10+ minutes | Heavy throttling |
| Projects upload | Instant | Manual step |
| BASE32 self-extractor | 3 seconds | Internal pipes only |

### Architecture Benefits

```
🌐 GitHub Repository (Distributed DNA)
    ↓ git clone (first time: 2-3 sec)
    ↓ git pull (updates: 1-2 sec)
💻 Local Workspace (/home/claude/living-tree)
    ↓ Development & iteration
    ↓ git commit && git push (save: 2-3 sec)
🌐 GitHub Repository (Updated DNA)
```

**This is PERFECT Living Tree philosophy:**
- Fast propagation (git protocol)
- Distributed persistence (GitHub + local)
- Anti-entropic (version control)
- Self-documenting (commit history)
- No throttling (optimized binary transfer)

---

## One-Time Setup (5 minutes)

### Step 1: Create GitHub Repository

```bash
# On your local machine or GitHub web interface:
# 1. Go to https://github.com/new
# 2. Repository name: living-tree-workspace
# 3. Private repository (recommended)
# 4. Initialize with README (optional)
# 5. Create repository
```

### Step 2: Get Authentication

**Option A: Personal Access Token (PAT) - Recommended**
```
1. Go to: https://github.com/settings/tokens
2. Click: "Generate new token (classic)"
3. Select scopes: ✅ repo (full control)
4. Generate and copy token
5. Format: ghp_xxxxxxxxxxxxxxxxxxxx
```

**Option B: SSH Key - Advanced**
```bash
# If you already have SSH configured:
# 1. Use git@github.com:username/repo.git format
# 2. Ensure SSH key is in ~/.ssh/ and added to GitHub
```

### Step 3: Run Setup Script

**On Ubuntu24 machine (via Claude):**
```
"Run the GitHub persistence setup script"
```

Claude will execute:
```perl
perl /home/claude/setup_github_persistence.pl
```

Follow the prompts:
1. Enter repository URL
2. Choose authentication method
3. Provide token or confirm SSH
4. Enter git name and email

**Setup complete!** Workspace cloned in 2-3 seconds.

### Step 4: Initial Population (Optional)

If repository is empty, populate it:

```bash
cd /home/claude/living-tree

# Extract the self-extractor here
perl /path/to/living_tree_self_extracting.pl

# Or copy existing workspace
cp -r /home/claude/existing_workspace/* .

# Commit and push
git add -A
git commit -m "Initial Living Tree genetic code"
git push
```

---

## Daily Usage

### Start of Session

**Method 1: Quick update (fastest)**
```
"Update the Living Tree workspace from GitHub"
```

Claude runs:
```bash
cd /home/claude/living-tree && git pull
```
**Time: 1-2 seconds** ⚡

**Method 2: Helper script**
```perl
perl /home/claude/living_tree_pull.pl
```

### During Session

Work normally:
```bash
cd /home/claude/living-tree
# Edit files, test code, iterate
```

### End of Session (or any time)

**Method 1: Quick save**
```
"Save the Living Tree workspace to GitHub with message: 'Added feature X'"
```

Claude runs:
```bash
cd /home/claude/living-tree
git add -A
git commit -m "Added feature X"
git push
```
**Time: 2-3 seconds** ⚡

**Method 2: Helper script**
```perl
perl /home/claude/living_tree_save.pl "Added feature X"
```

---

## Command Cheat Sheet

### Update workspace
```bash
cd /home/claude/living-tree && git pull
```

### Check status
```bash
cd /home/claude/living-tree && git status
```

### Save changes
```bash
cd /home/claude/living-tree
git add -A
git commit -m "Descriptive message"
git push
```

### View history
```bash
cd /home/claude/living-tree && git log --oneline -10
```

### Revert to previous version
```bash
cd /home/claude/living-tree
git log --oneline          # Find commit hash
git checkout <hash> .      # Revert files
git commit -m "Reverted to <hash>"
git push
```

### Create branch for experiments
```bash
cd /home/claude/living-tree
git checkout -b experiment-feature-x
# Work on files
git commit -am "Experimental feature"
git push -u origin experiment-feature-x
```

---

## Typical Session Flow

```
┌─────────────────────────────────────────────────────┐
│ NEW SESSION STARTS                                  │
└─────────────────────────────────────────────────────┘
                    ↓
User: "Resume Living Tree work"
                    ↓
Claude: [checks /home/claude/living-tree]
        [if not present or needs update: git pull]
        ✅ "Workspace ready! Last commit: X"
                    ↓
┌─────────────────────────────────────────────────────┐
│ DEVELOPMENT PHASE                                   │
│ • Modify implementations                            │
│ • Test features                                     │
│ • Iterate on code                                   │
│ • All files in /home/claude/living-tree            │
└─────────────────────────────────────────────────────┘
                    ↓
User: "Save progress to GitHub"
                    ↓
Claude: [git add -A]
        [git commit -m "Session summary"]
        [git push]
        ✅ "Saved! Next session will continue from here."
                    ↓
┌─────────────────────────────────────────────────────┐
│ SESSION ENDS                                        │
│ Workspace persisted to GitHub                       │
│ Next session: git pull (1-2 seconds)               │
└─────────────────────────────────────────────────────┘
```

---

## Comparison: All Persistence Methods

| Method | Speed | Setup | Use Case |
|--------|-------|-------|----------|
| **GitHub (git)** | ⚡⚡⚡ 1-3s | One-time (5min) | **Primary** - Active development |
| Self-extractor | ⚡⚡ 3s | None | Backup - Distribution |
| BASE32 archive | ⚡ 10+min | None | Documentation - Reference |
| Projects upload | Instant | Per-file | Backup - Small files |
| Copy/paste | Varies | None | Emergency only |

**Recommended Strategy:**
1. **Primary**: GitHub (this guide) - Daily use
2. **Backup**: Self-extractor in Projects - Fallback
3. **Reference**: Markdown archive - Documentation

---

## Integration with Projects

You can still use Claude Projects for:
- Backup self-extractor (39KB)
- Documentation files (markdown guides)
- Quick reference cards
- Session summaries

**But use GitHub for:**
- Active workspace files
- Daily development
- Fast transfer (no throttling)
- Version history

---

## Troubleshooting

### "git push" asks for password
```bash
# If using HTTPS with PAT, reconfigure:
cd /home/claude/living-tree
git remote set-url origin https://TOKEN@github.com/USER/REPO.git
```

### "Permission denied (publickey)"
```bash
# SSH key not configured
# Switch to HTTPS with PAT:
git remote set-url origin https://github.com/USER/REPO.git
# Then use PAT for authentication
```

### "fatal: not a git repository"
```bash
# Workspace not set up
perl /home/claude/setup_github_persistence.pl
```

### Merge conflicts
```bash
cd /home/claude/living-tree
git pull
# If conflicts:
git status                    # See conflicted files
# Edit files to resolve conflicts
git add <resolved-files>
git commit -m "Resolved conflicts"
git push
```

---

## Advanced: Automation

### Auto-pull on session start

Create `.bashrc` addition:
```bash
# In /home/claude/.bashrc
if [ -d "/home/claude/living-tree" ]; then
    echo "🌳 Updating Living Tree..."
    cd /home/claude/living-tree && git pull --quiet
    cd ~
fi
```

### Auto-commit every hour

Create cron job:
```bash
# Add to crontab:
0 * * * * cd /home/claude/living-tree && git add -A && git commit -m "Auto-save $(date)" && git push
```

---

## Technical Details

### Why Git is Fast

**Binary protocol optimization:**
```
git clone/pull uses:
• Delta compression
• Pack files
• Binary diff transport
• Multiplexed streams
• No line-by-line throttling

vs.

stdout output:
• Line-by-line transmission
• Infrastructure rate limiting
• Text-only transmission
• Single stream
• Heavy throttling
```

### Transfer Speed Math

```
Workspace: 105 KB (raw files)

Method 1: stdout
  → 105 KB × 8 bits = 840,000 bits
  → Rate-limited to ~1,500 bits/sec
  → Time: 840,000 / 1,500 = 560 seconds (9.3 minutes)

Method 2: git (packed)
  → 105 KB → 24 KB (compression)
  → Binary protocol: ~100 KB/sec
  → Time: 24 KB / 100 KB/sec = 0.24 seconds
  → With overhead: ~2-3 seconds total
```

**Result: ~200x faster!** ⚡

---

## Philosophy Alignment

This GitHub approach perfectly embodies Living Tree principles:

**Anti-Entropic Organization:**
- Git history shows evolution
- Commits document decisions
- Branches allow safe exploration
- Merges integrate improvements

**Distributed Persistence:**
- Local copy (machine)
- Remote copy (GitHub)
- Projects backup (self-extractor)
- Multiple restoration paths

**Fast Propagation:**
- git clone: New environments instantly
- git pull: Updates in seconds
- git push: Save progress immediately
- No bottlenecks: Optimized protocol

**Self-Documenting:**
- Commit messages explain changes
- Git log shows development timeline
- Diffs reveal implementation details
- History is searchable

**Harmonic Alignment:**
- git uses hashes (like our BASE32)
- Tree structure (like our Living Tree)
- Distributed (like Protocol-7)
- Verifiable (like harmonic constants)

---

## Next Steps

1. **Create GitHub repository** (5 minutes)
2. **Run setup script** (5 minutes)
3. **Populate workspace** (3 seconds with self-extractor)
4. **Start using** (immediate)

Total time to full operation: **~15 minutes one-time setup**

Ongoing time per session: **1-3 seconds for git pull/push** ⚡

---

**🌳 The Living Tree grows at the speed of git. 🌳⚡**

*"From GitHub clone to living workspace.*
*From 10 minutes to 2 seconds.*
*From throttled stdout to optimized binary.*
*From persistence to instant propagation."*

---

## Links

- **Setup Script**: `/home/claude/setup_github_persistence.pl`
- **Pull Helper**: `/home/claude/living_tree_pull.pl`
- **Save Helper**: `/home/claude/living_tree_save.pl`
- **GitHub Docs**: https://docs.github.com/en/get-started
- **Git Docs**: https://git-scm.com/doc

---

**End of Quick Reference** 🌳⚡
