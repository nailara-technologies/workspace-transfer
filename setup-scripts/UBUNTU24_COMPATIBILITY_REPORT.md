# Protocol-7 Dependencies - Ubuntu 24 Compatibility Analysis

## Summary

**Good News:** All Debian packages are available in Ubuntu 24!
- ✓ All 55 packages from apt-get install line are present
- ✓ No package name changes needed
- ✓ No missing packages

**CPAN Modules:** 11 modules need installation via cpanm
- These are not in Ubuntu's apt repositories
- Need to be installed from CPAN
- Can be installed persistently to `/mnt/user-data/perl5/`

## Debian/Ubuntu Packages (All Available)

### Core Development Tools
- gcc, git, make, cpanminus
- libc6-dev

### Perl Core Modules
- libmce-perl (Many-Core Engine)
- liburi-perl
- libclone-perl
- libevent-perl
- libcryptx-perl (Cryptography)
- libio-aio-perl (Async I/O)
- libjson-xs-perl (Fast JSON)
- libnet-dns-perl
- libtimedate-perl
- libhttp-date-perl
- liburi-query-perl
- libdigest-crc-perl
- libdigest-elf-perl
- libfile-which-perl
- libfile-finder-perl
- libfile-slurper-perl
- libfile-extattr-perl (Extended attributes)

### Perl Testing/Quality
- libperl-critic-perl
- libtest-requires-perl
- libtest-exception-perl
- libtest-sharedfork-perl

### Perl Utilities
- libsub-uplevel-perl
- libbsd-resource-perl
- libdigest-jhash-perl
- libhash-flatten-perl
- libhash-merge-simple-perl
- libhttp-message-perl
- libyaml-libyaml-perl
- libconfig-simple-perl
- libio-socket-ssl-perl
- libppix-utilities-perl
- libcurses-perl
- libproc-processtable-perl
- libterm-readline-gnu-perl
- libterm-readpassword-perl
- libterm-size-perl
- liblwp-protocol-https-perl
- libclass-accessor-lite-perl
- libio-socket-multicast-perl
- libinline-c-perl (Important: for AMOS7 inline C code!)
- libconst-fast-perl
- liblwpx-paranoidagent-perl
- liblinux-inotify2-perl
- libio-compress-perl
- libio-compress-lzma-perl
- libcapture-tiny-perl
- libfreezethaw-perl
- libunicode-string-perl
- libunicode-maputf8-perl

### System Libraries
- shared-mime-info

## CPAN Modules (Need cpanm Installation)

### Cryptography Modules
1. **Crypt::Ed25519** - Ed25519 signatures
2. **Crypt::Curve25519** - Curve25519 key exchange
   - Note: Script mentions this "no longer compiles as orig."
   - Fixed copy provided in `data/lib-path/pm-src/crypt-curve25519`
3. **Crypt::Twofish2** - Twofish encryption

### Checksum/Hashing
4. **Digest::Skein** - Skein hash function
5. **Digest::BMW** - Blue Midnight Wish hash (AMOS7 uses this!)

### Network/Protocol
6. **Net::IP::Lite** - Lightweight IP address manipulation
7. **URI::QueryParam** - URI query parameter handling

### System/Config
8. **Config::Hosts** - Hosts file manipulation
9. **Sys::Statistics::Linux::CpuStats** - CPU statistics

### Utilities
10. **File::MimeInfo::Magic** - MIME type detection
11. **SigAction::SetCallBack** - Signal handling callbacks

## Special Notes

### Crypt::Curve25519
The original script notes:
```bash
# Crypt::Curve25519 no longer compiles as orig., provided fixed copy locally now
#                                                until fmul issue fixed upstream
```

Protocol-7 provides a fixed version in:
`data/lib-path/pm-src/crypt-curve25519`

### Poloniex::API
**NOT NEEDED** for basic Protocol-7 operation. Only required for 'c-trade' agent.
The original script uses `--force` to install it:
```bash
cpanm --force Poloniex::API
```

## Recommendations

### For This Environment (Ubuntu 24 in Claude)

1. **System packages:** Run apt-get install (all work as-is)
2. **CPAN modules:** Install to `/mnt/user-data/perl5/` for persistence
3. **Skip:** Poloniex::API (not needed for core functionality)
4. **Crypt::Curve25519:** Use Protocol-7's fixed version from pm-src

### Installation Priority

**Essential (for core Protocol-7):**
- Digest::BMW (AMOS7 checksums!)
- Crypt::Ed25519, Crypt::Twofish2
- All system packages

**Important (for common zenki):**
- Net::IP::Lite
- File::MimeInfo::Magic
- Config::Hosts

**Lower Priority (specific features):**
- Sys::Statistics::Linux::CpuStats
- SigAction::SetCallBack
- URI::QueryParam
- Digest::Skein

## Ubuntu-Specific Changes Needed?

**NONE!** The Debian package list works perfectly on Ubuntu 24.

You can use the original `install_minimal_dependencies.debian.sh` as-is,
just modify the CPAN installation section to use persistent storage:

```bash
# Instead of:
cpanm Module::Name

# Use:
cpanm --local-lib /mnt/user-data/perl5 Module::Name
```
