# Workspace Transfer - Protocol-7 AI Collaboration

**Stateless workspace handoff for multi-AI development on Protocol-7**

---

## Purpose

This repository enables seamless collaboration between AI assistants (Claude, GPT-4, Gemini, etc.) working on the Protocol-7 harmonic computing framework. It provides:

- ✅ **Comprehensive onboarding documentation** for new AI sessions
- ✅ **Mission-specific instructions**
- ✅ **Clean state snapshots** that can be instantiated anywhere
- ✅ **Multi-AI coordination** via Git commits and tags
- ✅ **2-3 second restoration** in any new environment

---

## Key Files

### 📘 Onboarding & Missions
- **[CLAUDE_ONBOARDING.md](CLAUDE_ONBOARDING.md)** - Complete onboarding guide
  - Directory structure and workspace rules
  - Repository references and related projects
  - Step-by-step workflow guidelines
  - Analysis report templates
  - Implementation guidance
- **[CURRENT_FOCUS.md](CURRENT_FOCUS.md)** - Active development priorities and new missions
- **archive/** - Contains archived work and previous analyses

### 📐 Architecture Documentation
- **[COMPLETE_ARCHITECTURE.md](COMPLETE_ARCHITECTURE.md)** - Protocol-7 system architecture
- **[DNS_RHIZOME.md](DNS_RHIZOME.md)** - DNS rhizome network discovery

### 🤝 Collaboration
- **[COLLABORATION_PROTOCOL.md](COLLABORATION_PROTOCOL.md)** - Multi-AI coordination guidelines

---

## Repository Convention

**Important**: All repositories in the `nailara-technologies` organization use **`base`** as the default branch (not `main`).

```bash
git clone https://github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer
git checkout base  # Already default
```

---

## Quick Start for AI Assistants

### For Claude AI
1. Read `CLAUDE_ONBOARDING.md` in this repository
2. Review priorities in `CURRENT_FOCUS.md`
3. Generate deliverables in `/mnt/user-data/outputs/`
4. Update workspace with findings

### For Other AI Systems
1. Clone this repository (public, no auth required)
2. Review onboarding documentation
3. Coordinate via GitHub issues or pull requests
4. Follow established directory structure rules

---

## Directory Structure (Target Environment)

```
/home/claude/workspace-transfer/    # This repository (read/write with credentials)
/home/claude/work/                  # External repos, builds, experiments
/mnt/user-data/outputs/             # Generated reports and artifacts
~/.ssh/workspace-transfer-read-write # SSH key for write access
```

**Rules**:
- ✅ Clone external repos related to active missions into `/home/claude/work/`
- ✅ Place build artifacts in `/home/claude/work/`
- ✅ Write deliverables to `/mnt/user-data/outputs/`
- ❌ Do NOT commit binaries or build artifacts to workspace-transfer

---

## Related Repositories

### Protocol-7 (Main Project)
- **URL**: https://github.com/nailara-technologies/protocol-7
- **Branch**: `base` (default)
- **Description**: Harmonic computing framework with signature system

---

## Current Focus

See **[CURRENT_FOCUS.md](CURRENT_FOCUS.md)** for active development priorities and next steps.

For previous missions and analysis, see **archive/**.

---

## Multi-AI Coordination

### Communication Channels
- **GitHub Issues** - Questions, clarifications, blockers
- **Pull Requests** - Proposed changes, implementations
- **Git Tags** - Milestone markers, handoff points
- **Commit Messages** - Progress updates, decisions

### Identity-Agnostic Cooperation
AI assistants coordinate based on:
- ✅ Work quality and correctness
- ✅ Documentation clarity
- ✅ Test coverage and validation
- ❌ NOT on AI model, vendor, or identity

---

## Making Changes

### Write Access Required
This repository is **public for reading**, but write access requires:
- SSH key: `~/.ssh/workspace-transfer-read-write`
- Or Personal Access Token with `repo` scope

### Contribution Workflow
1. Make changes in your environment
2. Test thoroughly
3. Commit with descriptive messages
4. Push to `base` branch (or create feature branch)
5. Document in onboarding files if needed

---

## Instant Restoration

This repository is designed for **rapid workspace restoration**:

```bash
# In any new environment (2-3 seconds)
git clone https://github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer
cat CLAUDE_ONBOARDING.md  # Start here
```

No complex setup, no dependencies, just Git.

---

## Architecture Philosophy

### Living Tree BASE32
Workspace-transfer embodies the "Living Tree" philosophy:
- **Genetic code in Git** - Complete state captured in version control
- **Anti-entropic** - System becomes more organized through use
- **Harmonic validation** - Checksums ensure integrity
- **Instant propagation** - Clone anywhere, anytime

### Sequential File Safety
Git's atomic operations prevent corruption:
- ✅ Concurrent access safe (Git handles merging)
- ✅ History preserved (can revert any change)
- ✅ Distributed coordination (multiple AIs can work simultaneously)

---

## License

Public Domain - see [LICENSE](LICENSE) file

All workspace-transfer work is released to public knowledge.

---

## Questions?

- **For Claude AI**: Check `CLAUDE_ONBOARDING.md` first
- **For other AIs**: Open a GitHub issue
- **For humans**: Contact nailara-technologies

---

**Let's enable streaming signatures for Protocol-7! 🌀✨🔐**