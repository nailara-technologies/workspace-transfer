# Protocol-7 Module Requirements - From Cloned Repository

## Repository Status

✅ **Cloned Successfully:** https://github.com/nailara-technologies/protocol-7.git
- Location: `/home/claude/protocol-7`
- Size: 89MB
- Branch: main
- Latest: 80f5c25d4

## Initial Test Results

**Command:** `echo '[exit:"test",0]' | ./bin/Protocol-7 -v`

**Status:** ✗ Failed - missing system modules

**Error:**
```
Can't locate IO/Scalar.pm in @INC
```

## Required Perl Modules (from p7_load_perl_modules)

### Early Initialization Modules

These are loaded in `bin/Protocol-7` around line 252:

```perl
use File::stat;            # ✓ Available (core Perl)
use IO::Handle;            # ✓ Available (core Perl)  
use IO::Scalar;            # ✗ MISSING - need libio-stringy-perl
use Sys::Hostname;         # ✓ Available (core Perl)
use Text::Wrap;            # ✓ Available (core Perl)
use File::Spec::Functions; # ✓ Available (core Perl)
use List::MoreUtils;       # ✗ MISSING - need liblist-moreutils-perl
use Cwd;                   # ✓ Available (core Perl)
use FindBin;               # ✓ Available (core Perl)
use Fcntl;                 # ✓ Available (core Perl)
```

### Time::HiRes (loaded via p7_load_time_hires)

```perl
use Time::HiRes;           # ✓ Available (v1.9775)
```

## Minimum Required System Packages for Basic Test

To get Protocol-7 running for the simple test, we need:

### Essential (to start)
```bash
apt-get install libio-stringy-perl      # IO::Scalar
apt-get install liblist-moreutils-perl  # List::MoreUtils
```

### For Full Functionality
All 55 packages from `install_minimal_dependencies.debian.sh`

### Critical CPAN Modules
```bash
cpanm Digest::BMW          # AMOS7 checksums
cpanm Crypt::Ed25519       # Signatures
cpanm Digest::Elf          # ELF checksums (or use Digest::Elf fallback)
```

## Bundled Modules (Already Present)

Protocol-7 includes these in `data/lib-path/pm/`:

✓ AMOS7 suite:
- AMOS7.pm
- AMOS7::13
- AMOS7::Assert
- AMOS7::Assert::Truth
- AMOS7::CHKSUM
- AMOS7::CHKSUM::ELF
- AMOS7::INLINE
- AMOS7::TEMPLATE
- AMOS7::TERM
- AMOS7::Util
- And more...

✓ Other bundled:
- Curses extensions
- X11 extensions
- Term extensions
- Sys extensions
- Modified/fixed CPAN modules

## Space Considerations

Current space usage:
```
Total: 89MB
- data/gfx/backgrounds: 27MB (can be removed)
- data/gfx/icons: 1.8MB
- modules: 3.6MB
- configuration: 2.5MB
- data/lib-path: 1.6MB (keep - has AMOS7 modules)
```

Available disk space: 4.5GB
Current usage: 120MB (3%)

**Recommendation:** Keep as-is for now. 89MB is fine.

## Testing Strategy

### Option 1: Minimal Test (Need 2 packages)
```bash
# If we had apt access:
apt-get install libio-stringy-perl liblist-moreutils-perl

# Then test:
cd /home/claude/protocol-7
echo '[exit:"worx =)",0]' | ./bin/Protocol-7 -v
```

### Option 2: Full Installation
Use our created `install_minimal_dependencies.ubuntu24.sh`

### Option 3: Mock Missing Modules
Create stub modules temporarily just to test the concept:

```perl
# /home/claude/stubs/IO/Scalar.pm
package IO::Scalar;
use IO::Handle;
our @ISA = qw(IO::Handle);
sub new { my $class = shift; bless {}, $class; }
1;
```

## What We Can Test Now

Even without full dependencies, we can:

1. ✅ Browse the module code
2. ✅ Examine zenki configurations
3. ✅ Check the AMOS7 bundled modules
4. ✅ Review the architecture
5. ✅ Test with minimal stubs

## Space Cleanup Options (if needed)

If we need space later:

```bash
# Remove backgrounds (27MB)
rm -rf data/gfx/backgrounds/*

# Remove icons (1.8MB)
rm -rf data/gfx/icons/*

# Remove zenka graphics (925KB)
rm -rf data/gfx/zenka/*

# Total savings: ~29MB (reduces to 60MB)
```

**But don't do this yet** - we have plenty of space!

## Next Steps

1. Document the full dependency tree
2. Create stub modules for minimal testing
3. Or: note what would work with full installation
4. Test specific zenki configurations
5. Examine the inline C code compilation

## Files Available to Examine

```
bin/Protocol-7              - Main interpreter
configuration/zenki/v7/     - V7 zenka config
configuration/zenki/cube/   - Cube zenka config
modules/                    - 3.6MB of Protocol-7 modules
data/lib-path/pm/AMOS7/     - AMOS7 module suite
```

## Conclusion

✅ Repository cloned successfully
✅ AMOS7 modules bundled and available
✅ Space usage is reasonable (89MB / 4.5GB available)
⚠️ Need 2 system packages for basic test (IO::Stringy, List::MoreUtils)
⚠️ Environment network restrictions prevent apt-get install

The repository is complete and ready. We just need the system dependencies
which would be installed via `install_minimal_dependencies.ubuntu24.sh`
on a real Ubuntu 24 system.
