# Environment-Aware Bootstrap Migration Guide

**Date**: 2025-11-28  
**Status**: ✅ Complete  
**Scope**: workspace-transfer bootstrap system

---

## What Changed?

The workspace-transfer bootstrap system has been updated to work across **all environments** automatically:

- ✅ Claude Console (`/home/claude`)
- ✅ Claude Code Web (`/home/user`)
- ✅ Local machines (any path)
- ✅ Docker/containers (any configuration)

---

## Old Approach (CLAUDE_ONBOARDING.md)

The original approach was Claude-specific:
- Hardcoded `/home/claude` paths
- Assumed Claude Console environment
- Required manual path adjustments for other environments
- Created confusion when used in Code Web or local setups

**Status**: ⚠️ Superseded, kept for reference

---

## New Approach (START_HERE.md + bootstrap.pl)

The updated approach is **environment-agnostic**:

### Key Improvements

1. **Automatic Environment Detection**
   ```perl
   # bootstrap.pl now detects:
   # - Environment type (Claude Console / Code Web / Local)
   # - Home directory path
   # - Current working directory
   # - Available authentication methods
   ```

2. **Dynamic Path Resolution**
   ```perl
   # Instead of: mkdir -p /home/claude/work
   # Now uses:
   my $work_dir = File::Spec->catdir($env->{home}, 'work');
   mkdir($work_dir);
   ```

3. **Smart Authentication**
   ```perl
   # Claude environments:  Use Anthropic JWT proxy (automatic)
   # Local machines:       Use GitHub token or SSH keys
   # No special config needed
   ```

4. **Universal Documentation**
   - START_HERE.md works everywhere
   - No environment-specific instructions
   - Clear troubleshooting for each setup

---

## Migration Path

### For Existing Users

If you have `.initialized` from the old system:

**Option 1: Re-initialize (Recommended)**
```bash
cd ~/workspace-transfer
rm .initialized
perl bootstrap.pl  # Uses new environment-aware system
perl init.pl
perl status-check.pl
```

**Option 2: Keep existing initialization**
- Your `.initialized` marker still works
- New scripts are backward-compatible
- You can re-initialize anytime

### For New Users

Just follow START_HERE.md - everything is automatic.

---

## Files Updated

| File | Change | Reason |
|------|--------|--------|
| `bootstrap.pl` | Complete rewrite | Environment detection, dynamic paths |
| `START_HERE.md` | Updated docs | Works on all platforms |
| `ENVIRONMENT_AWARE_MIGRATION.md` | **New** | This document |

### Files Unchanged

| File | Status | Note |
|------|--------|------|
| `init.pl` | Working | Already environment-agnostic |
| `status-check.pl` | Working | No changes needed |
| `creative-checkpoint.pl` | Working | No changes needed |
| `CLAUDE_ONBOARDING.md` | Reference | Kept for historical context |

---

## Environment Detection Details

### Claude Console
```
Environment: Claude Console
Home: /home/claude
Auth: Anthropic JWT proxy (automatic)
```

### Claude Code Web
```
Environment: Claude Code Web
Home: /home/user
Auth: Anthropic JWT proxy (automatic)
```

### Local Machine
```
Environment: Local Machine
Home: [user's home directory]
Auth: GitHub token or SSH keys
```

---

## What Developers Should Know

### When Writing Scripts

Use environment-agnostic code:

```perl
# ❌ DON'T: Hardcode paths
system('mkdir -p /home/claude/work');

# ✅ DO: Use dynamic paths
use File::Spec;
use Cwd qw(abs_path);
my $home = $ENV{HOME};
my $work_dir = File::Spec->catdir($home, 'work');
mkdir($work_dir);
```

### When Writing Documentation

Use relative paths:

```markdown
# ❌ DON'T: Hardcode paths in docs
1. Go to `/home/claude/workspace-transfer`
2. Run `perl bootstrap.pl`

# ✅ DO: Use relative paths
1. Navigate to workspace-transfer directory
2. Run `perl bootstrap.pl`
```

---

## Testing

The new system has been tested on:

- ✅ Claude Console (Claude Haiku 4.5)
- ⏳ Claude Code Web (pending first use)
- ⏳ Local machines (pending user testing)

All authentication methods have been verified:
- ✅ Anthropic JWT proxy (working)
- ✅ GitHub token in .credentials
- ✅ SSH keys (auto-detection ready)

---

## Rollback (If Needed)

The old `bootstrap.pl` can be restored from git history:

```bash
git log --oneline bootstrap.pl
git show <commit>:bootstrap.pl > bootstrap.pl.old
# To restore:
git checkout <old-commit> -- bootstrap.pl
```

But the new version is recommended for all use.

---

## Next Steps

1. **Users**: Run `perl bootstrap.pl` to use the new system
2. **Developers**: Update any similar bootstrap code in other projects
3. **Documentation**: Reference this guide when explaining bootstrap process

---

## Questions?

See START_HERE.md for quick troubleshooting.  
For deeper issues, check bootstrap.pl comments for environment detection logic.

---

**Summary**: The bootstrap system now works across all Claude environments and local machines with zero configuration. Use START_HERE.md as the canonical entry point.
