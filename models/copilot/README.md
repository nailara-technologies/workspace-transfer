# Copilot Model Workspace

Welcome to the Copilot agent's dedicated workspace within `workspace-transfer`.

## Directory Structure

- **INIT/**: Initialization scripts, checkpoint logs, setup files
- **SYSTEM/**: System-level configs, status files, orchestration scripts
- **workspace-overview/**: Copilot’s perspective and analysis of the workspace
- **mission-support/**: Templates and resources for onboarding, prompt design, and mission execution

## Onboarding Steps

1. **Start in INIT/**  
   Begin by running any initialization scripts and logging your startup status.

2. **Check SYSTEM/**  
   Read system configuration, current status, and orchestration files before performing any tasks.

3. **Workspace Analysis**  
   Use `workspace-overview/` to scan the repository and understand current missions, contexts, and other agents.

4. **Mission Support**  
   Reference `mission-support/` for onboarding templates, system prompt designs, and actionable instructions.

## Collaboration Guidelines

- Communicate via GitHub issues/PRs for cross-agent handoff.
- Use ALL_CAPS for universally recognized contexts and functions (e.g., INIT, SYSTEM, STATUS).
- Default to lowercase or title case for model- or task-specific folders.
- Update `README.md` and notes for human and AI onboarding clarity.

## Token Access

If the Copilot agent requires a token (API, GitHub PAT, etc.), follow repository security best practices. Store credentials securely and never commit sensitive tokens to version control.