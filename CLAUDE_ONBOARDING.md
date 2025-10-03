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

## 📋 Detailed Phase Documentation (Reference)

### Phase 0: Extract and Analyze Historical Workspace Archives

**STATUS: ✅ COMPLETED (October 2, 2025)**

Archives (files 20-39) were extracted and analyzed. Results available in:
- `other/archive-inventory-report.md` (155 files analyzed, 20 identical to repo)

**Note**: No action needed for new sessions - this phase is complete.

**Once Phase 0 is complete, proceed to Phase 1 (BMW Analysis).**

---

## Phase 1: BMW Analysis (If Applicable)

Reference the specific BMW work if resuming that project.

---
