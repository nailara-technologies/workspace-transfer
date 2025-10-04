# Checkpoint Scripts - Usage Guide

**Scripts**: `export-context-checkpoint.pl` and `load-context-checkpoint.pl`  
**Purpose**: Phase 0 implementation - context reset for token efficiency  
**Location**: `scripts/`

---

## Quick Start

### Create a Checkpoint

**Interactive mode** (recommended first time):
```bash
cd workspace-transfer
perl scripts/export-context-checkpoint.pl --session-name=my-work

# You'll be prompted for:
# - Active task description
# - Current status
# - Recent achievements
# - Open issues
# - Next steps
# - Key decisions
# - Important context
# - Reference files
```

**Automated mode** (quick backup):
```bash
perl scripts/export-context-checkpoint.pl --auto --session-name=quick-backup
```

### List Available Checkpoints

```bash
perl scripts/load-context-checkpoint.pl --list

# Output shows:
# - Named sessions (grouped)
# - Unnamed checkpoints (timestamped)
# - Total count
```

### Load a Checkpoint

**Load most recent**:
```bash
perl scripts/load-context-checkpoint.pl
```

**Load specific session**:
```bash
perl scripts/load-context-checkpoint.pl --session-name=my-work
```

**Output**: Full checkpoint content displayed, ready to copy or use directly

---

## Real-World Workflow

### Scenario: ELF Architecture Work Complete

**Step 1**: Export checkpoint after milestone
```bash
perl scripts/export-context-checkpoint.pl --session-name=elf-complete

# Interactive prompts:
Active task: ELF algorithm clarification and documentation
Status: clean
Achievements:
  1. Created ELF_ALGORITHM_CLARIFICATION.md
  2. Handed off fix task to claude-code
  3. Documented BMW-MOD-BITS separation
  4. (empty line to finish)
Open issues:
  1. Wait for claude-code to fix validate-signature.pl
  2. Re-sign workspace command files after fix
  3. (empty line to finish)
Next steps:
  1. Test signature validation after fix
  2. Begin Phase 2 integration work
  3. (empty line to finish)
...etc
```

**Step 2**: Checkpoint saved
```
✓ Checkpoint created: context-checkpoints/CHECKPOINT_20251004_143022_elf-complete.md
```

**Step 3**: List to verify
```bash
perl scripts/load-context-checkpoint.pl --list

# Shows:
📌 Named Sessions:
  Session: elf-complete
  Count:   1
  Latest:  2025-10-04 14:30:22
  File:    CHECKPOINT_20251004_143022_elf-complete.md
```

**Step 4**: Load to review (optional)
```bash
perl scripts/load-context-checkpoint.pl --session-name=elf-complete
```

**Step 5**: Use in new chat
1. Start new Claude chat
2. Upload: `context-checkpoints/CHECKPOINT_20251004_143022_elf-complete.md`
3. Message: "Resume from checkpoint"
4. **Result**: Continue with 8k baseline instead of 83k!

---

## Token Savings Example

### Before (this conversation):
- Accumulated baseline: **90k tokens**
- Remaining budget: **100k tokens**
- Can do: ~10k more work before limit

### After checkpoint reset:
- New baseline: **~8k tokens** (checkpoint file)
- Effective budget: **182k tokens**
- Can do: **18x more work!**

---

## Checkpoint Organization

### Named Sessions
Best for:
- Feature work (e.g., "filesystem-implementation")
- Bug fixes (e.g., "elf-validation-fix")
- Documentation phases (e.g., "phase2-integration")
- Major milestones (e.g., "v1.0-release")

**Benefits**:
- Easy to find related checkpoints
- Group by project/feature
- Load latest of specific work

### Unnamed Checkpoints
Best for:
- Quick backups
- End-of-day saves
- Experimental work
- Ad-hoc resets

**Benefits**:
- Fast to create (--auto)
- Timestamped automatically
- No naming decisions needed

---

## Advanced Usage

### Multiple Checkpoints Per Session

```bash
# Start feature work
perl scripts/export-context-checkpoint.pl --session-name=feature-x
# ... work ...

# Mid-feature checkpoint
perl scripts/export-context-checkpoint.pl --session-name=feature-x
# ... more work ...

# Feature complete
perl scripts/export-context-checkpoint.pl --session-name=feature-x

# List all checkpoints for this feature
perl scripts/load-context-checkpoint.pl --list
# Shows: feature-x Count: 3
```

**Load latest** for that session:
```bash
perl scripts/load-context-checkpoint.pl --session-name=feature-x
# Always loads most recent for that session name
```

### Daily Checkpoint Routine

**End of each work day**:
```bash
perl scripts/export-context-checkpoint.pl --auto --session-name=daily-$(date +%Y%m%d)
```

**Start of next day**:
```bash
perl scripts/load-context-checkpoint.pl --list  # Review yesterday's work
perl scripts/load-context-checkpoint.pl         # Load latest
```

### Pre-Token-Limit Checkpoint

When approaching token limit (~70% used):
```bash
perl scripts/export-context-checkpoint.pl --session-name=pre-limit-save
# Complete current thought, then reset chat
```

---

## Best Practices

### When to Create Checkpoints

✅ **DO checkpoint**:
- After completing major features
- Before switching to unrelated task
- When context feels "heavy"
- At ~70% token usage
- After resolving complex issues
- End of work session

❌ **DON'T checkpoint**:
- In middle of debugging
- With unresolved questions
- During active discussion
- Before understanding is complete

### What to Include

✅ **Include**:
- Current state (what/where)
- Completed work (achievements)
- Open issues (what remains)
- Next steps (what's next)
- Key decisions (why/how)
- Critical context (non-obvious info)

❌ **Exclude**:
- Debugging process details
- Implementation discussions
- Resolved confusions
- Dead-end explorations
- Routine status updates

### Session Naming

**Good names**:
- `elf-architecture` - Clear, specific
- `phase2-integration` - Stage-based
- `bug-fix-signatures` - Problem-focused
- `daily-20251004` - Date-based

**Poor names**:
- `work` - Too vague
- `stuff` - No information
- `temp` - Unclear purpose
- `abc123` - Meaningless

---

## Troubleshooting

### No checkpoints found

**Problem**: Directory doesn't exist  
**Solution**: Create first checkpoint (auto-creates directory)

### Can't find session name

**Problem**: Typo or doesn't exist  
**Solution**: Use `--list` to see available names

### Checkpoint too large

**Problem**: Included too much detail  
**Solution**: Focus on state, not process. Use references to files for details.

### Lost checkpoint file

**Problem**: File deleted or moved  
**Solution**: Checkpoints are in git. Use `git log` to find and restore.

---

## Integration with Workflow

### Git Workflow Integration

**After significant commits**:
```bash
git commit -m "Complete feature X"
git push
perl scripts/export-context-checkpoint.pl --session-name=feature-x-done
```

### Pre-Handoff Checkpoint

**Before handing off to claude-code**:
```bash
# Document current state
perl scripts/export-context-checkpoint.pl --session-name=handoff-elf-fix

# Create handoff task
cat > suggestions/outgoing/claude-code/0003.task.md

# Commit both
git add suggestions/ context-checkpoints/
git commit -m "Handoff: task + checkpoint"
```

### Multi-Day Projects

**Day 1 end**:
```bash
perl scripts/export-context-checkpoint.pl --session-name=project-x-day1
```

**Day 2 start** (new chat):
```bash
# Attach: CHECKPOINT_*_project-x-day1.md
# Message: "Resume from checkpoint"
```

**Day 2 end**:
```bash
perl scripts/export-context-checkpoint.pl --session-name=project-x-day2
```

---

## Example Checkpoint Content

See these files for examples:
- `CONTEXT_CHECKPOINT_2025-10-04_EXAMPLE.md` - Manual example
- `context-checkpoints/CHECKPOINT_*_test-checkpoint.md` - Auto-generated

---

## Script Options Reference

### export-context-checkpoint.pl

```
--session-name=NAME   Optional session name
--auto                Non-interactive mode
--help, -h            Show help
--version, -v         Show version
```

### load-context-checkpoint.pl

```
--session-name=NAME   Load specific session
--list                List all checkpoints
--latest              Load latest (default)
--help, -h            Show help
--version, -v         Show version
```

---

## Token Impact

**Real numbers from this session**:

**Without checkpoints**:
```
Current session: 90k tokens accumulated
Can continue:    ~100k tokens remaining
Total capacity:  190k tokens/week
Efficiency:      47% of week used
```

**With checkpoint reset now**:
```
Checkpoint file: ~8k tokens
New baseline:    8k instead of 90k
Savings:         82k tokens (91% reduction!)
Extended work:   ~11x more work possible
```

---

**Status**: ✅ Scripts implemented and tested  
**Ready**: Create checkpoint right now with one command!  
**Benefit**: Continue this work with 90% fewer tokens

---

*"Save state, reset context, multiply capacity."*
