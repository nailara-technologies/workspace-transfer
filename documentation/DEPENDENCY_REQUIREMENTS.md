# Dependency Requirements for workspace-transfer

**Critical Dependencies for Core Functionality**

---

## 🔑 Checkpoint Encryption/Decryption

### Required Package: `libcryptx-perl`

**Purpose**: Provides CryptX module including Crypt::Mode::CBC for Twofish encryption  
**Required for**: encrypt-checkpoint.pl and decrypt-checkpoint.pl scripts  
**Installation**: 

```bash
# Ubuntu/Debian systems:
apt-get update && apt-get install -y libcryptx-perl

# Alternative if no sudo access (in Docker/Claude environment):
apt-get install -y libcryptx-perl
```

**Why this is required**:
- Scripts migrated from deprecated Crypt::Twofish2 to CryptX (October 2025)
- CryptX is maintained, audited, and available in Ubuntu repositories
- Provides secure CBC mode with automatic padding/unpadding
- Required for checkpoint restoration functionality

### Symptoms if Missing

```
Can't locate Crypt/Mode/CBC.pm in @INC 
(you may need to install the Crypt::Mode::CBC module)
```

### Verification

```bash
# Test if module is available:
perl -e 'use Crypt::Mode::CBC; print "✓ CryptX installed\n"'

# Test checkpoint scripts:
cd /home/claude/workspace-transfer
perl scripts/encrypt-checkpoint.pl --help
perl scripts/decrypt-checkpoint.pl --help
```

---

## 📦 Other Dependencies

Most other dependencies are optional or provided by standard Perl installation:

### Core Modules (Usually Pre-installed)
- File::Basename
- File::Path
- File::Spec
- Getopt::Long
- Digest::SHA
- Time::Piece

### Optional Enhancements
- Term::ReadPassword (for secure key entry)
- YAML::XS or YAML (for configuration files)
- Git (for version control integration)

---

## 🚀 Quick Start for New Sessions

**Minimal setup for checkpoint functionality:**

```bash
# 1. Install CryptX dependency
apt-get update && apt-get install -y libcryptx-perl

# 2. Clone workspace (if needed)
cd /home/claude
git clone https://github.com/nailara-technologies/workspace-transfer.git

# 3. Verify checkpoint scripts work
cd workspace-transfer
perl scripts/decrypt-checkpoint.pl --help
# Should show usage without errors
```

---

## 📝 Historical Note

**October 4, 2025**: Migrated from Crypt::Twofish2 to CryptX
- Old module (Twofish2) was deprecated and not in CPAN
- New module (CryptX) is actively maintained and in Ubuntu repos
- Migration maintains full compatibility with existing checkpoints
- Improved security with random IVs and proper CBC implementation

---

## 🔍 Troubleshooting

### If apt-get Fails

```bash
# Try CPAN (may take longer):
cpan install CryptX

# Or cpanminus:
cpanm CryptX
```

### In Restricted Environments

If you cannot install system packages, checkpoint functionality will be limited.
Consider using:
- Plain text checkpoints (less secure but functional)
- Base64 encoding instead of encryption
- Manual checkpoint management

---

**Last Updated**: October 4, 2025  
**Validated On**: Ubuntu 24.04 LTS (Claude environment)
