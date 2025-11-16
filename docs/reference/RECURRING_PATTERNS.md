# Recurring Session Patterns - Automated Reminders

**Token-efficient automation for common session patterns**

These patterns happen frequently across sessions. Documenting them here saves tokens by:
1. Model doesn't need to remember each time
2. Scripts automate the repetitive parts
3. Documentation serves as instant reference

---

## Git Operations

### Pushing to Base Branch

**Pattern**: Push completed work directly to base branch with full write access

**Direct Approach** (recommended - as of 2025-11-16):
```bash
# Checkout and push directly to base
git checkout base
git push origin base

# Or cherry-pick specific commits from feature branches:
git checkout base
git cherry-pick <commit-hash>
git push origin base
```

**Automated approach** (still available):
```bash
# From your feature branch, use the helper script
bin/push-to-base --cleanup-branch <feature-branch-name>
```

**Manual process** (legacy - for reference):
```bash
# 1. Configure remote with PAT
git remote set-url origin https://${GITHUB_PAT}@github.com/nailara-technologies/workspace-transfer.git

# 2. Checkout base
git checkout base

# 3. Merge feature branch
git merge <feature-branch> --no-edit

# 4. Push to base
git push origin base

# 5. Delete feature branch
git branch -d <feature-branch>
git push origin --delete <feature-branch>
```

**Why this approach**:
- **Full write access to base branch** - no need for feature branches
- Cleaner git history with direct base commits
- Faster workflow - eliminates merge/delete steps
- PAT is already configured in the remote URL

**💡 Pro Tip - Direct GitHub Operations**:
With reconfigured remotes and full base branch access, you can:
- Push directly to base: `git checkout base && git push origin base`
- Cherry-pick commits: `git cherry-pick <commit> && git push origin base`
- Use GITHUB_PAT in environment: `https://${GITHUB_PAT}@github.com/...`
- GitHub CLI: `gh auth login --with-token <<< "$GITHUB_PAT"`
- API calls: `curl -H "Authorization: token $GITHUB_PAT"`

No feature branches required - GITHUB_PAT provides full write access to the default branch!

---

### Branch Naming Convention

**Pattern**: No longer required for feature branches (direct base branch access available)

**Historical Context**: Feature branches previously required `claude/` prefix with session ID
- **Old example**: `claude/init-workspace-transfer-011CUsZbZ39Enbpofu88zCwS`
- **Previous reason**: Server-side enforcement prevented 403 errors

**Current Approach** (as of 2025-11-16):
- Work directly on `base` branch with full write access
- Feature branches optional - use only for experimentation or branch protection
- No naming convention required for direct base branch commits

**💡 If you need feature branches**:
- Still supported: `bin/push-to-base --cleanup-branch <name>`
- Still available: automated naming via `bootstrap.pl`
- But not required: GITHUB_PAT provides direct base write access

---

## Session Workflow

### Standard Session Pattern

**Most sessions follow this flow**:

1. **Initialize**
   ```bash
   bin/init                    # ~500 tokens output
   bin/session-tokens reset    # Start tracking
   ```

2. **Work**
   ```bash
   # After each major task
   bin/track-tokens <task> <tokens>
   bin/session-tokens add <tokens>
   ```

3. **Check health periodically**
   ```bash
   bin/suggest-handover
   ```

4. **Commit and push**
   ```bash
   git add -A
   git commit -m "Description"
   bin/push-to-base --cleanup-branch <current-branch>
   ```

5. **Hand over (if recommended)**
   ```bash
   bin/session-tokens reset
   # Document state for next session
   # Start fresh session
   ```

**Token cost**: ~1-2k tokens total for automation
**Manual cost**: ~5-10k tokens explaining each time

---

## Authentication Patterns

### GitHub PAT Authentication

**Pattern**: Every push requires PAT in remote URL

**Where PAT is stored**: `GITHUB_PAT` environment variable

**Automation**: `bin/push-to-base` configures this automatically

**Manual check** (if needed):
```bash
echo $GITHUB_PAT  # Should show: ghp_...
```

**Why automated**: Prevents 403 errors, saves explaining auth every session

---

### Repository Access

**Pattern**: workspace-transfer is public read, requires auth for write

**Remote URL formats**:
- ❌ `http://local_proxy@127.0.0.1:49071/...` - Can't push to base
- ✅ `https://${GITHUB_PAT}@github.com/...` - Can push to base

**Automation**: Scripts handle URL switching automatically

---

## Token Tracking Patterns

### Initialization Tracking

**Pattern**: Track token usage right after `bin/init`

```bash
bin/init
# Count tokens in output (or estimate ~2400)
bin/track-tokens init 2400
bin/session-tokens add 2400
```

**Why**: Establishes baseline, enables trend detection

---

### Task Tracking

**Pattern**: Track after each substantial task

```bash
# After development work
bin/track-tokens development 8500
bin/session-tokens add 8500

# After documentation
bin/track-tokens documentation 3200
bin/session-tokens add 3200
```

**Why**: Detects efficiency improvements and degradation

---

### Handover Checks

**Pattern**: Check handover recommendation periodically

```bash
bin/suggest-handover
```

**When to check**:
- Every 20-30k tokens added
- After completing major milestones
- Before starting new large tasks
- If tasks seem to be taking more tokens

**Why**: Prevents context overflow and efficiency degradation

---

## File Organization Patterns

### Where Things Go

**Pattern**: Files belong in specific locations

| File Type | Location | Why |
|-----------|----------|-----|
| Scripts | `bin/` | All executables centralized |
| Documentation | `docs/` | Organized by category |
| Protocol-7 staging | `protocol7-staging/` | Transfer to protocol-7 |
| Archived work | `archive/` | Historical reference |
| Session data | `.token-stats.log`, `.current-session` | Gitignored, local only |

**Automation**: Structure enforced by existing layout

**Why**: Prevents "where should this go?" questions every session

---

## Documentation Patterns

### Commit Messages

**Pattern**: Descriptive multi-line commits with context

**Template**:
```
<type>: <short description>

<detailed explanation>

## <section>
<details>

## <section>
<more details>
```

**Types**: feat, fix, refactor, docs, test, chore

**Why**: Git history serves as documentation, saves re-explaining later

---

### STATUS.md Updates

**Pattern**: Update STATUS.md when completing work

**What to update**:
- Move completed items to "Recently Completed"
- Add new active systems
- Update priorities if changed

**When**: Before committing major features

**Why**: Next session knows immediately what's done

---

## Error Patterns

### Common Issues and Fixes

| Error | Cause | Fix | Automation |
|-------|-------|-----|-----------|
| 403 on push | Wrong remote URL | Use `bin/push-to-base` | Automatic |
| Context overflow | Session too long | Run `bin/suggest-handover` | Automatic detection |
| Token creep | Inefficiency drift | Check `bin/token-report --trends` | Automatic tracking |
| Branch naming | Doesn't start with `claude/` | Let `bootstrap.pl` create | Automatic |

---

## Best Practices (Automated)

### What Scripts Handle For You

✅ **PAT authentication** - Configured automatically
✅ **Branch naming** - Generated correctly
✅ **Token tracking** - Statistical analysis automated
✅ **Handover suggestions** - Context health monitored
✅ **Efficiency detection** - Improvements celebrated, regressions alerted
✅ **Push workflow** - One command instead of many

### What You Still Do

📝 **Choose task names** - For tracking
📝 **Estimate tokens** - For tracking (or count manually)
📝 **Write commit messages** - Describe your work
📝 **Update STATUS.md** - Document major changes
📝 **Decide when to hand over** - Based on suggestions

---

## Token Savings Per Session

| Pattern | Manual Tokens | Automated Tokens | Savings |
|---------|--------------|------------------|---------|
| Git push workflow | ~500 | ~50 | 450 |
| Init explanation | ~300 | ~100 | 200 |
| Token tracking setup | ~400 | ~100 | 300 |
| Handover decision | ~300 | ~50 | 250 |
| Error recovery | ~500 | ~100 | 400 |
| **Total per session** | **~2000** | **~400** | **~1600** |

**Over 100 sessions**: ~160,000 tokens saved

---

## Future Automation Opportunities

Patterns that could be further automated:

- [ ] Auto-count tokens in command outputs
- [ ] Auto-track after bin/init runs
- [ ] Auto-suggest commit messages from git diff
- [ ] Auto-update STATUS.md from commits
- [ ] Auto-detect task types from file changes
- [ ] Integration hooks (run tracking automatically)

---

## Summary

**Recurring patterns are documented here so the model doesn't need to remember**:

✅ Git workflows → `bin/push-to-base`
✅ Session tracking → `bin/session-tokens`, `bin/track-tokens`
✅ Handover logic → `bin/suggest-handover`
✅ Auth configuration → Automated in scripts
✅ File organization → Documented structure

**Result**: Each session starts with instant knowledge of workflows, saving 1-2k tokens on setup overhead.

---

**Version**: 1.0
**Last Updated**: 2025-11-07
**See also**: TOKEN_TRACKING_GUIDE.md, STATUS.md
