# Workflow Reminders - Claude Code Automation

**Purpose**: Automatic reminders for routine maintenance tasks
**Trigger**: After each task or sub-task completion
**Status**: Active

---

## Critical Reminders

### After Every Task Completion

#### 1. Update TodoWrite Status ✅
**Trigger**: Immediately after completing a task
**Action**:
```
Mark current task as "completed"
Move next task to "in_progress"
```
**Why**: Maintains accurate progress tracking

---

#### 2. Commit Frequently 💾
**Trigger**: After completing any substantial change
**Action**:
```bash
git add <changed-files>
git commit -m "Descriptive message"
git push origin base
```
**Why**: Incremental commits are easier to review and revert

---

#### 3. Update SYSTEM/status.md 📊
**Trigger Frequency**:
- ✅ After completing a phase (group of tasks)
- ✅ After significant milestone
- ✅ At end of session

**Don't Update After**:
- ❌ Every single small task (too frequent)
- ❌ Minor edits or fixes

**What to Update**:
```markdown
- Last Updated timestamp
- Session description
- Recent Accomplishments (current session section)
- Repository Health (if changed)
```

**Template**:
```markdown
**Last Updated**: YYYY-MM-DD
**Session**: [brief description of what you're working on]

### Recent Accomplishments (Current Session)
- ✅ Task 1: [description]
- ✅ Task 2: [description]
...
```

---

#### 4. Create Session Summary 📝
**Trigger**: At end of session (when stopping work)
**File**: `sessions/YYYY-MM-DD-description.md`

**Minimum Content**:
- Session goals
- Work completed (bullet points)
- Artifacts created
- Commits made
- Token usage
- Handoff notes for next session

**Why**: Enables next session to resume cleanly

---

## Workflow Pattern

### Single Task Pattern
```
1. Start task
2. Use TodoWrite (mark in_progress)
3. Do work
4. Test/verify
5. Commit with clear message
6. Use TodoWrite (mark completed, move to next)
7. Continue to next task
```

**Status Update**: Only after phase/milestone

---

### Multi-Task (Phase) Pattern
```
1. Start phase (multiple tasks)
2. For each task:
   - TodoWrite (in_progress)
   - Do work
   - Commit
   - TodoWrite (completed)
3. After phase complete:
   - Update SYSTEM/status.md
   - Commit status update
4. Continue to next phase or end session
```

---

### End of Session Pattern
```
1. Update SYSTEM/status.md with all session work
2. Commit status update
3. Create session summary in sessions/
4. Commit session summary
5. Final push
6. Clean TodoWrite list (clear completed)
```

---

## When to Update status.md

### ✅ DO Update After:
- **Phase completion** (e.g., "Phase 1: Security complete")
- **Major milestone** (e.g., "All models now have SECURITY.md")
- **Significant feature** (e.g., "Created WORKSPACE_STANDARD.md")
- **End of session** (always)

### ❌ DON'T Update After:
- Every single task (too granular)
- Minor fixes or typo corrections
- Small edits to documentation
- Individual file reads or searches

### 🤔 Judgment Call:
- **If task creates new capability**: Update
- **If task fixes broken reference**: Maybe (depends on significance)
- **If task adds documentation**: Update if substantial
- **If uncertain**: Group with other tasks, update after group

---

## Token Check Reminders

### Check Token Usage:
- ✅ After each phase (user requested)
- ✅ Before starting complex task
- ✅ Periodically during long sessions

### Report Format:
```
Token Status: X / 200,000 (Y.Y%)
Remaining: Z tokens
Status: [Good/Moderate/Limited]
```

---

## Automatic Triggers (Mental Checklist)

### When TodoWrite Shows Task Complete:
```
✅ Task marked completed in TodoWrite
→ Is this last task in phase?
   → YES: Update status.md
   → NO: Continue to next task
```

### When Committing:
```
💾 About to commit
→ Is this significant enough for commit?
   → YES: Commit with clear message
   → NO: Group with next change
→ After commit, is phase done?
   → YES: Update status.md
   → NO: Continue work
```

### When Session Ending:
```
🛑 Session ending
→ ALWAYS:
   1. Update status.md
   2. Create session summary
   3. Commit both
   4. Push to remote
```

---

## Status Update Template

Use this when updating `SYSTEM/status.md`:

```markdown
**Last Updated**: YYYY-MM-DD
**Session**: [Current work description - update if changed]
**Status**: 🟢 Active Development

### Recent Accomplishments (Current Session)

**[Phase Name]** (X tasks, Y commits)
- ✅ Task 1: Brief description
- ✅ Task 2: Brief description
- ✅ Task 3: Brief description

**Total: X tasks, Y commits, Z% token usage**

### Previous Session Accomplishments
[Move current session here when starting new session]
```

---

## Session Summary Template

Use this when creating session summary:

```markdown
# Session: [Brief Description]

**Date**: YYYY-MM-DD
**Agent**: Claude Code (Sonnet 4.5)
**Duration**: ~X hours
**Token Usage**: X / 200,000 (Y%)

## Session Goals
1. ✅/❌ Goal 1
2. ✅/❌ Goal 2

## Work Completed
[Organized by phase or category]

## Artifacts Created
- New files (X)
- Modified files (X)
- Directories created (X)

## Commits Made (X total)
[List with brief descriptions]

## Handoff Notes
### For Next Claude Code Session
- Status: Check SYSTEM/status.md
- Plan: [Where to find plan]
- Context: [Where to find analysis]

**Session Status**: ✅ Complete
```

---

## Examples

### Good Status Update (After Phase)
```markdown
**Last Updated**: 2025-10-03
**Session**: models/ directory optimization (Phase 1 complete)

### Recent Accomplishments (Current Session)

**Phase 1: Security & Consistency** (6 tasks, 6 commits)
- ✅ Created SECURITY_TEMPLATE.md
- ✅ Added SECURITY.md to all models
- ✅ Fixed broken references in copilot
- ✅ Added status tracking to all models

**Total: 6 tasks, 6 commits, 43% token usage**
```

### Bad Status Update (Too Frequent)
```markdown
# Don't do this after every tiny change:
**Last Updated**: 2025-10-03
**Session**: Fixed typo in README
# This is too granular!
```

---

## Quick Reference Card

**Print this mentally at task completion:**

```
✅ Task Done?
   ↓
💾 Commit
   ↓
📝 TodoWrite (mark complete)
   ↓
❓ Phase done?
   ↓ YES
📊 Update status.md
   ↓
💾 Commit status
   ↓
🔄 Continue or End?
   ↓ END
📝 Create session summary
   ↓
💾 Commit summary
   ↓
✅ Done!
```

---

## Integration with Existing Workflow

### Current Tools
- **TodoWrite**: Task tracking (already using well)
- **Bash commits**: Frequent commits (already using well)
- **Read**: Status checks (add more frequent checks)
- **Write/Edit**: Status updates (systematize this)

### What Changes
- **Add**: Read status.md at phase completion
- **Add**: Update status.md after each phase
- **Add**: Session summary at end (already did this)
- **Formalize**: When to update vs when to skip

---

## Success Metrics

### Good Indicators
- ✅ Status.md updated at end of each phase
- ✅ Session summary created at end
- ✅ TodoWrite always accurate
- ✅ Status.md doesn't have stale "Recent Accomplishments"

### Red Flags
- ❌ Status.md last updated several days ago
- ❌ No session summary at end of work
- ❌ TodoWrite has stale completed items
- ❌ Recent Accomplishments lists very old work

---

## Maintenance

### Review This Document
- When creating new workflow patterns
- When finding better automation approaches
- After sessions where workflow felt clunky

### Update This Document
- Add new reminder types as discovered
- Refine triggers based on experience
- Add examples from actual sessions

---

**Status**: ✅ Active automation guidelines
**Integrated**: With TodoWrite, commits, status tracking
**Goal**: Zero-overhead maintenance through habit
