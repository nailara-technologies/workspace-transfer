# Protocol-7 Dependency Synchronization System

**Keeping Protocol-7 and workspace-transfer dependencies in sync**

---

## Overview

The Protocol-7 repository contains a comprehensive dependency tracking system that serves as the **single source of truth** for all project dependencies. The `bin/p7-deps` script reads this information and generates YAML files that can be used for:

1. **Production system installations** - Complete dependency lists for deploying Protocol-7
2. **Workspace-transfer profile updates** - Keep bin/deps synchronized with Protocol-7 reality
3. **Zenka-specific dependencies** - Track which dependencies each zenka (component) requires

---

## Dependency Sources in Protocol-7

### 1. Base Module Dependencies

**File**: `modules/base.known_dependencies`

Contains a Perl hash mapping 82+ CPAN modules to their:
- Debian APT package equivalents
- CPAN installation names
- Platform-specific mappings

**Example**:
```perl
'JSON::XS' => {
    'debian' => ['libjson-xs-perl'],
    'cpan'   => 'JSON::XS'
},
```

### 2. Zenka-Specific Perl Dependencies

**Directory**: `configuration/zenki/*/pm-dep/`

Zero-byte files indicate which CPAN modules each zenka (component) requires.

**Example**:
```
configuration/zenki/v7/pm-dep/Event
configuration/zenki/v7/pm-dep/IO__AIO  (:: replaced with __)
```

### 3. Zenka-Specific OS Dependencies

**Directory**: `configuration/zenki/*/os-dep/`

**Subdirectories**:
- `debian/` - Debian APT packages required
- `binary/` - System commands required (cpanm, gcc, etc.)

**Example**:
```
configuration/zenki/v7/os-dep/debian/libc6-dev
configuration/zenki/v7/os-dep/binary/gcc
```

---

## The `bin/p7-deps` Script

Located in: `/home/user/protocol-7/bin/p7-deps`

### Commands

#### `bin/p7-deps list`
List all dependencies from all sources with breakdown by type.

**Output**:
- Total CPAN modules from base.known_dependencies
- Zenka PM dependencies with which zenka requires them
- Debian packages with which zenka requires them
- Binary commands with which zenka requires them

#### `bin/p7-deps check [profile]`
Aggregate and verify dependencies for a profile (default: protocol7_full).

**Shows**:
- Total count of CPAN modules needed
- Total count of Debian packages needed
- Sorted lists of each

#### `bin/p7-deps generate [file]`
Generate YAML file from Protocol-7 sources.

**Creates**: `.deps/protocol7_full.yaml` with aggregated dependencies

#### `bin/p7-deps update-workspace`
Show instructions for updating workspace-transfer profiles.

---

## Workflow: Keeping Dependencies in Sync

### When Dependencies Change in Protocol-7

**Scenario**: A developer updates `base.known_dependencies` or adds new zenka dependencies.

#### Step 1: Generate Updated YAML in Protocol-7
```bash
cd /home/user/protocol-7
bin/p7-deps generate
```

**Output**: `.deps/protocol7_full.yaml`

#### Step 2: Review Generated YAML
```bash
cat .deps/protocol7_full.yaml | head -50
```

Should show all CPAN modules and Debian packages aggregated from:
- base.known_dependencies
- All zenka pm-dep directories
- All zenka os-dep/debian directories

#### Step 3: Update workspace-transfer Profiles

**Copy** the APT and CPAN sections to:
```
/home/user/workspace-transfer/.deps/profiles.yaml
```

In the `protocol7_full` profile section:
```yaml
protocol7_full:
  description: "Protocol-7 complete development environment"
  apt:
    # Copy from generated .deps/protocol7_full.yaml
    - libevent-perl
    - libjson-xs-perl
    # ... rest of packages
  cpan:
    # Copy from generated .deps/protocol7_full.yaml
    - Event
    - JSON::XS
    # ... rest of modules
```

#### Step 4: Test Updated Profiles

```bash
cd /home/user/workspace-transfer
bin/deps check protocol7_full --no-cache
```

Should show all dependencies present if installed, or count of missing dependencies.

#### Step 5: Commit Both Repositories

**In protocol-7**:
```bash
git add .deps/protocol7_full.yaml modules/base.known_dependencies
git commit -m "update: Dependency changes for [feature/zenka name]"
git push origin base
```

**In workspace-transfer**:
```bash
git add .deps/profiles.yaml
git commit -m "update: Sync protocol7_full profile with Protocol-7 dependencies"
git push origin base
```

---

## Production System Installations

For production systems, use the generated YAML as the source of truth:

### Option 1: Use workspace-transfer bin/deps

```bash
# On target system
bin/deps install protocol7_full
```

This installs everything defined in the current profile.

### Option 2: Use Protocol-7's p7-deps Output Directly

```bash
# Generate list from Protocol-7
bin/p7-deps check protocol7_full > /tmp/p7-deps.txt

# Install on target system (manual)
apt-get install [packages from os-dep]
cpanm [modules from pm-dep]
```

### Option 3: Automate with Generated YAML

Parse `.deps/protocol7_full.yaml` and programmatically install:

```bash
# Extract APT packages
grep -A 100 "apt:" .deps/protocol7_full.yaml | grep "^    - " | sed 's/.*- //'

# Extract CPAN modules
grep -A 100 "cpan:" .deps/protocol7_full.yaml | grep "^    - " | sed 's/.*- //'
```

---

## Dependency Architecture

### Flow Diagram

```
protocol-7/
├── modules/
│   └── base.known_dependencies (82 CPAN modules with mappings)
│
├── configuration/zenki/*/
│   ├── pm-dep/                   (CPAN requirements per zenka)
│   │   └── [Module__Name]        (zero-byte files)
│   │
│   └── os-dep/
│       ├── debian/               (Debian packages per zenka)
│       │   └── [package-name]    (zero-byte files)
│       │
│       └── binary/               (Binary commands per zenka)
│           └── [command]         (zero-byte files)
│
└── bin/p7-deps                    (Aggregation script)
    ↓
    Generates .deps/protocol7_full.yaml
    ↓
workspace-transfer/.deps/profiles.yaml
    ↓
bin/deps (dependency manager)
```

---

## Key Metrics

As of 2025-11-16:

| Metric | Count |
|--------|-------|
| Base CPAN modules | 82 |
| Zenka PM dependencies | 134 total |
| Debian packages | 77 total |
| Binary requirements | ~8-10 |
| Total zenkas | 80+ |

---

## Benefits of This System

1. **Single Source of Truth**: Protocol-7's base.known_dependencies is authoritative
2. **Zenka Transparency**: See exactly which dependencies each component needs
3. **Production Ready**: Generated YAML is always production-deployable
4. **Automated Sync**: bin/p7-deps updates can be automated in CI/CD
5. **Reproducibility**: Same dependencies everywhere - dev, CI, and production
6. **Maintainability**: One place to update dependency mappings

---

## Troubleshooting

### Generated YAML is Missing Modules

**Cause**: Zenka pm-dep files not updated when code changes

**Solution**:
```bash
# Check which zenkas have which dependencies
bin/p7-deps list | grep "Zenki PM"

# Verify pm-dep directories exist
ls -la configuration/zenki/[zenka-name]/pm-dep/
```

### Workspace-transfer Profile Out of Sync

**Cause**: Protocol-7 dependencies updated but workspace profiles not refreshed

**Solution**:
```bash
# In protocol-7
bin/p7-deps generate

# In workspace-transfer
# Manually update .deps/profiles.yaml with new lists
# Or use a sync script if you create one
```

### Missing Debian Package in APT

**Cause**: Debian package name may have changed in newer distributions

**Solution**:
1. Check base.known_dependencies mapping
2. Test APT package availability: `apt-cache search [package]`
3. Update mapping if package renamed
4. Regenerate YAML

---

## Extending the System

### Adding a New Zenka's Dependencies

1. Create pm-dep directory:
```bash
mkdir -p configuration/zenki/[new-zenka]/pm-dep
mkdir -p configuration/zenki/[new-zenka]/os-dep/{debian,binary}
```

2. Add dependency files (zero-byte):
```bash
touch configuration/zenki/[new-zenka]/pm-dep/Module::Name
touch configuration/zenki/[new-zenka]/os-dep/debian/libname-perl
touch configuration/zenki/[new-zenka]/os-dep/binary/gcc
```

3. Regenerate and sync:
```bash
bin/p7-deps generate
# ... sync to workspace-transfer ...
```

### Adding to base.known_dependencies

For modules used across multiple zenkas, add to base.known_dependencies:

```perl
'Your::Module' => {
    'debian' => ['libpkg-name-perl'],  # or []if no Debian pkg
    'cpan'   => 'Your::Module'
},
```

Then regenerate:
```bash
bin/p7-deps generate
```

---

## Integration with CI/CD

### GitHub Actions Example

```yaml
- name: Sync Protocol-7 Dependencies
  run: |
    cd ../protocol-7
    bin/p7-deps generate
    cp .deps/protocol7_full.yaml ../workspace-transfer/.deps/

- name: Verify Sync
  run: |
    cd workspace-transfer
    bin/deps check protocol7_full --no-cache
```

---

**Version**: 1.0
**Last Updated**: 2025-11-16
**Related Files**:
- `/home/user/protocol-7/bin/p7-deps`
- `/home/user/protocol-7/modules/base.known_dependencies`
- `/home/user/workspace-transfer/.deps/profiles.yaml`
- `docs/reference/DEPENDENCY_MANAGEMENT.md`
