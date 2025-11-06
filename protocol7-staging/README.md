# Protocol-7 Staging Area

## Purpose

This directory stages work destined for the Protocol-7 repository before transfer.

## Structure

The directory structure mirrors Protocol-7's layout for easy transfer:

```
protocol7-staging/
├── bin/                    # Executables and scripts
│   ├── dev/               # Development tools
│   └── dependencies/      # Dependency management scripts
├── modules/               # Protocol-7 modules (one function per file)
├── configuration/         # Zenka configurations
│   └── zenki/            # Per-zenka configs
├── data/                  # Data files, resources, libraries
│   ├── yaml/             # YAML documentation and configs
│   ├── asc/              # ASCII documentation
│   └── lib-path/pm/      # Perl modules (AMOS7, etc.)
├── documentation/         # General documentation
├── read-me/              # README files and guides
└── .manifest.yaml        # Transfer manifest (what goes where)
```

## Workflow

### 1. Stage Changes

Work on Protocol-7 features in this staging area:

```bash
# Create a module
vim protocol7-staging/modules/httpd.new_feature

# Create documentation
vim protocol7-staging/data/yaml/docs/new-feature-guide.yaml

# Update manifest
vim protocol7-staging/.manifest.yaml
```

### 2. Transfer to Protocol-7

Use the transfer script:

```bash
# Dry run (see what would be transferred)
../scripts/transfer-to-protocol7.pl --dry-run

# Transfer with review
../scripts/transfer-to-protocol7.pl --interactive

# Auto-transfer (use with caution)
../scripts/transfer-to-protocol7.pl --auto
```

### 3. Commit in Protocol-7

```bash
cd ../../protocol-7
git status  # Review transferred files
git add <files>
git commit -m "feat: Add new feature from workspace-transfer"
git push
```

## File Naming Conventions

### Modules
- Format: `category.function_name`
- Example: `httpd.async_handler`
- Location: `modules/`

### Configuration
- Zenka configs: `configuration/zenki/<zenka-name>/`
- Shared params: `configuration/shared-params`

### Documentation
- YAML docs: `data/yaml/docs/`
- Markdown: `documentation/` or `read-me/`

### Scripts
- User scripts: `bin/`
- Dev tools: `bin/dev/`

## Transfer Manifest

The `.manifest.yaml` file controls what gets transferred and where:

```yaml
transfers:
  - source: "modules/httpd.async_handler"
    dest: "../protocol-7/modules/httpd.async_handler"
    action: "copy"  # or "move"

  - source: "data/yaml/docs/async-guide.yaml"
    dest: "../protocol-7/data/yaml/docs/async-guide.yaml"
    action: "copy"
```

## Safety Features

The transfer script includes:

- ✅ Dry-run mode (see changes before applying)
- ✅ Interactive confirmation (review each file)
- ✅ Backup creation (before overwriting)
- ✅ Git status check (warn if uncommitted changes)
- ✅ Signature preservation (maintain AMOS7 signatures)

## Quick Start

```bash
# 1. Stage your work
mkdir -p protocol7-staging/modules
vim protocol7-staging/modules/test.function

# 2. Create manifest
cat > protocol7-staging/.manifest.yaml << 'EOF'
transfers:
  - source: "modules/test.function"
    dest: "../protocol-7/modules/test.function"
    action: "copy"
EOF

# 3. Transfer
../scripts/transfer-to-protocol7.pl --dry-run
```

## Integration with Workspace

- **Work here**: Experimental Protocol-7 code
- **Test here**: Validate in isolation
- **Transfer**: Move to protocol-7 repo when ready
- **Commit**: Atomic commits in protocol-7 repo

## Tips

1. **Small transfers**: Transfer frequently, small batches
2. **Test first**: Validate in staging before transfer
3. **Document changes**: Update manifest with notes
4. **Review diffs**: Always check what changed
5. **Preserve signatures**: Don't break AMOS7 signatures

---

**Next**: See `../scripts/transfer-to-protocol7.pl --help` for usage
