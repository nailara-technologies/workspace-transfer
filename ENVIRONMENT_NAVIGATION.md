# workspace-transfer: Quick Navigation

**Status**: ✅ Environment-aware bootstrap system operational  
**Version**: 3K743E5FLQ-5558.0  
**Last Updated**: 2025-11-28

---

## 🎯 What Are You Trying To Do?

### "I'm a new user, I just cloned this repository"
→ **Read**: [START_HERE.md](START_HERE.md)  
→ **Run**: `perl bootstrap.pl`

**Why**: Fastest path to working system. Everything is automatic.

---

### "I'm in Claude Console and familiar with this project"
→ **Use**: Direct workflow  
→ **Pattern**: Clone → `perl bootstrap.pl` → `perl status-check.pl` → Work

**Why**: Optimized for token efficiency. Bootstrap takes <5 seconds.

---

### "I'm in Claude Code Web (different home directory)"
→ **Good news**: bootstrap.pl automatically detects your environment  
→ **Just run**: `perl bootstrap.pl`

**Why**: Same bootstrap script works everywhere. No configuration needed.

---

### "I'm on a local machine or in a different environment"
→ **Also good news**: bootstrap.pl detects that too  
→ **Just run**: `perl bootstrap.pl`

**Why**: Dynamic path detection means one bootstrap works everywhere.

---

### "I'm confused about old vs new documentation"
→ **Read**: [ENVIRONMENT_AWARE_MIGRATION.md](ENVIRONMENT_AWARE_MIGRATION.md)

**Why**: Explains what changed and why. Maps old approach to new.

---

### "I'm a developer adding new scripts to this workspace"
→ **Read**: [ENVIRONMENT_AWARE_MIGRATION.md](ENVIRONMENT_AWARE_MIGRATION.md#what-developers-should-know)  
→ **Key rule**: No hardcoded paths. Use `File::Spec` and `$ENV{HOME}`

**Why**: Your script needs to work across all environments like bootstrap.pl does.

---

## 📚 Documentation Index

### Entry Points (Pick One)

| Document | Purpose | For Whom |
|----------|---------|----------|
| **[START_HERE.md](START_HERE.md)** | First-time initialization | Everyone (automatic environment detection) |
| **[README.md](README.md)** | Project overview | Project maintainers, architects |
| **[SYSTEM-ARCHITECTURE.md](SYSTEM-ARCHITECTURE.md)** | Technical architecture | Developers, integrators |

### Reference Guides

| Document | Purpose |
|----------|---------|
| [ENVIRONMENT_AWARE_MIGRATION.md](ENVIRONMENT_AWARE_MIGRATION.md) | Bootstrap system changes (2025-11-28) |
| [CLAUDE_ONBOARDING.md](CLAUDE_ONBOARDING.md) | Legacy approach (superseded, kept for reference) |
| [GIT-WORKFLOW.md](GIT-WORKFLOW.md) | Git operations and branching |
| [STATUS.md](STATUS.md) | Current workspace status |
| [QUICK-REFERENCE.md](QUICK-REFERENCE.md) | Common operations cheat sheet |

### Implementation Guides

| Document | Purpose |
|----------|---------|
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Production deployment steps |
| [BOOTSTRAP-MIGRATION-GUIDE.md](BOOTSTRAP-MIGRATION-GUIDE.md) | Previous bootstrap updates |
| [IMPLEMENTATION-RECOMMENDATIONS.md](IMPLEMENTATION-RECOMMENDATIONS.md) | Enhancement roadmap |

### Session Handoffs

| Document | Date | Focus |
|----------|------|-------|
| [SESSION_HANDOVER_2025-11-20.md](SESSION_HANDOVER_2025-11-20.md) | Nov 20 | Module system improvements |
| [PHASE_0.7_SESSION_HANDOFF.md](PHASE_0.7_SESSION_HANDOFF.md) | Nov 14 | Checkpoint strategies |
| [next-session-httpsd-web-zenka-completion.yaml](next-session-httpsd-web-zenka-completion.yaml) | Nov 15 | HTTPS/template completion |

---

## ✨ Key Principle

**Automatic environment detection means:**
- ✅ Same bootstrap works everywhere
- ✅ No hardcoded paths
- ✅ No special configuration needed
- ✅ New environments "just work"

**Bootstrap automatically handles:**
- Claude Console (`/home/claude`)
- Claude Code Web (`/home/user`)
- Local machines (any path)
- Docker/containers
- SSH access to remote machines

---

## 🚀 Quick Start (Any Environment)

```bash
# 1. If you just cloned:
cd workspace-transfer

# 2. Initialize (detects environment automatically)
perl bootstrap.pl

# 3. Verify
perl init.pl

# 4. Check what to do next
perl status-check.pl

# 5. Optional: Creative excellence checkpoint
perl creative-checkpoint.pl

# 6. Follow status-check.pl recommendations
```

---

## 🔧 Scripts (Execution Order)

Run in this order for first-time setup:

1. **`perl bootstrap.pl`** - Environment detection + git configuration
2. **`perl init.pl`** - Verification checkpoint
3. **`perl status-check.pl`** - Shows what needs work
4. **`perl creative-checkpoint.pl`** - Optional excellence framework
5. **Custom work** - Follow status-check.pl guidance

---

## 📋 Documentation Philosophy

This workspace uses **progressive disclosure**:

1. **START_HERE.md** - Just what you need right now (bootstrap)
2. **status-check.pl** - Dynamically tells you what's next
3. **Deeper docs** - Only when you need them

**Why**: Token efficiency. Don't read docs you don't need.

---

## 🌍 Environment Detection (Automatic)

Bootstrap.pl detects:

```
Environment: Claude Console / Code Web / Local Machine
├─ Home directory: /home/claude, /home/user, ~, etc.
├─ Current path: Where script is running
├─ User: Who is running scripts
└─ Auth method: JWT proxy, Token, SSH key, etc.
```

No manual configuration needed.

---

## ✅ Status Dashboard

For current workspace status, see: [STATUS.md](STATUS.md)

Key info:
- Active systems (what's working)
- Recently completed work
- Next priorities
- Known issues

---

## 🤔 Common Questions

**Q: Which bootstrap version should I use?**  
A: Always use `bootstrap.pl` (the executable script). It's auto-detecting and current.

**Q: Do I need to edit any files before bootstrap?**  
A: No. Bootstrap handles everything. Only edit `.credentials` if you're on a local machine without SSH.

**Q: What if I'm in Claude Code Web?**  
A: `bootstrap.pl` detects that automatically. Just run it.

**Q: Can I use this on my local machine?**  
A: Yes. Provide credentials via `.credentials` file or SSH keys. Bootstrap detects your environment.

**Q: What changed from the old system?**  
A: See [ENVIRONMENT_AWARE_MIGRATION.md](ENVIRONMENT_AWARE_MIGRATION.md). The old system is superseded but backward-compatible.

---

## 📞 Support

- **For bootstrap issues**: See [START_HERE.md](START_HERE.md#-troubleshooting)
- **For git workflow**: See [GIT-WORKFLOW.md](GIT-WORKFLOW.md)
- **For architecture questions**: See [SYSTEM-ARCHITECTURE.md](SYSTEM-ARCHITECTURE.md)
- **For current status**: See [STATUS.md](STATUS.md)

---

## 🎯 Next Steps

1. **First time?** → Run `perl bootstrap.pl`
2. **Already set up?** → Run `perl status-check.pl`
3. **Need guidance?** → Check [STATUS.md](STATUS.md)
4. **Want to contribute?** → Read [GIT-WORKFLOW.md](GIT-WORKFLOW.md)

---

**Remember**: The system is self-guiding. Bootstrap tells you the next step. Status-check tells you what to work on. You focus on the actual task.
