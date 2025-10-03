# Model Workspace Structure Standard

**Version**: 1.0
**Date**: 2025-10-03
**Purpose**: Define consistent structure for all model workspaces in workspace-transfer

---

## Overview

This document establishes the standard structure for model workspaces to ensure:
- **Consistency**: Predictable layout across all models
- **Security**: Every model has security awareness
- **State Tracking**: Session-to-session continuity
- **Cross-Model Coordination**: Clear communication patterns
- **Onboarding**: Easy for new AI sessions to understand structure

---

## Required Files

### 1. README.md (REQUIRED)

**Location**: `models/{model-name}/README.md`

**Must contain**:
- Model name and purpose
- Capabilities summary
- Setup instructions (if applicable)
- Directory structure overview
- Onboarding steps
- Related models section

**Example structure**:
```markdown
# {Model Name} Workspace

**Purpose**: Brief description
**Capabilities**: What this model does

## Setup
Installation/configuration steps

## Directory Structure
Overview of directories

## Onboarding Steps
1. Read SECURITY.md
2. Check SYSTEM/status.md
3. Review current focus
4. Begin work

## Related Models
- Other models and when to coordinate
```

---

### 2. SECURITY.md (REQUIRED)

**Location**: `models/{model-name}/SECURITY.md`

**Must contain**:
- Public repository awareness
- Multi-directory context warnings
- Pre-commit verification checklist
- Security infrastructure overview
- Emergency response procedures
- Model-specific security considerations

**Template Available**: Use `/models/SECURITY_TEMPLATE.md` as starting point

**Why Required**:
- This is a PUBLIC repository
- All models must be security-aware
- Prevents accidental credential commits
- Documents security best practices

---

## Strongly Recommended Files

### 3. SYSTEM/status.md (RECOMMENDED)

**Location**: `models/{model-name}/SYSTEM/status.md`

**Should contain**:
- Last update timestamp
- Security context
- Workspace health status
- Active focus areas
- Communication channels status
- Recent activity log
- Next session recommendations
- Known issues

**Benefits**:
- Session-to-session continuity
- State awareness
- Progress tracking
- Quick orientation for new sessions

---

## Optional Directories & Files

### 4. sessions/ (OPTIONAL)

**Location**: `models/{model-name}/sessions/`

**Purpose**: Log individual session activities

**File Format**: `YYYY-MM-DD-description.md`

**Contains**:
- Session goals
- Actions taken
- Decisions and rationale
- Patterns discovered
- Artifacts created

**Best For**: CLI-based models (Claude Code)

---

### 5. suggestions/ (OPTIONAL)

**Location**: `models/{model-name}/suggestions/`

**Purpose**: File-based inter-model communication

**Structure**:
```
suggestions/
├── incoming/       # Messages TO this model
└── outgoing/       # Messages FROM this model
    ├── {target-model}/
    │   ├── 0001.description
    │   └── 0002.description
    └── README.md
```

**Best For**: MCP-based models, file-based coordination

---

### 6. Model-Specific Directories

Models may create additional directories as needed:
- `tasks/` - Task-based workflows (qwen)
- `mission-support/` - Templates and resources (copilot)
- `analyses/` - Analysis outputs (claude-code)
- `optimizations/` - Reusable patterns (claude-code)
- `INIT/` - Initialization tracking

---

## Directory Naming Conventions

### ALL_CAPS Directories
**Use for**: Universal, system-level functions

**Examples**:
- `INIT/` - Initialization scripts and logs
- `SYSTEM/` - System configuration and status
- `STATUS/` - Status files (if not in SYSTEM/)

**Convention**: Denotes high-level organization

---

### lowercase Directories
**Use for**: Functional, task-specific content

**Examples**:
- `sessions/` - Session logs
- `tasks/` - Task workflows
- `suggestions/` - Inter-model communication
- `analyses/` - Analysis outputs
- `mission-support/` - Templates and resources

**Convention**: Denotes operational content

---

## Communication Patterns

### Pattern A: suggestions/ Directories (File-Based)

**Use When**:
- Model operates via file-based tools (GitHub MCP server)
- Asynchronous communication needed
- Persistent message storage desired

**Structure**:
```
suggestions/
├── incoming/{source}/NNNN.message
└── outgoing/{target}/NNNN.message
```

**File Naming**: Sequential numbers (0001, 0002, etc.)

**Models Using This**: copilot, qwen2.5-7b-instruct-1m

---

### Pattern B: Git Commits (Direct Coordination)

**Use When**:
- Model has direct Git access (CLI)
- Real-time coordination possible
- Documentation updates serve as communication

**Method**:
- Clear commit messages
- Documentation updates
- Status file updates
- Session logs

**Models Using This**: claude-code

---

### Pattern C: Hybrid

**Use When**: Model can use both approaches

**Method**: Use whichever fits the task better
- Git for documentation and code
- suggestions/ for targeted messages

---

## Security Requirements

### Every Model Must:

1. **Have SECURITY.md**
   - Based on template
   - Customized for model's access patterns
   - Updated when new risks discovered

2. **Follow Pre-Commit Checklist**
   - Verify repository context
   - Check content is public-safe
   - Sanitize paths and examples
   - Question before committing

3. **Maintain .gitignore Awareness**
   - Know what's protected
   - Update when new patterns found
   - Test with `git check-ignore`

4. **Respect Pre-Commit Hook**
   - Available at /security/hooks/
   - Can be installed per-user
   - Detects common credential patterns

---

## Handoff Protocols

### When to Handoff

**To next-larger/**:
- Task requires larger context window
- Complex analysis beyond current model capability
- Need for more sophisticated reasoning

**To next-local/**:
- Resource constraints in current environment
- Need for local processing (privacy, speed)
- Coordination with other local models

**To specific model**:
- Task matches model's specialty
- Via suggestions/ directories
- Clear handoff documentation

### Handoff Format

**Include**:
1. Context summary
2. Task description
3. Current state/progress
4. Blockers/challenges
5. Expected deliverables
6. References/links

**Templates**: See next-larger/ and next-local/ directories

---

## Examples: Model Workspace Structures

### Example 1: claude-code (CLI Model)

```
models/claude-code/
├── README.md              # Comprehensive, operational philosophy
├── SECURITY.md            # CLI-specific security guidelines
├── INIT/
│   └── first-session.md
├── SYSTEM/
│   ├── status.md
│   └── SECURITY.md        # Detailed security procedures
├── sessions/              # Session logs
├── analyses/              # Analysis outputs
└── optimizations/         # Reusable patterns
```

**Characteristics**:
- Git-based communication
- Session logging
- No suggestions/ (uses Git directly)
- Optimization capture

---

### Example 2: qwen2.5-7b-instruct-1m (MCP Model)

```
models/qwen2.5-7b-instruct-1m/
├── README.md              # Setup and capabilities
├── SECURITY.md            # MCP-specific security
├── WHO_AM_I.md            # Quick reference
├── NAVIGATION.md          # Path guide
├── TOOL_REFERENCE.md
├── WORKFLOW_GUIDE.md
├── SYSTEM/
│   └── status.md
├── tasks/                 # .asc workflow files
└── suggestions/           # File-based communication
    ├── incoming/
    └── outgoing/
```

**Characteristics**:
- File-based communication
- Task-oriented (.asc files)
- Navigation aids
- MCP tool reference

---

### Example 3: copilot (Integration Model)

```
models/copilot/
├── README.md              # Principles and philosophy
├── SECURITY.md            # Consciousness-aware security
├── SYSTEM/
│   └── status.md
├── mission-support/       # Templates and resources
└── suggestions/           # File-based communication
    ├── incoming/
    └── outgoing/
```

**Characteristics**:
- Philosophical guidance
- Principle-based operations
- Mission support resources
- File-based communication

---

## Validation Checklist

When creating or updating a model workspace, verify:

### Required (Must Have)
- [ ] README.md exists and is comprehensive
- [ ] SECURITY.md exists with model-specific guidelines
- [ ] All directory references in README are valid
- [ ] Onboarding steps are clear

### Recommended (Should Have)
- [ ] SYSTEM/status.md exists with current state
- [ ] Related models section in README
- [ ] Communication pattern documented
- [ ] Recent activity logged

### Quality (Nice to Have)
- [ ] Examples provided
- [ ] Cross-references to other models
- [ ] Session logging mechanism
- [ ] Metrics tracking

---

## Maintenance Guidelines

### When Adding New Model Workspace

1. Copy SECURITY_TEMPLATE.md to new workspace
2. Customize SECURITY.md for model's access pattern
3. Create README.md following standard structure
4. Create SYSTEM/status.md for state tracking
5. Add to models/README.md list
6. Document communication pattern
7. Create initial status entry
8. Test directory references

### When Updating Existing Workspace

1. Verify all directory references are valid
2. Update SECURITY.md if new risks discovered
3. Update status.md with changes
4. Document in session log (if applicable)
5. Update README if structure changed
6. Commit with clear message

### Regular Maintenance

- Review SECURITY.md quarterly
- Update status.md at session end
- Clean up stale references
- Archive completed work
- Update cross-references

---

## Version History

### Version 1.0 (2025-10-03)
- Initial standard created
- Based on analysis of claude-code, copilot, qwen workspaces
- Established required/recommended/optional structure
- Defined communication patterns
- Security requirements documented

---

## Questions & Feedback

**Found an issue with this standard?**
→ Document in claude-code/analyses/
→ Propose update via Git commit
→ Update this version history

**Need clarification?**
→ Check existing model workspaces for examples
→ Review models/README.md for context
→ Ask in suggestions/ communication

---

**Standard Status**: ✅ Active
**Compliance**: All models should follow this standard
**Exceptions**: Document in model's README.md with justification
**Updates**: Version this document, maintain history
