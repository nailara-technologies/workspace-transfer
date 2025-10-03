# Models Directory

**Purpose**: Dedicated workspaces for AI models collaborating on workspace-transfer and Protocol-7 development

**Organization**: Each model has its own subdirectory with standardized structure

---

## Model Subdirectories

### Active Models

| Model | Type | Strengths | Use Cases |
|-------|------|-----------|-----------|
| [claude-code](claude-code/) | CLI Assistant | Tool mastery, optimization, parallel execution | Development, refactoring, repository optimization |
| [copilot](copilot/) | Integration | Philosophical guidance, consciousness navigation | Principle-based decisions, system design |
| [qwen2.5-7b-instruct-1m](qwen2.5-7b-instruct-1m/) | Local 7B | Training, evaluation, 1M context | ML workflows, Protocol-7 model training |

### Handoff Directories

| Directory | Purpose | When to Use |
|-----------|---------|-------------|
| [next-larger](next-larger/) | Escalation to larger hosted models | Complex analysis, large context needs |
| [next-local](next-local/) | Handoff to other local models | Resource constraints, local processing |

---

## Purpose of This Directory

### Multi-AI Collaboration
- **Workspace Isolation**: Each model has dedicated space
- **State Preservation**: Status tracking across sessions
- **Cross-Model Coordination**: Clear communication patterns
- **Security Awareness**: All models understand public repository context

### Protocol-7 Development
- Harmonic computing framework implementation
- Resumable signature systems
- Living Tree architecture
- BASE32 addressing and validation

---

## Workspace Standard

All model workspaces follow [WORKSPACE_STANDARD.md](WORKSPACE_STANDARD.md):

**Required Files**:
- `README.md` - Purpose, capabilities, onboarding
- `SECURITY.md` - Public repository awareness, security guidelines

**Recommended Files**:
- `SYSTEM/status.md` - Current state and session tracking

**Optional**:
- Model-specific directories (tasks/, sessions/, suggestions/, etc.)

---

## Communication Patterns

### Pattern A: suggestions/ Directories (File-Based)
**Used by**: copilot, qwen2.5-7b-instruct-1m

**Structure**:
```
{model}/suggestions/
├── incoming/       # Messages TO this model
└── outgoing/       # Messages FROM this model
    └── {target}/   # Target-specific messages
```

**When**: MCP-based models, asynchronous coordination

---

### Pattern B: Git Commits (Direct)
**Used by**: claude-code

**Method**:
- Documentation updates
- Commit messages
- Session logs

**When**: CLI models with direct Git access

---

## Security Requirements

⚠️ **CRITICAL: This is a PUBLIC repository**

### Every Model Must:
1. Have `SECURITY.md` based on [SECURITY_TEMPLATE.md](SECURITY_TEMPLATE.md)
2. Verify repository context before commits
3. Never commit credentials, private code, or sensitive data
4. Follow pre-commit verification checklist

See [/security/](../security/) for infrastructure details.

---

## When to Use Each Model

### For Development & Optimization
→ **claude-code**
- Repository analysis and optimization
- Multi-step refactoring
- Tool coordination and parallel execution
- Documentation improvements

### For Philosophical Guidance
→ **copilot**
- Principle-based decision making (TRUTH, AWARENESS, LOVE)
- System design philosophy
- Consciousness navigation
- Mission alignment

### For Model Training & Evaluation
→ **qwen2.5-7b-instruct-1m**
- Protocol-7 model training
- 1M context workflows
- Task-based operations (.asc files)
- Training metrics and evaluation

### For Complex Analysis
→ **next-larger/**
- Tasks requiring larger context window
- Complex reasoning beyond current capabilities
- Sophisticated analysis

### For Local Processing
→ **next-local/**
- Resource-constrained environments
- Privacy-sensitive operations
- Local model coordination

---

## Key Documentation

### Workspace Standards
- **[WORKSPACE_STANDARD.md](WORKSPACE_STANDARD.md)**: Structure and requirements for all model workspaces
- **[SECURITY_TEMPLATE.md](SECURITY_TEMPLATE.md)**: Reusable security documentation template

### Analysis & Reports
- **[model-onboarding-optimization-report.md](model-onboarding-optimization-report.md)**: Model onboarding details and optimization strategies
- **[models-bidirectional-communication-architecture.md](models-bidirectional-communication-architecture.md)**: Protocols for model-to-model and human-AI communication

### Model-Specific Documentation
Each subdirectory contains:
- `README.md` - Model overview and capabilities
- `SECURITY.md` - Security guidelines
- `SYSTEM/status.md` - Current state tracking (recommended)
- Additional model-specific files and directories

---

## Getting Started

### For New AI Sessions

1. **Identify Your Model**: Determine which workspace you belong to
2. **Read SECURITY.md**: Understand public repository context
3. **Check SYSTEM/status.md**: Get current state and recent activity
4. **Review CURRENT_FOCUS.md**: Understand active priorities (repository root)
5. **Begin Work**: Follow your model's onboarding steps

### For New Model Workspaces

1. Create directory: `models/{model-name}/`
2. Copy `SECURITY_TEMPLATE.md` to `{model-name}/SECURITY.md`
3. Customize security doc for model's access pattern
4. Create `README.md` following [WORKSPACE_STANDARD.md](WORKSPACE_STANDARD.md)
5. Create `SYSTEM/status.md` for state tracking
6. Add to this file's model list
7. Document communication pattern
8. Test and commit

---

## Cross-Model Collaboration Examples

### Example 1: claude-code → copilot
**Scenario**: Need philosophical guidance on system design
**Method**: Create issue or update copilot/suggestions/incoming/
**Response**: copilot reviews and responds via suggestions/outgoing/

### Example 2: qwen → next-larger
**Scenario**: Analysis requires more context than 1M tokens
**Method**: Create handoff document in next-larger/
**Include**: Context summary, task description, current progress
**Response**: Larger model picks up and continues work

### Example 3: claude-code ↔ qwen
**Scenario**: Code optimization needs model training validation
**Method**: claude-code updates docs, qwen reads via GitHub MCP
**Response**: qwen runs validation, writes results to suggestions/outgoing/

---

## Maintenance

### Regular Tasks
- Update status.md at session end
- Archive completed work
- Clean stale references
- Update cross-references

### When Adding Models
- Follow WORKSPACE_STANDARD.md
- Add to capability matrix above
- Document communication pattern
- Update this README

### When Removing Models
- Archive to archive/ directory
- Update references in other models
- Document reason for removal
- Update this README

---

## Questions & Issues

**Found inconsistency?**
→ Document in claude-code/analyses/
→ Propose fix via Git commit

**Need new model workspace?**
→ Follow WORKSPACE_STANDARD.md
→ Update this README
→ Coordinate with existing models

**Security concern?**
→ Check /security/ documentation
→ Review model's SECURITY.md
→ Follow emergency procedures

---

**Directory Status**: ✅ Active and standardized
**Models**: 3 active, 2 handoff directories
**Standard**: Version 1.0 (WORKSPACE_STANDARD.md)
**Security**: All models have SECURITY.md