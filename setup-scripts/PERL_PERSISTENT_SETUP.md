# Protocol-7 Persistent Perl Module Setup

## Directory Structure

```
/mnt/user-data/perl5/          # Persistent CPAN modules (survives sessions)
  └── lib/perl5/               # Installed module libraries

/mnt/user-data/uploads/        # Your Protocol-7 files (upload here)
/mnt/user-data/outputs/        # Generated files (download from here)

/home/claude/                  # Working directory (resets each session)
```

## Environment Setup

Add to your working session:

```bash
export PERL5LIB="/mnt/user-data/perl5/lib/perl5:$PERL5LIB"
export PERL_LOCAL_LIB_ROOT="/mnt/user-data/perl5"
export PERL_MB_OPT="--install_base /mnt/user-data/perl5"
export PERL_MM_OPT="INSTALL_BASE=/mnt/user-data/perl5"
```

Or source the provided config:
```bash
. /mnt/user-data/outputs/perlrc
```

## Installing Persistent Modules

### Method 1: Using cpanm directly
```bash
cpanm --local-lib /mnt/user-data/perl5 Module::Name
```

### Method 2: Using the helper script
```bash
./install-persistent-module.pl Module::Name
```

## Module Priority Order

Protocol-7 will search for modules in this order:

1. **Protocol-7 bundled modules** (`$P7_ROOT/data/lib-path/pm/`)
   - AMOS7::* modules
   - Modified/fixed CPAN modules
   
2. **Persistent CPAN modules** (`/mnt/user-data/perl5/lib/perl5/`)
   - Modules you install that persist between sessions
   
3. **System Perl modules** (`/usr/share/perl5/`, etc.)
   - Debian-packaged modules

## Example: Installing Time::HiRes

```bash
# Check if already available
perl -MTime::HiRes -e 'print "OK\n"'

# If not, install persistently
cpanm --local-lib /mnt/user-data/perl5 Time::HiRes
```

## Checking What's Installed Persistently

```bash
ls -R /mnt/user-data/perl5/lib/perl5/
```

## Notes

- **Protocol-7's own modules** in `data/lib-path/pm/` are NOT in the persistent location
  They're part of your Protocol-7 installation
  
- **Heavy dependencies** should be installed to `/mnt/user-data/perl5/` to avoid
  reinstalling every session
  
- **System dependencies** from install_*_dependencies.sh scripts install system-wide
  (ephemeral in this environment)

## For Protocol-7 Development

When working on Protocol-7 code:

1. Copy Protocol-7 to `/home/claude/protocol-7/` for editing
2. Install needed CPAN deps to `/mnt/user-data/perl5/`
3. Test your changes
4. Copy modified files to `/mnt/user-data/outputs/` to preserve them

Protocol-7's @INC modification will automatically find modules in both locations.
