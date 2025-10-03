# Task: Workspace Command System Optimization

**Date Started**: October 3, 2025  
**Priority**: HIGH  
**Status**: 🔄 In Progress

---

## 🎯 Objective

Reduce complexity in system prompts for local models by refactoring workspace bootstrapping to use remote `.asc` file references instead of embedding full instructions.

## 🔍 Problem Statement

Current system prompts for local models (qwen2.5-7b-instruct-1m, etc.) connected via github-mcp-server contain:
- Large embedded instructions for workspace initialization
- Duplicated content between system prompt and README files
- Difficult to maintain consistency across multiple model configurations
- Commands like `workspace-init` and `workspace-resume` have debugging issues

## 💡 Solution Approach

**Simplify system prompt** → **Point to remote `.asc` files** → **Let models fetch instructions**

### Architecture Change

**BEFORE** (Current):
```
System Prompt (Large)
├── Full workspace-init instructions (embedded)
├── Full workspace-resume instructions (embedded)
└── Other commands (embedded)
```

**AFTER** (Proposed):
```
System Prompt (Minimal)
├── workspace-init → fetch README.init.asc
├── workspace-resume → fetch README.resume.asc
├── workspace-improve → fetch README.improve.asc (new)
└── workspace-edit → fetch README.edit.asc (new)
```

## 📋 Implementation Tasks

### Phase 1: Remote .asc File Architecture
- [x] Review current README.init.asc
- [x] Review current README.resume.asc
- [x] Identify what's working vs what needs debugging
- [x] Design minimal system prompt structure
- [x] Define .asc file format standards (directive-style)

### Phase 2: Create/Refactor .asc Files
- [x] Refactor README.init.asc (explicit 2-step tool calls)
- [x] Refactor README.resume.asc (explicit 3-step tool calls)
- [x] Create README.improve.asc (workspace infrastructure mode)
- [x] Create README.edit.asc (documentation edit mode)
- [x] Ensure all .asc files are self-contained and executable

### Phase 3: Minimal System Prompt
- [x] Design new minimal system prompt template (v2.0)
- [x] Add github-mcp-server fetch instructions
- [x] Add command → .asc file mapping
- [ ] Test with qwen2.5-7b-instruct-1m
- [ ] Document the new pattern

### Phase 4: Debug & Validate
- [ ] Test workspace-init flow with new architecture
- [ ] Test workspace-resume flow with new architecture
- [ ] Identify and fix debugging issues mentioned
- [ ] Create troubleshooting guide
- [ ] Update model onboarding docs

## 🔧 Technical Details

### github-mcp-server Integration
- Models can fetch files from GitHub repositories
- Use raw.githubusercontent.com URLs for .asc files
- Models read and execute instructions from remote files
- Reduces system prompt token usage significantly

### .asc File Structure (Proposed)
```
# WORKSPACE-<COMMAND>

## Quick Start (3-5 commands max)

## Full Instructions
1. Step-by-step bootstrap
2. Verification
3. Status reporting

## Error Handling
- Common issues
- Recovery steps
```

### System Prompt Structure (Proposed)
```
You have access to github-mcp-server tool.

Commands available:
- workspace-init: Fetch and execute README.init.asc
- workspace-resume: Fetch and execute README.resume.asc
- workspace-improve: Fetch and execute README.improve.asc
- workspace-edit: Fetch and execute README.edit.asc

Repository: https://github.com/nailara-technologies/workspace-transfer
Branch: base

When user invokes a command, fetch the corresponding .asc file and follow its instructions.
```

## 🐛 Known Issues to Debug

### workspace-init
- Token location issues?
- Authentication flow problems?
- Status reporting inconsistencies?

### workspace-resume
- State restoration incomplete?
- Session context not loading properly?
- Current focus detection issues?

*(Document specific issues as we investigate)*

## 📊 Success Criteria

- [ ] System prompt reduced by >70% in token count
- [ ] All four workspace commands functional
- [ ] Local models can bootstrap without confusion
- [ ] .asc files are maintainable and clear
- [ ] Documentation updated and verified
- [ ] Tested with at least one local model

## 🔄 Progress Log

### Session 1 - October 3, 2025 (Original)
- Task document created
- Ready to investigate current state
- Next: Review existing README.init.asc and README.resume.asc

### Session 2 - October 3, 2025 (Current - Explicit .asc Files)
- ✅ Reviewed all existing .asc files and identified issues
- ✅ Problem: .asc files too minimal, no actionable instructions
- ✅ Problem: Models become verbose when instructions unclear
- ✅ Problem: Tool calls fail due to lack of explicit format
- ✅ Created explicit directive-style .asc files:
  - README.init.asc: 2 tool calls + "SYSTEM READY." output
  - README.resume.asc: 3 tool calls + task listing output
  - README.improve.asc: 3 tool calls for infrastructure mode
  - README.edit.asc: 2 tool calls for edit mode
- ✅ Updated SYSTEM_PROMPT_MINIMAL.md v2.0 with new pattern
- 🔄 Next: Test with qwen model, verify tool call success

---

## 📁 Related Files

- `README.init.asc` - Current init instructions
- `README.resume.asc` - Current resume instructions
- `SYSTEM_PROMPT_TEMPLATE.md` - Current system prompt template
- `models/qwen2.5-7b-instruct-1m/` - Test model configuration
- `models/WORKSPACE_STANDARD.md` - Workspace standards doc

---

**Note**: Push this task file early and often. Session crashes shouldn't lose context.
