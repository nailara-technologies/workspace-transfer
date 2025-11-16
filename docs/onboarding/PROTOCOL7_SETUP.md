# Protocol-7 Repository Setup

**Need to work on the Protocol-7 framework itself?** Start here.

---

## Repository Relationship

```
workspace-transfer (this repo)
  └─ Staging area for Protocol-7 work
  └─ Documentation & coordination
  └─ Transfers completed work to...

     protocol-7 (main framework repo)
       └─ Actual Protocol-7 implementation
       └─ Where transferred code lives
       └─ Source of truth for framework
```

**Typical workflow:**
1. Clone **workspace-transfer** (for documentation & staging)
2. Clone **protocol-7** (the actual framework)
3. Develop in workspace-transfer/protocol7-staging/
4. Transfer completed work to protocol-7
5. Commit in protocol-7, push to GitHub

---

## Quick Setup

### Clone Both Repositories

```bash
# Create a directory for your work
mkdir ~/protocol-7-work
cd ~/protocol-7-work

# Clone workspace-transfer (documentation & staging area)
git clone https://github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer

# Clone protocol-7 (main framework - in separate directory)
cd ..
git clone https://github.com/nailara-technologies/protocol-7.git
cd protocol-7

# Both repos use 'base' branch (not 'main')
git branch --show-current  # Should show: base
```

### Directory Structure After Cloning

```
~/protocol-7-work/
├── workspace-transfer/          # Documentation & staging
│   ├── STATUS.md               # Current priorities
│   ├── protocol7-staging/      # Stage work here before transfer
│   ├── docs/                   # All documentation
│   └── bin/                    # Utility scripts
│
└── protocol-7/                 # Main framework (source of truth)
    ├── modules/                # Protocol-7 modules (your work goes here)
    ├── bin/                    # Protocol-7 executables
    ├── docs/                   # Protocol-7 documentation
    └── tests/                  # Test suite
```

---

## Important: Order of Cloning

**RECOMMENDED:**
1. Clone **workspace-transfer** first → Read STATUS.md → Understand what needs doing
2. Then clone **protocol-7** → Make changes based on workspace-transfer priorities

**NOT RECOMMENDED:**
1. Cloning protocol-7 first → Getting lost in 7,000+ lines of Perl
2. Not reading workspace-transfer/STATUS.md → No context for your work

---

## Branch Convention

⚠️ **IMPORTANT**: Both repositories use **`base`** as the default branch, NOT `main`

```bash
cd protocol-7
git branch --show-current     # Should show: base

# Never work on 'main' - it doesn't exist
# If you see it, you're in the wrong repo
```

---

## First Time: Verify Both Repos Work

### Test workspace-transfer
```bash
cd workspace-transfer
cat STATUS.md           # Should show current priorities
bin/init                # Initialize workspace
```

### Install Dependencies (First Time Only)
```bash
cd protocol-7

# Install minimal dependencies required by Protocol-7
bash bin/dependencies/install_minimal_dependencies.debian.sh

# This installs Perl modules and system packages
# Takes 2-5 minutes depending on internet connection
```

### Test protocol-7
```bash
cd protocol-7
./bin/Protocol-7 v7 -B -v   # Start Protocol-7 (may take 30-40 seconds)
# If successful, you'll see initialization messages
# Press Ctrl+C when done testing
```

---

## Git Credentials (HTTPS)

⚠️ **IMPORTANT**: Both repos require HTTPS authentication with GitHub Personal Access Token (PAT).

### Why HTTPS with PAT?
- **Direct access to GitHub.com**: These repositories are on github.com, not locally hosted
- **Full feature access**: With GITHUB_PAT, you get full push/pull/fetch permissions
- **Seamless cloning**: Larger codebases (protocol-7 has 5,000+ files) clone smoothly with PAT authentication
- **No SSH key needed**: PAT-based HTTPS works in all environments

### Setup Once
```bash
# Set GitHub PAT in environment (REQUIRED for cloning/pushing)
export GITHUB_PAT="ghp_your_actual_token_here"

# Verify it's set
echo $GITHUB_PAT  # Should show your token (starts with ghp_)
```

**Creating a PAT if you don't have one:**
1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it `repo` scope (full control of private/public repos)
4. Copy the token and store it: `export GITHUB_PAT="ghp_..."`

### Automatic Remote Configuration
When you clone with `$GITHUB_PAT` in your environment, remotes are automatically set to HTTPS:

```bash
cd workspace-transfer
git remote -v  # Shows: https://github.com/nailara-technologies/workspace-transfer.git

cd ../protocol-7
git remote -v  # Shows: https://github.com/nailara-technologies/protocol-7.git
```

Both will use your GITHUB_PAT automatically for operations (token is embedded in URL during this session).

### Managing Remote URLs

⚠️ **Note**: Remote URLs sometimes reset to local proxy addresses. If you encounter this:

```bash
# In workspace-transfer repository
bin/configure-remote

# Or push with automatic reconfiguration (recommended)
bin/push-to-github base

# In protocol-7 repository (if needed)
bin/dev/configure-remote
bin/dev/push-to-github base
```

See `workspace-transfer/docs/reference/REMOTE_URL_CONFIGURATION.md` for detailed instructions and troubleshooting.

---

## Understanding the Workflow

### Development Workflow

```
1. Read workspace-transfer/STATUS.md
   ↓
2. Work on protocol-7 (modify files in protocol-7/modules/)
   ↓
3. Test changes in protocol-7
   ↓
4. Commit in protocol-7
   ↓
5. Push to protocol-7 GitHub
   ↓
6. Update workspace-transfer with notes/documentation
   ↓
7. Commit in workspace-transfer
   ↓
8. Push to workspace-transfer GitHub
```

### OR Use Staging (For Complex Work)

```
1. Read workspace-transfer/STATUS.md
   ↓
2. Create work in workspace-transfer/protocol7-staging/
   ↓
3. Use bin/transfer to move to protocol-7
   ↓
4. Commit in protocol-7
   ↓
5. Push to protocol-7 GitHub
```

See: `workspace-transfer/docs/protocol7/TRANSFER_WORKFLOW.md` for details

---

## Current Protocol-7 Status

Check what's running:

```bash
cd protocol-7

# Check if any processes are running
ps aux | grep runsc | grep -v grep

# See recent commits
git log --oneline -5

# Check current branch
git branch --show-current

# View latest status documentation
cat docs/SESSION_STATUS*.md 2>/dev/null | head -50
```

---

## Key Directories in protocol-7

```
protocol-7/
├── modules/              # All Perl modules (where work happens)
│   ├── *.init_code       # Initialization code
│   ├── base.*            # Core framework
│   ├── io.*              # Socket/IO handling
│   ├── net.*             # Network protocols
│   ├── protocol.*        # Protocol implementations
│   └── httpsd.*          # HTTPS server
├── bin/                  # Executables
│   ├── Protocol-7        # Main runtime
│   ├── p7               # Client
│   └── transfer         # Transfer from staging
├── docs/                # Documentation
│   ├── SESSION_STATUS_* # Session notes
│   └── ANALYSIS_*       # Analysis documents
├── tests/               # Test suite
└── .git/                # Git repository
```

---

## Common Tasks

### Just Want to Read Code?
```bash
cd protocol-7/modules
ls -la                    # Browse all modules
grep -r "function_name" . # Search for something
cat base.handler.read     # Read a specific module
```

### Want to Modify Code?
```bash
cd protocol-7
git checkout base                    # Ensure on base branch
git pull origin base                 # Get latest
# Edit files in modules/
git add modules/my-changes.pl
git commit -m "description"
git push origin base
```

### Need to Understand Current Status?
```bash
cat workspace-transfer/STATUS.md     # High-level status
cat protocol-7/docs/SESSION_STATUS_*.md  # Detailed status
ls protocol-7/docs/                 # See all documentation
```

---

## Troubleshooting

### "Permission denied when pushing"
Check authentication:
```bash
git remote -v
# Should show: https://github.com/... (not git@github.com:)

# If it's SSH, change to HTTPS:
git remote set-url origin https://github.com/nailara-technologies/protocol-7.git

# Or use the automatic reconfiguration script (workspace-transfer):
bin/configure-remote
bin/push-to-github base

# Or in protocol-7:
bin/dev/configure-remote
bin/dev/push-to-github base
```

See `docs/reference/REMOTE_URL_CONFIGURATION.md` for more details on handling persistent remote URL issues.

### "Not on base branch"
```bash
git branch --show-current
# If not 'base', switch:
git checkout base
```

### "Protocol-7 won't start"
```bash
cd protocol-7
./bin/Protocol-7 v7 -B -v
# Look for error messages
# Common: dependencies missing, port in use, permissions
```

### "Can't find workspace-transfer"
```bash
pwd  # Where are you?
# You should be in ~/protocol-7-work/workspace-transfer
# Or wherever you cloned it
```

---

## Next Steps

1. **Clone both repos** (follow Quick Setup above)
2. **Read workspace-transfer/STATUS.md** (understand priorities)
3. **Verify protocol-7 starts** (check setup works)
4. **Find your task** in STATUS.md
5. **Edit protocol-7/modules/** as needed
6. **Commit and push** when done

---

## More Information

- **Transfer workflow**: `workspace-transfer/docs/protocol7/TRANSFER_WORKFLOW.md`
- **Protocol-7 architecture**: `protocol-7/docs/` (various analysis and status documents)
- **Current priorities**: `workspace-transfer/STATUS.md`
- **Issues/questions**: Open GitHub issues in either repository

---

**Still confused?** Open an issue in workspace-transfer: https://github.com/nailara-technologies/workspace-transfer/issues
