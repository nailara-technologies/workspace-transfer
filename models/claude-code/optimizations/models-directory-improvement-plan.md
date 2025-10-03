# models/ Directory Improvement Plan

**Date**: 2025-10-03
**Session**: models/ optimization
**Status**: Ready for execution
**Source Analysis**: analyses/models-directory-analysis.md

---

## Execution Strategy

**Approach**: Incremental, frequent commits
**Checkpoint**: Pause after each task to check token budget
**Rollback**: All changes can be reverted via git
**Validation**: Test after each phase

---

## Phase 1: Security & Consistency (HIGH PRIORITY)

### Task 1.1: Create SECURITY.md Template

**Action**: Create reusable security template for all models

**File**: `models/SECURITY_TEMPLATE.md`

**Content**:
- Public repository warning
- Multi-directory context awareness
- Pre-commit verification checklist
- Content sensitivity guide
- Emergency response procedure
- Link to main security docs

**Commit**: "Create SECURITY.md template for model workspaces"

---

### Task 1.2: Add SECURITY.md to copilot/

**Action**: Copy template, customize for copilot context

**File**: `models/copilot/SECURITY.md`

**Customizations**:
- Note copilot's philosophical approach
- Mention mission-support/ directory
- Reference suggestions/ communication

**Commit**: "Add SECURITY.md to copilot workspace"

---

### Task 1.3: Add SECURITY.md to qwen2.5-7b-instruct-1m/

**Action**: Copy template, customize for qwen context

**File**: `models/qwen2.5-7b-instruct-1m/SECURITY.md`

**Customizations**:
- Note GitHub MCP server usage
- Reference tasks/ and suggestions/ directories
- Mention .asc file format considerations

**Commit**: "Add SECURITY.md to qwen2.5-7b-instruct-1m workspace"

---

### Task 1.4: Fix copilot README Broken References

**Action**: Edit copilot/README.md to remove workspace-overview/ references

**Changes**:
- Line 13: Remove "workspace-overview/" from directory structure
- Line 27-28: Update reference from workspace-overview/ to mission-support/
- Verify all directory references are valid

**Commit**: "Fix copilot README: Remove non-existent workspace-overview references"

---

### Task 1.5: Add SYSTEM/status.md to copilot/

**Action**: Create status tracking for copilot

**File**: `models/copilot/SYSTEM/status.md`

**Content**:
- Last activity timestamp
- Security context (public repo)
- Current focus/mission
- Capabilities status
- Communication channels status
- Known issues/blockers

**Commit**: "Add status tracking to copilot workspace"

---

### Task 1.6: Add SYSTEM/status.md to qwen2.5-7b-instruct-1m/

**Action**: Create status tracking for qwen

**File**: `models/qwen2.5-7b-instruct-1m/SYSTEM/status.md`

**Content**:
- Last activity timestamp
- Security context (public repo)
- Current tasks status
- GitHub MCP server configuration
- Communication channels status
- Task workflow status

**Commit**: "Add status tracking to qwen2.5-7b-instruct-1m workspace"

---

**Phase 1 Checkpoint**: Review token budget, assess progress

---

## Phase 2: Structure & Documentation (MEDIUM PRIORITY)

### Task 2.1: Create WORKSPACE_STANDARD.md

**Action**: Document standard model workspace structure

**File**: `models/WORKSPACE_STANDARD.md`

**Content**:
- Required files (README, SECURITY)
- Optional files (status, sessions)
- Directory naming conventions (ALL_CAPS vs lowercase)
- Communication patterns (suggestions/ vs Git)
- Security requirements
- Handoff protocols
- Examples

**Commit**: "Create workspace structure standard documentation"

---

### Task 2.2: Enhance models/README.md

**Action**: Expand existing models/README.md

**Additions**:
- Purpose of models/ directory
- When to use each model (capability matrix)
- Communication protocols overview
- Security requirements summary
- Link to WORKSPACE_STANDARD.md
- Handoff procedures

**Commit**: "Enhance models/README.md with comprehensive overview"

---

### Task 2.3: Add README.md to next-larger/

**Action**: Create proper README for next-larger

**File**: `models/next-larger/README.md`

**Content**:
- Purpose (escalation to larger hosted models)
- When to use (complex analysis, large context needs)
- How to handoff (format, what to include)
- Examples of handoff scenarios
- Expected response format

**Commit**: "Add README to next-larger handoff directory"

---

### Task 2.4: Add README.md to next-local/

**Action**: Create proper README for next-local

**File**: `models/next-local/README.md`

**Content**:
- Purpose (handoff to other local models)
- When to use (resource constraints, local processing)
- How to handoff (format, what to include)
- Examples of handoff scenarios
- Local model coordination

**Commit**: "Add README to next-local handoff directory"

---

### Task 2.5: Add Handoff Templates

**Action**: Create handoff message templates

**Files**:
- `models/next-larger/handoff-template.md`
- `models/next-local/handoff-template.md`

**Template Content**:
- Context summary
- Task description
- Current state/progress
- Blockers/challenges
- Expected deliverables
- References/links

**Commit**: "Add handoff templates to next-* directories"

---

### Task 2.6: Add Example Handoffs

**Action**: Create example handoff messages

**Files**:
- `models/next-larger/examples/0001-complex-analysis-example.md`
- `models/next-local/examples/0001-resource-constrained-example.md`

**Commit**: "Add example handoff messages to next-* directories"

---

**Phase 2 Checkpoint**: Review token budget, assess progress

---

## Phase 3: Enhancements (LOW PRIORITY)

### Task 3.1: Document Inter-Model Communication Patterns

**Action**: Add communication patterns to WORKSPACE_STANDARD.md

**Content**:
- Pattern A: suggestions/ directories (file-based)
- Pattern B: Git commits (direct coordination)
- When to use each
- Examples of both

**Commit**: "Document inter-model communication patterns"

---

### Task 3.2: Replace .placeholder Files

**Action**: Replace placeholder files with README.md

**Files to Replace**:
- `models/copilot/suggestions/incoming/.placeholder` → README.md
- `models/copilot/suggestions/outgoing/.placeholder` → README.md
- `models/qwen2.5-7b-instruct-1m/suggestions/incoming/.placeholder` → README.md
- `models/qwen2.5-7b-instruct-1m/suggestions/outgoing/.placeholder` → README.md

**README Content**:
- Directory purpose
- Expected file format
- Naming conventions
- Examples

**Commit**: "Replace placeholder files with informative README files"

---

### Task 3.3: Add Cross-References to Model READMEs

**Action**: Add "Related Models" section to each README

**Files to Edit**:
- `models/claude-code/README.md`
- `models/copilot/README.md`
- `models/qwen2.5-7b-instruct-1m/README.md`

**Content**:
- List of other models
- Capability summary for each
- When to coordinate/handoff
- Communication protocol with each

**Commit**: "Add cross-references between model workspaces"

---

### Task 3.4: Document .asc File Format

**Action**: Add task format documentation to qwen

**File**: `models/qwen2.5-7b-instruct-1m/TASK_FORMAT.md`

**Content**:
- What .asc format means
- Why this format chosen
- How to create new tasks
- Naming convention (XXX_name.asc)
- Structure/template
- Examples

**Commit**: "Document .asc task file format for qwen workspace"

---

### Task 3.5: Add Session Logging to copilot/

**Action**: Create sessions/ directory structure

**Directory**: `models/copilot/sessions/`

**Files**:
- Create directory
- Add `sessions/README.md` explaining purpose
- Template for session logs

**Content**:
- Session naming convention
- What to log
- Format guide

**Commit**: "Add session logging structure to copilot workspace"

---

### Task 3.6: Create Model Capability Matrix

**Action**: Add capability comparison to models/README.md

**Table Content**:
| Model | Type | Strengths | Use Cases | Communication |
|-------|------|-----------|-----------|---------------|
| claude-code | CLI | Tool mastery, optimization | Development, refactoring | Git commits |
| copilot | Integration | Philosophical guidance | Consciousness navigation | suggestions/ |
| qwen2.5-7b | Local 7B | Training, evaluation | ML workflows | suggestions/ |
| next-larger | Handoff | Large context | Complex analysis | Handoff docs |
| next-local | Handoff | Resource efficient | Local processing | Handoff docs |

**Commit**: "Add model capability matrix to models/README.md"

---

**Phase 3 Checkpoint**: Review token budget, final assessment

---

## Execution Order (Prioritized)

### Start Here (Critical):
1. ✅ Task 1.1: Create SECURITY template
2. ✅ Task 1.2: Add SECURITY to copilot
3. ✅ Task 1.3: Add SECURITY to qwen
4. ✅ Task 1.4: Fix copilot broken references
5. ✅ Task 1.5: Add status to copilot
6. ✅ Task 1.6: Add status to qwen

**PAUSE FOR TOKEN CHECK**

### Continue If Budget Allows (Important):
7. ✅ Task 2.1: Create WORKSPACE_STANDARD
8. ✅ Task 2.2: Enhance models/README.md
9. ✅ Task 2.3: Add README to next-larger
10. ✅ Task 2.4: Add README to next-local
11. ✅ Task 2.5: Add handoff templates
12. ✅ Task 2.6: Add example handoffs

**PAUSE FOR TOKEN CHECK**

### If Budget Still Good (Nice to Have):
13. ✅ Task 3.1: Document communication patterns
14. ✅ Task 3.2: Replace placeholders
15. ✅ Task 3.3: Add cross-references
16. ✅ Task 3.4: Document .asc format
17. ✅ Task 3.5: Add sessions to copilot
18. ✅ Task 3.6: Create capability matrix

**FINAL TOKEN CHECK**

---

## Success Criteria

### Phase 1 Complete:
- ✅ All models have SECURITY.md
- ✅ copilot README references valid directories only
- ✅ All models have SYSTEM/status.md
- ✅ Frequent commits (6 commits)

### Phase 2 Complete:
- ✅ WORKSPACE_STANDARD.md exists
- ✅ models/README.md is comprehensive
- ✅ next-larger and next-local have READMEs
- ✅ Handoff templates exist
- ✅ Example handoffs exist
- ✅ Frequent commits (6 commits)

### Phase 3 Complete:
- ✅ Communication patterns documented
- ✅ No .placeholder files remain
- ✅ Cross-references in all READMEs
- ✅ .asc format documented
- ✅ copilot has session logging
- ✅ Capability matrix exists
- ✅ Frequent commits (6 commits)

---

## Rollback Plan

If issues discovered:
```bash
# View recent commits
git log --oneline -10

# Revert specific commit
git revert <commit-hash>

# Or reset to before changes
git reset --hard <commit-before-changes>
```

**All changes are safe to revert.**

---

## Token Management Strategy

**Pause Points**: After tasks 1.6, 2.6, 3.6
**Check Command**: User will confirm token budget
**Abort Criteria**: If budget low, stop and document progress
**Resume**: Can continue in future session from any checkpoint

---

**Plan Status**: ✅ Complete and ready for execution
**Total Tasks**: 18
**Estimated Commits**: 18 (one per task)
**Execution Mode**: Pause after each task for token check
