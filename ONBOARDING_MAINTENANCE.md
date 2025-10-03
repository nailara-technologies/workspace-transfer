# Onboarding Documentation Maintenance

**Purpose**: Keep onboarding instructions accurate as work progresses

---

## The Pattern

Onboarding documents (`CLAUDE_ONBOARDING.md`, `START_HERE.md`, etc.) can become outdated when work gets completed but documentation isn't updated. This causes confusion for future sessions.

---

## Check First, Then Act

When starting a new session:

1. **Before following onboarding instructions**, check if the work is already done:
   ```bash
   # Look for completion artifacts
   ls -la incoming/          # Are archives still there?
   ls -la other/archive*     # Was inventory already generated?
   git log --oneline -20     # Recent commit history
   ```

2. **Ask the user** if unsure:
   ```bash
   echo "Task X appears completed - should I skip to next phase?" > QUESTION
   git add QUESTION && git commit -m "Question about task status" && git push
   ```

3. **Update documentation** after confirming:
   - Mark completed phases as `✅ COMPLETED (date)`
   - Reference where results are located
   - Remove detailed instructions if no longer needed
   - Keep brief summary for reference

---

## Case Study: Phase 0 Archives (October 2025)

### What Happened

- `CLAUDE_ONBOARDING.md` said: "Extract 20 archives from incoming/"
- Reality: Archives already extracted on October 2nd
- Evidence: `other/archive-inventory-report.md` existed with results
- Confusion: New Claude started to follow outdated instructions

### Resolution

1. User confirmed: "the 20 files are long processed already"
2. Checked evidence: Found archive-inventory-report.md dated Oct 2
3. Updated CLAUDE_ONBOARDING.md:
   - Marked Phase 0 as completed
   - Referenced existing report
   - Removed detailed extraction instructions
4. Committed: "Update CLAUDE_ONBOARDING.md: Mark Phase 0 as completed"

### Time Saved

Instead of:
- Extracting 155 files from 20 archives
- Running SHA256 comparisons
- Generating duplicate report

Did:
- Verified completion (30 seconds)
- Updated documentation (2 minutes)
- Moved to next work

---

## Successful Method Template

When you find work is already done:

```bash
# 1. Verify completion
ls -la [expected output location]
cat [completion report if exists]

# 2. Update onboarding doc
# Edit CLAUDE_ONBOARDING.md or relevant file:
# - Change "Do this task" to "✅ COMPLETED (date)"
# - Add "Results: [location]"
# - Keep 1-2 line summary
# - Remove step-by-step instructions

# 3. Commit the update
git add [onboarding file]
git commit -m "Mark [task] as completed - already done on [date]"
git push origin base

# 4. Move forward
# Continue with actual next task
```

---

## Warning Signs of Outdated Instructions

- Instructions reference files/directories that don't exist
- Expected outputs already present with old timestamps
- Git history shows work completed weeks ago
- User says "that's already done"

---

## Where to Check for Completion Evidence

- `other/` directory - old reports and artifacts
- `archive/` directory - completed work archives
- Git log - commit messages about completion
- Existing reports with dates/timestamps
- README files with status updates

---

## Best Practice

**Don't blindly follow onboarding instructions** - verify they're still relevant first. When in doubt, ask the user via QUESTION file rather than duplicating completed work.

---

## Update This Document

If you discover other patterns of outdated instructions:

1. Add case study section above
2. Update "Warning Signs" list
3. Commit changes
4. This creates institutional memory

---

**Last Updated**: October 3, 2025  
**Status**: Active maintenance pattern  
**Related**: CLAUDE_ONBOARDING.md, START_HERE.md, QUESTION_ANSWER_SYSTEM.md
