#!/bin/bash

## BMW Implementation Analysis Script
## For Claude AI's Ubuntu 24 environment

set -e

# Create work directory in /home/claude/work (NOT workspace-transfer!)
WORK_DIR="/home/claude/work"
BMW_REPO="https://github.com/gray/digest-bmw.git"

echo "=== BMW Implementation Analysis ==="
echo "Working directory: $WORK_DIR"
echo ""

# Setup clean workspace
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone BMW repository
if [ ! -d "digest-bmw" ]; then
    echo "Cloning BMW repository into $WORK_DIR/digest-bmw ..."
    git clone "$BMW_REPO"
    echo "✅ Repository cloned"
else
    echo "Repository already exists at $WORK_DIR/digest-bmw"
fi

cd digest-bmw

echo ""
echo "=== Repository Structure ==="
ls -lh

echo ""
echo "=== Checking BMW.xs for State Methods ==="

# Search for state management functions
grep -n -i "getstate\|setstate\|clone\|save.*state\|restore" BMW.xs 2>/dev/null || echo "  (none found in BMW.xs)"

echo ""
echo "=== Checking BMW.pm Interface ==="

if [ -f "lib/Digest/BMW.pm" ]; then
    echo "Methods defined in BMW.pm:"
    grep -n "^sub " lib/Digest/BMW.pm || echo "  (no explicit subs - may use autoload)"
    
    echo ""
    echo "Checking for @ISA inheritance:"
    grep -n "@ISA\|use base\|use parent" lib/Digest/BMW.pm || echo "  (no explicit inheritance)"
else
    echo "  BMW.pm not found - searching..."
    find . -name "BMW.pm" -type f
fi

echo ""
echo "=== Analysis Complete ==="
echo "Location: $WORK_DIR/digest-bmw"
echo ""
echo "Next: Build and test the module"
echo "  cd $WORK_DIR/digest-bmw"
echo "  perl Makefile.PL && make && make test"