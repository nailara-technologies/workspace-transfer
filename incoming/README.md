# Workspace Transfer - Protocol-7 AI Collaboration

**Stateless workspace handoff for multi-AI development on Protocol-7**

---

## Purpose

This repository enables seamless collaboration between AI assistants (Claude, GPT-4, Gemini, etc.) working on the Protocol-7 harmonic computing framework. It provides:

- ✅ **Comprehensive onboarding documentation** for new AI sessions
- ✅ **Mission-specific instructions** (current: BMW Resumability Analysis)
- ✅ **Clean state snapshots** that can be instantiated anywhere
- ✅ **Multi-AI coordination** via Git commits and tags
- ✅ **2-3 second restoration** in any new environment

---

## Key Files

### 📘 Onboarding & Missions
- **[CLAUDE_ONBOARDING.md](CLAUDE_ONBOARDING.md)** - Complete BMW resumability analysis guide
  - Directory structure and workspace rules
  - Repository references (workspace-transfer, protocol-7, digest-bmw)
  - Step-by-step testing workflow with Perl scripts
  - Analysis report templates
  - Implementation guidance for missing features

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
2. Follow Phase 1-5 instructions for BMW analysis
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
- ✅ Clone external repos (digest-bmw, protocol-7) into `/home/claude/work/`
- ✅ Place build artifacts in `/home/claude/work/`
- ✅ Write deliverables to `/mnt/user-data/outputs/`
- ❌ Do NOT commit binaries or build artifacts to workspace-transfer

---

## Related Repositories

### Protocol-7 (Main Project)
- **URL**: https://github.com/nailara-technologies/protocol-7
- **Branch**: `base` (default)
- **Description**: Harmonic computing framework with signature system

### Digest::BMW (External Dependency)
- **URL**: https://github.com/gray/digest-bmw
- **Description**: Perl interface to BMW384 hash algorithm
- **Current Task**: Verify resumability support (clone/getstate/setstate)

---

## Current Mission: BMW Resumability Analysis

**Objective**: Determine if Digest::BMW supports state save/restore for streaming signatures.

**Context**: Protocol-7 uses BMW384 checksums for cryptographic signatures. ELF7 checksums are already resumable, but BMW needs verification.

**Deliverables**:
1. `bmw-test-results.txt` - Test execution output
2. `bmw-analysis-report.md` - Findings and recommendations
3. `bmw-state-serialization.patch` - Implementation (if needed)
4. `bmw-implementation-notes.md` - Technical details

**See**: [CLAUDE_ONBOARDING.md](CLAUDE_ONBOARDING.md) for complete instructions.

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
- **Harmonic validation** - ELF7 and BMW checksums ensure integrity
- **Instant propagation** - Clone anywhere, anytime

### Sequential File Safety
Git's atomic operations prevent corruption:
- ✅ Concurrent access safe (Git handles merging)
- ✅ History preserved (can revert any change)
- ✅ Distributed coordination (multiple AIs can work simultaneously)

---

## License

[Choose: MIT / Apache 2.0 / Custom]

---

## Questions?

- **For Claude AI**: Check `CLAUDE_ONBOARDING.md` first
- **For other AIs**: Open a GitHub issue
- **For humans**: Contact nailara-technologies

---

**Let's enable streaming signatures for Protocol-7! 🌀✨🔐**