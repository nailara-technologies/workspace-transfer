# Protocol-7 Ubuntu 24 Dependencies - Analysis Summary

## Quick Answer: ✓ All Debian Packages Work!

**No Ubuntu-specific changes needed for apt packages.**
All 55 packages from `install_minimal_dependencies.debian.sh` are available in Ubuntu 24.

## What Was Analyzed

1. **55 Debian packages** from apt-get install line
   - Result: ✓ All available in Ubuntu 24
   - No name changes needed
   - No substitutions required

2. **11 CPAN modules** installed via cpanm
   - Result: Not in Ubuntu repos (expected)
   - Need CPAN installation
   - Can install to persistent storage

3. **1 Special case:** Crypt::Curve25519
   - Protocol-7 provides fixed version in pm-src/
   - Original has "fmul issue"

4. **1 Skipped:** Poloniex::API
   - Only for 'c-trade' agent
   - Not needed for core functionality

## Files Created

### `/mnt/user-data/outputs/`

1. **`UBUNTU24_COMPATIBILITY_REPORT.md`**
   - Detailed analysis of all 66 dependencies
   - Categorized by type and priority
   - Installation recommendations

2. **`install_minimal_dependencies.ubuntu24.sh`**
   - Ubuntu 24 optimized install script
   - Uses persistent Perl module storage (`/mnt/user-data/perl5/`)
   - Categorizes modules by priority (essential/important/optional)
   - Handles Crypt::Curve25519 special case
   - Skips Poloniex::API

3. **`PERL_PERSISTENT_SETUP.md`**
   - Guide for using persistent Perl modules
   - Environment setup instructions
   - Module search order explanation

4. **`perlrc`**
   - Environment variables for persistent modules
   - Source this in each session

5. **`install-persistent-module.pl`**
   - Helper script for manual module installation
   - Uses persistent storage automatically

## Key Findings

### System Packages ✓
All work perfectly:
- Core: gcc, git, make, cpanminus
- Perl modules: 51 lib*-perl packages
- All available via apt-get

### Critical CPAN Modules
**Must have:**
- `Digest::BMW` - AMOS7 uses this for checksums!
- `Crypt::Ed25519` - Ed25519 signatures
- `Crypt::Twofish2` - Encryption

**Important:**
- `Net::IP::Lite` - Network operations
- `File::MimeInfo::Magic` - File type detection
- `Config::Hosts` - System configuration

### Special Considerations

#### Inline::C (CRITICAL!)
- Package: `libinline-c-perl` ✓ Available
- Protocol-7's AMOS7 modules use inline C code
- Essential for performance (ELF checksums, truth assertions)
- Without it: Falls back to slower pure-Perl or Digest::Elf

#### Crypt::Curve25519
- Upstream has compilation issues ("fmul bug")
- Protocol-7 provides fixed version
- Install from `data/lib-path/pm-src/crypt-curve25519`

## Recommendation

Use the provided **`install_minimal_dependencies.ubuntu24.sh`** script:

```bash
# As root
sudo /mnt/user-data/outputs/install_minimal_dependencies.ubuntu24.sh

# Then in your session
. /mnt/user-data/outputs/perlrc
```

Benefits:
- All system packages installed
- CPAN modules go to persistent storage
- Survives environment resets
- Prioritized installation (essential first)
- Handles special cases automatically

## Testing Checklist

After installation, verify:

```bash
# Check system packages
dpkg -l | grep -E 'libinline-c-perl|libcryptx-perl|libdigest-elf-perl'

# Check CPAN modules
perl -MDigest::BMW -e 'print "BMW OK\n"'
perl -MCrypt::Ed25519 -e 'print "Ed25519 OK\n"'
perl -MCrypt::Curve25519 -e 'print "Curve25519 OK\n"'

# Check persistent library
ls -la /mnt/user-data/perl5/lib/perl5/

# Check environment
echo $PERL5LIB
```

## Differences from Original Debian Script

1. **Persistent storage:** CPAN modules install to `/mnt/user-data/perl5/`
2. **Prioritization:** Modules categorized by importance
3. **Error handling:** Optional modules don't fail installation
4. **Skip Poloniex:** Not installed by default
5. **Environment setup:** Creates and documents environment config

## Next Steps

1. Run the Ubuntu 24 install script
2. Source the perlrc environment config
3. Test Protocol-7 startup
4. Install any additional modules as needed using:
   ```bash
   cpanm --local-lib /mnt/user-data/perl5 Module::Name
   ```

No Ubuntu-specific package substitutions needed! 🎉
