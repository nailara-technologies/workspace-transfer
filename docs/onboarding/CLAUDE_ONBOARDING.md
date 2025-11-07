# Claude AI - Workspace Onboarding (OPTIMIZED + SECURE)

## ⚡ INSTANT START

### First Time Setup (< 30 seconds)

```bash
# Step 1: Clone repository (with your token)
cd /home/claude
git clone https://workspace-transfer:YOUR_GITHUB_TOKEN@github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer

# Step 2: Set up credentials (one-time only)
cp .credentials.template .credentials
# Edit .credentials and add your actual token (file is gitignored)

# Step 3: Bootstrap
perl bootstrap.pl

# Step 4: Status Check
perl status-check.pl
```

### Returning Sessions (< 5 seconds)

```bash
cd /home/claude/workspace-transfer
perl bootstrap.pl && perl status-check.pl
```

**The status check will tell you exactly what to do next.**

---

## 🔑 Git Credentials - SECURE APPROACH

### Using .credentials File (Recommended)

1. Copy the template:
   ```bash
   cp .credentials.template .credentials
   ```

2. Edit `.credentials` with your actual token:
   ```bash
   GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
   GITHUB_USER=workspace-transfer
   GITHUB_EMAIL=workspace-transfer@taeki.v7.ax
   ```

3. The `.credentials` file is **gitignored** and will NEVER be committed

### Using Environment Variables (Alternative)

```bash
export GITHUB_TOKEN=ghp_YOUR_ACTUAL_TOKEN_HERE
export GITHUB_USER=workspace-transfer
export GITHUB_EMAIL=workspace-transfer@taeki.v7.ax
perl bootstrap.pl
```

### Security Notes

- ✅ Tokens are NEVER committed to git
- ✅ `.credentials` is in `.gitignore`
- ✅ Bootstrap reads from file or environment
- ✅ GitHub push protection enabled
- ⚠️ Current active token: Contact repository owner for access

---

## 📋 Workspace Reference

### Directory Structure
```
/home/claude/workspace-transfer/    # This repository (managed via Git)
/home/claude/work/                  # External repos, builds, experiments
/mnt/user-data/outputs/             # Generated reports and artifacts
```

### Key Scripts
- `bootstrap.pl` - One-time workspace setup
- `init.pl` - Verify initialization status
- `status-check.pl` - Show current workspace status and next steps
- `commit_checkpoint.pl` - Create git checkpoint with timestamp
- `creative-checkpoint.pl` - Quality elevation prompt

### Active Work
See `CURRENT_FOCUS.md` for current development priorities.

For completed missions and historical work, see `archive/`.

---
