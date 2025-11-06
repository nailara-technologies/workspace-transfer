# Protocol-7 Transfer Workflow

## Overview

The workspace-transfer repository provides a staging area for Protocol-7 development work before committing to the main Protocol-7 repository.

This enables:
- **Isolated experimentation** without affecting protocol-7
- **Collaborative review** in workspace-transfer before merge
- **Atomic commits** in protocol-7 (complete features, not WIP)
- **Multi-AI coordination** via staging area

---

## Repository Structure

```
/home/user/  (or any parent directory)
├── workspace-transfer/
│   ├── protocol7-staging/     # ← Work here first
│   │   ├── modules/
│   │   ├── bin/
│   │   ├── configuration/
│   │   ├── data/
│   │   └── .manifest.yaml     # ← Defines transfers
│   ├── scripts/
│   │   └── transfer-to-protocol7.pl  # ← Transfer script
│   └── (other workspace-transfer content)
│
└── protocol-7/                 # ← Transfer here when ready
    ├── modules/
    ├── bin/
    ├── configuration/
    └── (protocol-7 structure)
```

---

## Workflow Steps

### 1. Stage Your Work

Develop in `workspace-transfer/protocol7-staging/`:

```bash
cd /home/user/workspace-transfer/protocol7-staging

# Create a new module
vim modules/httpd.async_handler

# Add documentation
vim data/yaml/docs/async-handler-guide.yaml

# Create a development tool
vim bin/dev/test-async

# Make scripts executable
chmod +x bin/dev/test-async
```

---

### 2. Update the Manifest

Edit `.manifest.yaml` to define what gets transferred:

```bash
vim protocol7-staging/.manifest.yaml
```

Add transfer entries:

```yaml
transfers:
  - source: "modules/httpd.async_handler"
    dest: "modules/httpd.async_handler"
    action: "copy"
    description: "Async HTTP request handler"
    preserve_signatures: true

  - source: "data/yaml/docs/async-handler-guide.yaml"
    dest: "data/yaml/docs/async-handler-guide.yaml"
    action: "copy"
    description: "Documentation for async handler"

  - source: "bin/dev/test-async"
    dest: "bin/dev/test-async"
    action: "copy"
    chmod: "0755"
    description: "Testing tool for async functionality"
```

---

### 3. Preview the Transfer (Dry Run)

Always preview first:

```bash
cd /home/user/workspace-transfer
./scripts/transfer-to-protocol7.pl --dry-run
```

Output shows:
- What files will be transferred
- Where they'll go
- What action will be performed
- Which files already exist (will be backed up)

---

### 4. Transfer Files

Choose transfer mode:

#### Interactive Mode (Recommended)
```bash
./scripts/transfer-to-protocol7.pl --interactive
```

Confirms each file before transfer. Safe for first-time transfers.

#### Auto Mode (Batch Transfer)
```bash
./scripts/transfer-to-protocol7.pl --auto
```

Transfers all files without confirmation. Use when confident.

---

### 5. Review in Protocol-7

Check what was transferred:

```bash
cd ../protocol-7
git status
git diff
```

Review:
- ✅ Files are in correct locations
- ✅ Content is correct
- ✅ Permissions are set (especially scripts)
- ✅ No unintended changes

---

### 6. Commit in Protocol-7

```bash
cd ../protocol-7

# Stage transferred files
git add modules/httpd.async_handler
git add data/yaml/docs/async-handler-guide.yaml
git add bin/dev/test-async

# Commit with descriptive message
git commit -m "feat: Add async HTTP request handler

Implement non-blocking async request handler for httpd zenka.

- New module: httpd.async_handler
- Documentation: async-handler-guide.yaml
- Testing tool: bin/dev/test-async

Developed and tested in workspace-transfer staging area."

# Push to remote
git push origin base
```

---

### 7. Clean Up Staging (Optional)

If you used `action: move` in manifest, files are already removed.

For `action: copy`, clean up manually:

```bash
cd ../workspace-transfer/protocol7-staging

# Remove transferred files
rm modules/httpd.async_handler
rm data/yaml/docs/async-handler-guide.yaml
rm bin/dev/test-async

# Or archive them
mkdir -p ../archive/transferred/$(date +%Y-%m-%d)
mv modules/httpd.async_handler ../archive/transferred/$(date +%Y-%m-%d)/
```

---

## Transfer Actions

### copy
- **Behavior**: Copy file from staging to protocol-7
- **Source**: Remains in staging
- **Use**: Default action, safest option
- **Example**: Documentation, modules you might iterate on

### move
- **Behavior**: Move file (delete from staging after copy)
- **Source**: Removed from staging
- **Use**: One-time transfers, completed work
- **Example**: Final implementations moving to protocol-7

### sync
- **Behavior**: Copy only if source is newer
- **Source**: Remains in staging
- **Use**: Keeping files synchronized between repos
- **Example**: Shared configuration that might update

---

## Safety Features

### Automatic Backups

Before overwriting existing files, the script creates backups:

```
protocol-7/modules/httpd.async_handler
protocol-7/modules/httpd.async_handler.bak  ← backup
```

Configure in `.manifest.yaml`:
```yaml
options:
  backup_enabled: true
  backup_suffix: ".bak"
```

### Git Status Check

Script warns if protocol-7 has uncommitted changes:

```
⚠️  Target repository has uncommitted changes:
 M modules/httpd.other_file
?? new-file.txt

Continue anyway? [y/N]
```

### Dry Run Mode

Always available to preview without changes:

```bash
./scripts/transfer-to-protocol7.pl --dry-run
```

Shows exactly what would happen.

---

## Common Workflows

### Single File Transfer

```bash
# 1. Create file in staging
vim protocol7-staging/modules/test.function

# 2. Add to manifest
echo "transfers:
  - source: modules/test.function
    dest: modules/test.function
    action: copy" > protocol7-staging/.manifest.yaml

# 3. Transfer
./scripts/transfer-to-protocol7.pl --dry-run
./scripts/transfer-to-protocol7.pl --auto

# 4. Commit in protocol-7
cd ../protocol-7
git add modules/test.function
git commit -m "feat: Add test function"
git push
```

### Batch Transfer (Multiple Files)

```yaml
# protocol7-staging/.manifest.yaml
transfers:
  - source: "modules/httpd.handler1"
    dest: "modules/httpd.handler1"
    action: "copy"

  - source: "modules/httpd.handler2"
    dest: "modules/httpd.handler2"
    action: "copy"

  - source: "documentation/httpd-handlers.md"
    dest: "documentation/httpd-handlers.md"
    action: "copy"
```

```bash
./scripts/transfer-to-protocol7.pl --interactive
# Review each file, confirm/skip as needed
```

### Update Existing File

When updating an existing protocol-7 file:

```bash
# 1. Copy current version to staging
cp ../protocol-7/modules/httpd.existing protocol7-staging/modules/httpd.existing

# 2. Modify in staging
vim protocol7-staging/modules/httpd.existing

# 3. Test changes
perl -c protocol7-staging/modules/httpd.existing

# 4. Update manifest
# (add transfer entry)

# 5. Transfer with backup
./scripts/transfer-to-protocol7.pl --interactive
# ⚠️  Destination exists
# 📦 Backed up to: httpd.existing.bak
# ✅ Copied

# 6. Review diff in protocol-7
cd ../protocol-7
git diff modules/httpd.existing

# 7. If good, commit
git add modules/httpd.existing
git commit -m "refactor: Improve httpd.existing implementation"

# 8. If bad, restore backup
mv modules/httpd.existing.bak modules/httpd.existing
```

---

## Integration with Workspace

### Session Handover

When creating session handovers, mention staged work:

```yaml
# session-handover-template.yaml
task_specific_context:
  files_worked_on:
    - path: "protocol7-staging/modules/httpd.new_feature"
      changes: "Implemented async handling"
      status: "Ready for transfer to protocol-7"

next_steps:
  - "[ ] Review protocol7-staging/.manifest.yaml"
  - "[ ] Run transfer script with --dry-run"
  - "[ ] Transfer to protocol-7"
  - "[ ] Commit in protocol-7 repo"
```

### Quick Status

Add to quick-start.yaml or QUICK_STATUS.md:

```yaml
protocol7_staging:
  pending_transfers: 3
  files:
    - "modules/httpd.async_handler (ready)"
    - "data/yaml/docs/async-guide.yaml (ready)"
    - "bin/dev/test-tool (needs review)"
```

---

## Troubleshooting

### "Target repository not found"

```bash
# Check both repos exist and are side-by-side
ls -la /home/user/
# Should see: protocol-7/ and workspace-transfer/

# If protocol-7 missing, clone it
cd /home/user
git clone https://github.com/nailara-technologies/protocol-7
```

### "Manifest file not found"

```bash
# Create initial manifest
cat > protocol7-staging/.manifest.yaml << 'EOF'
transfers: []
options:
  backup_enabled: true
EOF
```

### "YAML::Tiny not found"

```bash
# Install Perl module
cpan YAML::Tiny
# or
sudo apt-get install libyaml-tiny-perl
```

### Permissions Issues

```bash
# Make script executable
chmod +x scripts/transfer-to-protocol7.pl

# Fix staging directory permissions
chmod -R u+rw protocol7-staging/
```

### Git Conflicts

If transfer creates conflicts:

```bash
cd ../protocol-7
git status
# Resolve conflicts manually
vim <conflicted-file>
git add <conflicted-file>
git commit
```

---

## Best Practices

### ✅ DO

1. **Preview first**: Always run `--dry-run` before actual transfer
2. **Small batches**: Transfer related files together
3. **Test in staging**: Validate before transferring
4. **Descriptive commits**: Explain what and why in protocol-7 commits
5. **Keep manifest updated**: Document all planned transfers

### ❌ DON'T

1. **Don't edit protocol-7 directly**: Stage in workspace-transfer first
2. **Don't transfer WIP**: Only move complete, tested code
3. **Don't skip dry-run**: Always preview first
4. **Don't forget backups**: Keep `backup_enabled: true`
5. **Don't batch unrelated changes**: Transfer logically grouped files

---

## Advanced Usage

### Custom Post-Transfer Hooks

```yaml
# .manifest.yaml
post_transfer_hooks:
  - command: "perl ../protocol-7/bin/dev/update-version"
    when: "modules transferred"

  - command: "git -C ../protocol-7 status"
    when: "always"
```

### Conditional Transfers

```yaml
transfers:
  - source: "modules/httpd.dev_only"
    dest: "modules/httpd.dev_only"
    action: "copy"
    condition: "development"  # Only transfer in dev mode
```

### Directory Transfers

```yaml
transfers:
  - source: "modules/httpd.*"  # Wildcard
    dest: "modules/"
    action: "copy"
    description: "All httpd modules"
```

---

## Script Reference

### Command Line Options

```bash
--dry-run       # Preview without changes
--interactive   # Confirm each transfer (default)
--auto          # Transfer all without confirmation
-h, --help      # Show help message
```

### Exit Codes

- `0`: Success (all transfers completed)
- `1`: Failure (one or more transfers failed)

### Output Colors

- 🔵 Blue: Informational
- 🟢 Green: Success
- 🟡 Yellow: Warning / Skip
- 🔴 Red: Error / Failure

---

## Examples

### Example 1: Single Module

```bash
# Create module in staging
cat > protocol7-staging/modules/test.hello << 'EOF'
## [:< ##
# name = test.hello
say "Hello from workspace-transfer!";
EOF

# Add to manifest
vim protocol7-staging/.manifest.yaml
# (add transfer entry)

# Transfer
./scripts/transfer-to-protocol7.pl --dry-run
./scripts/transfer-to-protocol7.pl --auto

# Commit
cd ../protocol-7
git add modules/test.hello
git commit -m "feat: Add test.hello module"
```

### Example 2: Module + Documentation

```yaml
# .manifest.yaml
transfers:
  - source: "modules/weather.api_v2"
    dest: "modules/weather.api_v2"
    action: "copy"
    description: "Weather API v2 implementation"

  - source: "data/yaml/docs/weather-api-v2.yaml"
    dest: "data/yaml/docs/weather-api-v2.yaml"
    action: "copy"
    description: "Weather API v2 documentation"
```

### Example 3: Tool + Config

```yaml
transfers:
  - source: "bin/dev/benchmark-tool"
    dest: "bin/dev/benchmark-tool"
    action: "copy"
    chmod: "0755"
    description: "Performance benchmarking tool"

  - source: "configuration/benchmark.conf"
    dest: "configuration/benchmark.conf"
    action: "copy"
    description: "Benchmark configuration"
```

---

## See Also

- **protocol7-staging/README.md** - Staging area overview
- **protocol7-staging/.manifest.yaml** - Transfer definitions
- **session-handover-template.yaml** - Session handover format
- **quick-start.yaml** - Workspace quick start guide

---

**Version**: 1.0
**Last Updated**: 2025-11-06
**Maintainer**: workspace-transfer team
