# Dependency Management System

**Automated dependency checking and installation for different session types**

## The Problem

Different workspace tasks require different dependencies:
- **Filesystem work** needs FUSE libraries
- **Network development** needs SSL and networking libraries
- **Learning systems** need SQLite and database libraries
- **Token visualization** needs graphics libraries and gnuplot

Without automation:
- Models spend 500-2000 tokens manually checking if dependencies are installed
- Installation instructions must be re-explained each session
- "Does the system have X?" questions waste context
- Setup friction delays actual work

---

## The Solution

Profile-based dependency management with pre-flight checks and one-command installation.

### Core Command

```bash
bin/deps <command> [args]
```

---

## Available Profiles

| Profile | Description | Use For |
|---------|-------------|---------|
| `base` | Basic workspace dependencies | Always (git, perl, curl, core modules) |
| `filesystem` | FUSE filesystem development | Working on living tree filesystem |
| `network` | Network distribution protocol | Implementing resonant pair distribution |
| `learning` | Learning system with SQLite | Pattern tracking and metrics |
| `visualization` | Token visualization and graphing | Generating token graphs and heatmaps |
| `archive` | Archive system with compression | BASE32 archive implementation |
| `development` | Full development environment | All of the above (meta-profile) |

---

## Quick Start

### Check Dependencies

```bash
# Check specific profile
bin/deps check visualization

# Output:
# 🔍 Checking dependencies for: visualization
#    Token visualization and graphing
#
# Checking APT packages...
#   ✅ gnuplot
#   ❌ imagemagick (missing)
#   ...
#
# ❌ Missing 3 dependencies
# 💡 Install with: bin/deps install visualization
```

### Install Dependencies

```bash
# Install missing dependencies
bin/deps install visualization

# Preview what would be installed (dry run)
bin/deps install visualization --dry-run

# Install all development dependencies
bin/deps install development
```

### List All Profiles

```bash
bin/deps list

# Shows:
# - Available profiles
# - Description of each
# - Package counts (apt, cpan, system)
```

### Check All Profiles

```bash
bin/deps status

# Checks every profile and shows status
```

---

## Commands

### `bin/deps check <profile> [--no-cache]`

Check if dependencies for a profile are installed.

**Options**:
- `--no-cache`: Force fresh check (ignore 24-hour cache)

**Exit codes**:
- `0`: All dependencies installed
- `1`: Missing dependencies

**Examples**:
```bash
bin/deps check base                    # Quick check (uses cache)
bin/deps check filesystem --no-cache   # Force recheck
```

### `bin/deps install <profile> [--dry-run]`

Install missing dependencies for a profile.

**Options**:
- `--dry-run`: Preview what would be installed without actually installing

**Notes**:
- Requires `sudo` for APT packages
- Skips already-installed dependencies
- Clears cache after installation

**Examples**:
```bash
bin/deps install visualization         # Install missing deps
bin/deps install learning --dry-run    # Preview installation
```

### `bin/deps list`

List all available dependency profiles with descriptions.

### `bin/deps status`

Check status of all profiles (except meta-profile `development`).

Useful for getting a complete picture of the system's dependency state.

### `bin/deps clear-cache`

Clear all cached verification results. Forces fresh checks on next run.

---

## Caching System

Dependency checks are cached for 24 hours to improve performance.

### Why Caching?

- Checking every dependency on every invocation is slow
- Most dependencies don't change frequently
- 24-hour cache balances freshness and performance

### Cache Behavior

- First check: Real verification, result cached
- Subsequent checks (< 24h): Return cached result
- After 24 hours: Cache expires, fresh verification
- After `install`: Cache cleared automatically

### Override Cache

```bash
bin/deps check <profile> --no-cache   # Force fresh check
bin/deps clear-cache                   # Clear all caches
```

### Cache Location

- Stored in `.deps/cache/` (gitignored, local only)
- One file per profile: `.deps/cache/<profile>.cache`
- Contains: `OK` or `MISSING`

---

## Profile Definitions

Profiles are defined in `.deps/profiles.yaml` (YAML format).

### Structure

```yaml
profiles:
  profile_name:
    description: "Human-readable description"
    apt:              # APT packages (Ubuntu/Debian)
      - package1
      - package2
    cpan:             # Perl CPAN modules
      - Module::Name
    system:           # System commands to verify
      - command_name
    includes:         # Other profiles to include (meta-profiles)
      - profile1
      - profile2
```

### Example: Visualization Profile

```yaml
visualization:
  description: "Token visualization and graphing"
  apt:
    - gnuplot
    - imagemagick
    - libgd-dev
  cpan:
    - GD::Graph
    - GD::SVG
    - Chart::Gnuplot
  system:
    - gnuplot
    - convert  # ImageMagick
```

### Example: Development Meta-Profile

```yaml
development:
  description: "Full development environment (all profiles)"
  includes:
    - base
    - filesystem
    - network
    - learning
    - visualization
    - archive
```

---

## Adding New Profiles

Edit `.deps/profiles.yaml`:

```yaml
profiles:
  my_custom_profile:
    description: "My custom session type"
    apt:
      - required-apt-package
    cpan:
      - Required::Perl::Module
    system:
      - required-command
```

Then:
```bash
bin/deps list                    # Verify profile appears
bin/deps check my_custom_profile # Check dependencies
```

---

## Token Savings

### Per Session with Dependencies

**Without automation**:
- Check if package installed: ~100-200 tokens per package
- Explain installation: ~300-500 tokens
- Debug missing deps: ~500-1000 tokens
- **Total**: ~500-2000 tokens

**With automation**:
- Run `bin/deps check`: ~50 tokens
- Run `bin/deps install`: ~50 tokens (one line)
- **Total**: ~100 tokens

**Savings**: ~400-1900 tokens per session (80-95% reduction)

### Compound Savings

Applies to ~20-30% of sessions (those requiring specific dependencies).

- Over 100 sessions: **~20k-60k tokens saved**

---

## Integration with Workflows

### Pattern 1: Session Initialization

```bash
# At start of filesystem development session
bin/deps check filesystem
# If missing dependencies:
bin/deps install filesystem

# Now start work with confidence all deps are present
```

### Pattern 2: Pre-Flight Check

```bash
# Before attempting visualization work
if bin/deps check visualization; then
    # Dependencies ready, proceed
    bin/token-graph --generate
else
    # Install first
    bin/deps install visualization
fi
```

### Pattern 3: Fresh Environment Setup

```bash
# New VM or container
bin/deps install development  # Install everything

# Or selective installation
bin/deps install base
bin/deps install visualization
```

---

## Package Managers

### APT (Ubuntu/Debian)

System packages installed via `apt-get`:
- Requires `sudo` permission
- Updates package list before install
- Uses `-y` flag for non-interactive installation

**Commands run**:
```bash
sudo apt-get update -qq
sudo apt-get install -y <packages>
```

### CPAN (Perl Modules)

Perl modules installed via `cpan`:
- Uses `-T` flag (test-less install for speed)
- Filters verbose output for cleaner display
- May require additional system libraries

**Commands run**:
```bash
cpan -T Module::Name
```

### System Commands

Verifies commands are available in PATH:
- Uses `which <command>` to check
- Does not auto-install (must be in apt/cpan sections)
- Useful for validation after installation

---

## Best Practices

### 1. **Check before install**

Always check first to see what's missing:
```bash
bin/deps check visualization   # See what's needed
bin/deps install visualization # Install only if needed
```

### 2. **Use dry-run for unfamiliar profiles**

Preview installation before committing:
```bash
bin/deps install network --dry-run
```

### 3. **Clear cache after manual changes**

If you manually install packages:
```bash
bin/deps clear-cache
bin/deps check <profile> --no-cache
```

### 4. **Use meta-profiles for setup**

For fresh environments, use `development`:
```bash
bin/deps install development
```

### 5. **Define custom profiles for your workflows**

Create profiles for specific project needs in `.deps/profiles.yaml`.

---

## Troubleshooting

### "Missing dependencies" after install

1. Clear cache and recheck:
   ```bash
   bin/deps clear-cache
   bin/deps check <profile> --no-cache
   ```

2. Check if installation actually failed:
   - Review output from `bin/deps install`
   - Look for error messages

3. Manually verify:
   ```bash
   dpkg -l <package>           # Check APT package
   perl -M<Module> -e 1        # Check CPAN module
   which <command>             # Check system command
   ```

### APT installation requires interaction

Some packages require user input. If this happens:
1. Note which package caused the issue
2. Manually install with interaction:
   ```bash
   sudo apt-get install <package>
   ```
3. Re-run `bin/deps install <profile>` to continue

### CPAN module installation fails

1. Check if system libraries are needed:
   - Example: `GD::Graph` needs `libgd-dev`
   - Install APT dependencies first

2. Try manual CPAN install:
   ```bash
   cpan Module::Name
   ```

3. Check for Perl version compatibility

### Cache shows wrong status

Clear and recheck:
```bash
bin/deps clear-cache
bin/deps status
```

---

## Files

| File | Purpose | Gitignored |
|------|---------|------------|
| `.deps/profiles.yaml` | Dependency definitions | No (committed) |
| `.deps/cache/<profile>.cache` | Verification cache files | Yes (local only) |

---

## See Also

- `.deps/profiles.yaml` - Edit to add custom profiles
- `docs/reference/STATUS_AUTOMATION.md` - Status summary system
- `docs/reference/CONTEXT_MANAGEMENT.md` - Persistent todos and research

---

**Version**: 1.0
**Last Updated**: 2025-11-07
**Estimated Token Savings**: ~20k-60k over 100 sessions (400-1900 tokens per session needing deps)
