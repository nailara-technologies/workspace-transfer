# Protocol-7 Quick Start Guide

**After running `./START-HERE --install`, Protocol-7 is ready to use!**

---

## 🚀 Quick Start Commands

### View Available Zenkas

```bash
./bin/Protocol-7 --help      # Show available zenkas and options
```

### Run Protocol-7

```bash
# Run specific zenka
./bin/Protocol-7 v7          # v7 zenka
./bin/Protocol-7 cube        # cube zenka

# With verbosity flags
./bin/Protocol-7 v7 -v       # Verbose (1 level)
./bin/Protocol-7 v7 -vv      # More verbose (2 levels)
./bin/Protocol-7 v7 -vvv     # Maximum verbose (3 levels)

# With custom options
./bin/Protocol-7 v7 -v --config path/to/config
```

---

## 🔗 Convenient Symlink Shortcuts

After setup, the following shortcuts are automatically available:

```bash
# Protocol-7 variants
p7.v7              # Run v7 zenka
p7.cube            # Run cube zenka
p7.keys            # Access key management
p7.sourcecode      # View source code

# Shell
nshell             # Interactive Protocol-7 shell
```

**Examples:**
```bash
p7.v7 -vv          # v7 zenka with 2 levels of verbosity
p7.cube            # Run cube without flags
p7.keys list       # List available keys
p7.sourcecode      # View source code structure
```

---

## 📊 Common Workflows

### Debugging with Verbose Output

```bash
# Single level (shows main operations)
./bin/Protocol-7 v7 -v

# Two levels (shows detailed operations)
./bin/Protocol-7 v7 -vv

# Three levels (shows everything including internal details)
./bin/Protocol-7 v7 -vvv
```

### Working with Different Zenkas

```bash
# Test v7 zenka
p7.v7

# Test cube zenka
p7.cube

# Compare behavior
p7.v7 -v
p7.cube -v
```

### Key Management

```bash
# View key management interface
p7.keys

# May support subcommands depending on implementation:
p7.keys list        # List keys
p7.keys add         # Add new key
p7.keys remove      # Remove key
```

### Source Code Viewing

```bash
# View protocol-7 source structure
p7.sourcecode

# May support navigation and searching depending on implementation
```

---

## 🛠️ Dependency Management

After setup, if you need to manage dependencies:

```bash
# Check dependency status
bin/deps check protocol7_full

# Install/update dependencies
bin/deps install protocol7_full

# Preview what would be installed
bin/deps install protocol7_full --dry-run

# Check all dependency profiles
bin/deps status
```

---

## 📁 Project Layout

```
/home/user/workspace-transfer/     # Workspace root
├── bin/
│   ├── Protocol-7                 # Main executable
│   ├── nshell                     # Interactive shell
│   └── dev/                       # Development tools
├── docs/                          # Documentation
├── .deps/                         # Dependency profiles
│   └── profiles.yaml              # Dependency definitions
└── START-HERE                     # Setup script

/home/user/protocol-7/             # Protocol-7 repository
├── bin/
├── modules/
└── STATUS.md                      # Current status
```

---

## 🔧 Environment Setup

After running START-HERE, your environment is configured with:

### PATH Configuration

The following directories are added to PATH (see START-HERE output):
```bash
/home/user/workspace-transfer/bin
/home/user/workspace-transfer/bin/dev
```

To make these permanent, add to your shell profile (`.bashrc`, `.zshrc`, etc.):
```bash
export PATH="/home/user/workspace-transfer/bin:$PATH"
export PATH="/home/user/workspace-transfer/bin/dev:$PATH"
```

### Systemd Service

A systemd service file is automatically installed:
```bash
/lib/systemd/system/Protocol-7.service
```

To manage it:
```bash
systemctl status Protocol-7      # Check status
systemctl start Protocol-7       # Start service
systemctl stop Protocol-7        # Stop service
systemctl enable Protocol-7      # Enable on boot
```

---

## 📖 Documentation

### General Workspace Setup
```bash
cat docs/onboarding/PROTOCOL7_SETUP.md
```

### Dependency Management
```bash
cat docs/reference/DEPENDENCY_MANAGEMENT.md
```

### Protocol-7 Status and Current Work
```bash
cat ../protocol-7/STATUS.md
```

### Full Help
```bash
bin/deps help                    # Dependency system help
./bin/Protocol-7 --help          # Protocol-7 help
```

---

## 🐛 Troubleshooting

### Command Not Found (Symlinks Not Working)

Make sure symlinks were created successfully:
```bash
ls -l /usr/local/bin/p7*
which p7.v7
```

If missing, reinstall:
```bash
bin/deps install protocol7_full
```

### Missing Dependencies

Check which dependencies are missing:
```bash
bin/deps check protocol7_full
```

Install missing:
```bash
bin/deps install protocol7_full
```

### Protocol-7 Not Executing

Check execution permissions:
```bash
ls -l bin/Protocol-7
chmod +x bin/Protocol-7
```

### Verbose Output Too Noisy

Reduce verbosity:
```bash
./bin/Protocol-7 v7         # No flags (normal output)
./bin/Protocol-7 v7 -v      # Less verbose than -vv
```

---

## 🔄 Updates and Maintenance

### Pull Latest Changes
```bash
git pull origin base
```

### Update Dependencies
```bash
bin/deps install protocol7_full
```

### Check System Status
```bash
bin/deps status
git status
cat STATUS.md
```

---

## 📊 System Health

Check everything is installed:
```bash
# All in one
bin/deps check protocol7_full

# Individual checks
bin/deps check base
bin/deps check network
bin/deps check learning
```

---

## 🎯 Next Steps

1. **Run your first command:**
   ```bash
   p7.v7
   ```

2. **Explore available options:**
   ```bash
   ./bin/Protocol-7 --help
   ```

3. **Check documentation:**
   ```bash
   cat docs/onboarding/PROTOCOL7_SETUP.md
   ```

4. **View current status:**
   ```bash
   cat STATUS.md
   cat ../protocol-7/STATUS.md
   ```

---

**Version**: 1.0
**Last Updated**: 2025-11-16
**Setup Script**: `./START-HERE`
**Dependency Manager**: `bin/deps`
