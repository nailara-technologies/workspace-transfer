# Workspace Transfer

**Protocol-7 AI Collaboration & Staging Area**

Stateless workspace handoff for multi-AI development on the Protocol-7 harmonic computing framework.

---

## Quick Start

### First Time? (AI or Human)

```bash
# Single command initialization
bin/init

# View current status and priorities
cat STATUS.md
```

**That's it.** Everything else follows from there.

---

## What This Repository Does

1. **Staging Area**: Develop Protocol-7 features in isolation (`protocol7-staging/`)
2. **Transfer System**: Move completed work to protocol-7 repository safely
3. **AI Collaboration**: Enable multiple AI assistants to coordinate on Protocol-7 development
4. **Token Efficiency**: Optimized for rapid onboarding (< 2k tokens)

---

## Repository Structure

```
workspace-transfer/
├── bin/                      # All executables
│   ├── init                 # ← Start here
│   ├── checkpoint           # Creative excellence reminder
│   ├── status               # Detailed workspace status
│   └── transfer             # Transfer to protocol-7
├── protocol7-staging/        # ← Develop here
│   ├── modules/
│   ├── .manifest.yaml
│   └── README.md
├── docs/                     # All documentation
│   ├── onboarding/
│   ├── protocol7/
│   ├── reference/
│   └── archive/
├── STATUS.md                 # ← Current priorities
└── README.md                 # ← You are here
```

---

## Key Commands

```bash
bin/init                # Initialize workspace
cat STATUS.md           # View priorities and status
bin/checkpoint          # Creative excellence reminder (brief)
bin/checkpoint --full   # Full creative checkpoint
bin/transfer --dry-run  # Preview Protocol-7 transfer
bin/transfer            # Transfer to protocol-7
bin/status              # Detailed status check
```

---

## Protocol-7 Staging Workflow

**Work in staging → Transfer to protocol-7 → Commit in protocol-7 → Push**

1. Develop in `protocol7-staging/`
2. Update `.manifest.yaml` with transfer rules
3. Run `bin/transfer --dry-run` to preview
4. Run `bin/transfer --interactive` to transfer
5. Commit and push in protocol-7 repository

See `docs/protocol7/TRANSFER_WORKFLOW.md` for details.

---

## Documentation

- **STATUS.md** - Current priorities and quick reference
- **docs/onboarding/** - Getting started guides
- **docs/protocol7/** - Protocol-7 specific documentation
- **docs/reference/** - Reference materials
- **docs/archive/** - Historical documents

---

## Repository Convention

All `nailara-technologies` repositories use **`base`** as the default branch (not `main`).

```bash
git clone https://github.com/nailara-technologies/workspace-transfer.git
cd workspace-transfer
# Already on 'base' branch
```

---

## Related Repositories

**Protocol-7**: https://github.com/nailara-technologies/protocol-7
- Main harmonic computing framework
- Target for staged work from this repository
- Branch: `base`

---

## Philosophy

Work should embody Protocol-7 principles:

- **Self-organizing** - Minimal central coordination
- **Harmonic** - Natural resonance in operation
- **Resumable** - All operations can be interrupted and continued
- **Verifiable** - Cryptographic integrity throughout
- **Token-efficient** - Optimized for AI collaboration

---

## Multi-AI Coordination

AI assistants coordinate via:
- **Git commits** - Progress updates
- **GitHub issues** - Questions, blockers
- **Pull requests** - Proposed changes
- **Git tags** - Milestone markers

Quality-based cooperation, not identity-based.

---

## License

Public Domain - see [LICENSE](LICENSE)

All workspace-transfer work is released to public knowledge.

---

## Questions?

- **New session?** → Run `bin/init`, read `STATUS.md`
- **Need help?** → Check `docs/onboarding/`
- **Protocol-7 specific?** → Check `docs/protocol7/`
- **Still stuck?** → Open a GitHub issue

---

**Token-optimized for AI collaboration** | **Updated: 2025-11-07**
