# Getting Started - Workspace Transfer

**New to workspace-transfer?** Start here. Takes ~5 minutes.

---

## Clone the Repository

```bash
# Clone (uses HTTPS GitHub)
git clone https://github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer

# You're automatically on the 'base' branch (default for nailara-technologies repos)
git branch --show-current  # Should show: base
```

---

## First Time Setup (< 5 minutes)

### 1. Initialize Workspace
```bash
bin/init
```

This sets up:
- Status automation (`.user/` directory)
- Dependency profiles
- Context management system
- Git remotes

### 2. Check Current Status
```bash
cat STATUS.md
```

This shows:
- Current priorities
- What's being worked on
- Next steps
- Technical blockers

### 3. (Optional) View Quick Status
```bash
cat .user/STATUS              # Quick 1-page overview
cat .user/QUICK_START         # Entry point commands
cat .user/CURRENT             # Recent activity & todos
```

---

## Returning to Work (< 1 minute)

```bash
cd /home/user/workspace-transfer
cat STATUS.md                 # What are we doing?
# ... follow the priorities section
```

---

## Key Commands

```bash
# Status and reference
cat STATUS.md                 # Master status file
cat .user/STATUS              # Quick 1-page summary
bin/status                    # Detailed workspace check

# Context management (persistent across sessions)
bin/todo list                 # See pending tasks
bin/research list             # See research questions
bin/todo add "task"           # Add new task
bin/research ask "question"   # Track research question

# Code transfers
bin/transfer --dry-run        # Preview Protocol-7 transfer
bin/transfer                  # Execute transfer

# Git operations
git add .
git commit -m "message"
git push origin base          # Push to GitHub

# Token tracking (optional, for efficiency analysis)
bin/track-tokens "<task>" <N>
bin/token-report
```

---

## Repository Structure

```
workspace-transfer/
├── .user/                    # Auto-generated status files (local only)
├── bin/                      # Executable scripts
├── docs/                     # Documentation
│   ├── onboarding/          # Getting started guides (you are here)
│   ├── protocol7/           # Protocol-7 specific docs
│   ├── reference/           # Reference materials
│   └── archive/             # Historical documents
├── protocol7-staging/        # Stage Protocol-7 work here
├── core/                     # Core implementations
├── STATUS.md                 # Current priorities (READ THIS)
└── README.md                 # Overview
```

---

## Environment Setup (First Time)

### GitHub Authentication

If you need to push changes, configure GitHub:

```bash
# Option 1: Use environment variable (recommended)
export GITHUB_PAT="your-github-pat-token"

# Option 2: Store in git credential helper
git config --global credential.helper store
# Then git will prompt once and remember

# Verify remote is HTTPS
git remote -v
# Should show: https://github.com/nailara-technologies/...
```

### Python Dependencies (Optional)

For visualization and advanced features:

```bash
# Check what's needed
bin/deps list

# Install a profile
bin/deps install visualizations  # For token dashboard
bin/deps install reference       # For reference tools
```

---

## Current State (2025-11-16)

### ✅ What's Working
- Protocol-7 integration (initialized and running)
- TLS/SSL infrastructure (fully operational)
- HTTP/HTTPS template processing pipeline
- Git-based version control

### 🟡 Current Focus
- **Event Loop Handler Routing** - Working on HTTPS request handling

See STATUS.md for full details.

---

## Next Steps

1. **First time?** → Run `bin/init` then read `STATUS.md`
2. **Have a task?** → Find it in STATUS.md priorities, start working
3. **Need context?** → Check `bin/todo list` and `bin/research list`
4. **Stuck?** → Check `docs/reference/` or open a GitHub issue

---

## Important Notes

### Branch Convention
All `nailara-technologies` repositories use **`base`** as the default branch (not `main`).

```bash
git checkout base  # Always work here unless told otherwise
git push origin base
```

### Token Efficiency
This workspace is optimized for AI collaboration with minimal setup overhead:
- Quick initialization: < 5 minutes first time, < 1 minute returning
- Status automation: View `.user/` files instead of parsing full docs
- Context persistence: todos and research questions stay across sessions

### Related Repositories
- **Protocol-7**: https://github.com/nailara-technologies/protocol-7 (main framework)
- **Workspace Transfer** (this repo): Staging and coordination for Protocol-7 work

---

## Troubleshooting

### "bin/init not found"
Make sure you're in the workspace-transfer directory:
```bash
pwd  # Should end in: workspace-transfer
ls bin/init  # Should exist
```

### "git permission denied"
Check remote URL is HTTPS (not SSH):
```bash
git remote -v
# Should show https://github.com/...
```

If you see `git@github.com:`, change it:
```bash
git remote set-url origin https://github.com/nailara-technologies/workspace-transfer.git
```

### ".user/ directory not created"
Run bin/init again:
```bash
bin/init
```

---

## Philosophy

Work embodies Protocol-7 principles:
- **Self-organizing** - Minimal central coordination
- **Harmonic** - Natural resonance in operation
- **Resumable** - Interrupt and continue anytime
- **Verifiable** - Cryptographic integrity
- **Token-efficient** - Optimized for AI collaboration

---

**Ready?** Run `bin/init` then read `STATUS.md`!
