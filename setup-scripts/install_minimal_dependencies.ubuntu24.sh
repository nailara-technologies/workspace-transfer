#!/bin/bash

## Protocol-7 Minimal Dependencies Installation for Ubuntu 24
## Optimized for persistent Perl module storage

set -e  # Exit on error

PERSISTENT_LIB="/mnt/user-data/perl5"

echo "=== Protocol-7 Ubuntu 24 Dependency Installation ==="
echo ""

# Create persistent Perl library if it doesn't exist
if [ ! -d "$PERSISTENT_LIB" ]; then
    echo "Creating persistent Perl library directory..."
    mkdir -p "$PERSISTENT_LIB/lib/perl5"
fi

# Set up environment for persistent modules
export PERL5LIB="$PERSISTENT_LIB/lib/perl5:$PERL5LIB"
export PERL_LOCAL_LIB_ROOT="$PERSISTENT_LIB"
export PERL_MB_OPT="--install_base $PERSISTENT_LIB"
export PERL_MM_OPT="INSTALL_BASE=$PERSISTENT_LIB"

echo "Persistent Perl modules will be installed to: $PERSISTENT_LIB"
echo ""

## System packages (all verified available in Ubuntu 24)
echo "=== Installing System Packages ==="
apt-get update
apt-get -y install gcc git make cpanminus libc6-dev libmce-perl \
            liburi-perl libclone-perl libevent-perl libcryptx-perl \
            libio-aio-perl libjson-xs-perl libnet-dns-perl libtimedate-perl \
            libhttp-date-perl liburi-query-perl libdigest-crc-perl \
            libdigest-elf-perl libfile-which-perl libfile-finder-perl \
            libperl-critic-perl libsub-uplevel-perl libbsd-resource-perl \
            libdigest-jhash-perl libfile-extattr-perl \
            libfile-slurper-perl libhash-flatten-perl libhttp-message-perl \
            libyaml-libyaml-perl libconfig-simple-perl libio-socket-ssl-perl \
            libtest-requires-perl libppix-utilities-perl shared-mime-info \
            libtest-exception-perl libtest-sharedfork-perl libcurses-perl \
            libhash-merge-simple-perl libproc-processtable-perl \
            libterm-readline-gnu-perl libterm-readpassword-perl \
            liblwp-protocol-https-perl libclass-accessor-lite-perl \
            libio-socket-multicast-perl libinline-c-perl libconst-fast-perl \
            liblwpx-paranoidagent-perl liblinux-inotify2-perl \
            libio-compress-perl libcapture-tiny-perl libfreezethaw-perl \
            libio-compress-lzma-perl \
            libterm-size-perl \
            libunicode-string-perl libunicode-maputf8-perl

echo ""
echo "=== Installing CPAN Modules (to persistent storage) ==="

# Essential CPAN modules for Protocol-7 core functionality
ESSENTIAL_MODULES=(
    "Digest::BMW"           # AMOS7 checksums - CRITICAL
    "Crypt::Ed25519"        # Ed25519 signatures
    "Crypt::Twofish2"       # Twofish encryption
)

# Important for common zenki
IMPORTANT_MODULES=(
    "Net::IP::Lite"         # IP address manipulation
    "File::MimeInfo::Magic" # MIME type detection
    "Config::Hosts"         # Hosts file manipulation
    "URI::QueryParam"       # URI query parameters
)

# Additional modules (lower priority)
OPTIONAL_MODULES=(
    "Digest::Skein"         # Skein hash function
    "Sys::Statistics::Linux::CpuStats"  # CPU statistics
    "SigAction::SetCallBack"  # Signal handling
)

install_module() {
    local module=$1
    local description=$2
    
    echo ""
    echo "Installing $module ($description)..."
    
    if cpanm --local-lib "$PERSISTENT_LIB" "$module"; then
        echo "✓ $module installed successfully"
    else
        echo "✗ Failed to install $module" >&2
        return 1
    fi
}

# Install essential modules
echo ""
echo "--- Essential Modules ---"
for module in "${ESSENTIAL_MODULES[@]}"; do
    install_module "$module" "essential"
done

# Install important modules
echo ""
echo "--- Important Modules ---"
for module in "${IMPORTANT_MODULES[@]}"; do
    install_module "$module" "important" || true  # Don't fail on these
done

# Install optional modules
echo ""
echo "--- Optional Modules ---"
for module in "${OPTIONAL_MODULES[@]}"; do
    install_module "$module" "optional" || true  # Don't fail on these
done

# Special handling for Crypt::Curve25519
echo ""
echo "=== Installing Crypt::Curve25519 (from fixed Protocol-7 version) ==="
echo "Note: Using Protocol-7's fixed version from data/lib-path/pm-src/crypt-curve25519"

# Assume NAILARA_ROOT is available or detect it
if [ -z "$NAILARA_ROOT" ]; then
    # Try to detect Protocol-7 root
    if [ -f "/usr/local/bin/Protocol-7" ]; then
        NAILARA_ROOT=$(readlink -f /usr/local/bin/Protocol-7 | sed 's|/bin/Protocol-7$||')
    fi
fi

if [ -n "$NAILARA_ROOT" ] && [ -d "$NAILARA_ROOT/data/lib-path/pm-src/crypt-curve25519" ]; then
    cpanm --local-lib "$PERSISTENT_LIB" "$NAILARA_ROOT/data/lib-path/pm-src/crypt-curve25519" && \
        cd "$NAILARA_ROOT" && git clean -fxd "$NAILARA_ROOT/data/lib-path/pm-src" || \
        echo "✗ Crypt::Curve25519 installation from local source failed"
else
    echo "⚠ Protocol-7 root not found, trying CPAN version (may have fmul issue)..."
    cpanm --local-lib "$PERSISTENT_LIB" Crypt::Curve25519 || \
        echo "✗ Crypt::Curve25519 installation failed (this is expected if fmul bug exists)"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Persistent modules installed to: $PERSISTENT_LIB"
echo ""
echo "To use these modules, add to your environment:"
echo "  export PERL5LIB=\"$PERSISTENT_LIB/lib/perl5:\$PERL5LIB\""
echo ""
echo "Or source the provided config:"
echo "  . /mnt/user-data/outputs/perlrc"
echo ""

# Note about Poloniex::API
echo "Note: Poloniex::API was NOT installed (only needed for 'c-trade' agent)"
echo "      Install manually if needed: cpanm --local-lib $PERSISTENT_LIB --force Poloniex::API"
echo ""
