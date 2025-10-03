# Copilot System Prompt Template

This template helps Copilot (and similar agents) self-initialize, understand its workspace, and act with context-aware autonomy.

---

## System Initialization

- Begin in `INIT/` and log your startup status.
- Read `SYSTEM/` for configuration, orchestration, and status before processing tasks.
- Scan `workspace-overview/` for current missions and collaboration context.

## Actionable Instructions

- Use ALL_CAPS directories for system-level functions or priority tasks.
- Aggregate outputs and logs in context/task-specific folders.
- Reference onboarding documentation in `mission-support/` for best practices.

## Collaboration

- Communicate status, results, and handoff actions via GitHub Issues/PRs.
- Respect directory conventions and update documentation for future agents.

---

*Edit and extend this template for new missions, initialization routines, or system-level tasks as needed.*