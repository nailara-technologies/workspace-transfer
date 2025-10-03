# Claude AI - Protocol-7 Workspace Onboarding

## Welcome to the Protocol-7 Development Environment

You are operating in an **Ubuntu 24.04 LTS** environment with access to the Protocol-7 codebase.

---

## Directory Structure

```
/home/claude/workspace-transfer/    # This repository (workspace-transfer)
/home/claude/work/                  # Workspace for builds, tests, experiments
/mnt/user-data/uploads/             # User-uploaded files (slightly persistent)
/mnt/user-data/outputs/             # Your generated outputs (ephemeral)
~/.ssh/workspace-transfer-read-write # SSH key for repository access
```

**Important Rules:**
- ✅ DO clone external repos into `/home/claude/work/`
- ✅ DO place build artifacts in `/home/claude/work/`
- ✅ DO write reports to `/mnt/user-data/outputs/`
- ❌ DO NOT commit binaries or build artifacts to `workspace-transfer/`

---

## Repository References

### Workspace Transfer (This Repository)
- **URL**: `https://github.com/nailara-technologies/workspace-transfer.git`
- **Location**: `/home/claude/workspace-transfer/` (you are here)
- **SSH Key**: `~/.ssh/workspace-transfer-read-write`
- **Purpose**: Working copy for Claude AI sessions
- **Branch**: `base` (default)

### Protocol-7 (Main Repository)
- **URL**: `https://github.com/nailara-technologies/protocol-7.git`
- **Clone to**: `/home/claude/work/protocol-7/` (if needed for reference)
- **Branch**: `base` (default)
- **Description**: Protocol-7 harmonic computing framework and signature system
- **Key Directories**:
  - `bin/` - Executable scripts and utilities
  - `modules/` - Core Protocol-7 modules (source.*, base.*, etc.)
  - `data/` - Checksums, signatures, configuration data
  - `bin/dev/` - Development tools and examples (e.g., `elf-continue`)

### Digest::BMW (External Dependency)
- **URL**: `https://github.com/gray/digest-bmw.git`
- **Clone to**: `/home/claude/work/digest-bmw/`
- **Description**: Perl interface to Blue Midnight Wish hash algorithm (BMW384)
- **Purpose**: Cryptographic checksums for Protocol-7 signatures
- **Key Files**:
  - `BMW.xs` - C/XS implementation
  - `lib/Digest/BMW.pm` - Perl interface
  - `t/` - Test suite

### Related Projects (For Reference)

#### CryptX (Perl Crypto Toolkit)
- **URL**: `https://github.com/DCIT/perl-CryptX.git`
- **Description**: Comprehensive Perl cryptography library
- **Relevance**: Contains reference implementations of various hash algorithms

#### Digest Base Classes
- **Digest::base** - Standard Perl digest interface
- **Digest::SHA** - Reference implementation for state management
- **Documentation**: `perldoc Digest` on system

---

## Current Mission: BMW Resumability Analysis

### Context

Protocol-7 uses **BMW384** checksums for cryptographic file signatures. Currently:
- ✅ **ELF7 checksums** are resumable (see `bin/dev/elf-continue`)
- ❓ **BMW checksums** - resumability needs verification

The BMW (Blue Midnight Wish) algorithm is used for:
- Line 2 of signature footer (BASE32-encoded BMW384 checksum)
- AMOS iteration counter calculation (derived from BMW state)
- Harmonic truth validation (ELF checksums validate BMW hashes)

### Why Resumability Matters

For streaming signatures on large files and continuous data sources:
1. **State save** - Serialize internal BMW context to binary blob
2. **State restore** - Resume computation from saved state
3. **Streaming mode** - Process data in chunks without buffering entire file
4. **Memory efficiency** - Constant memory usage regardless of input size

### What Is Resumability?

**Resumability** means the ability to:
1. **Save the internal hash state** at any point during computation
2. **Restore that state** and continue hashing from where you left off
3. **Produce identical results** whether computed all-at-once or in resumed chunks

**Example Pattern (from ELF7):**
```perl
# Compute in one pass
$hash1 = elf_hash("chunk1chunk2");

# Compute with continuation
$state = elf_hash("chunk1");  # Returns intermediate state
$hash2 = elf_hash("chunk2", seed => $state);  # Resume from state

# $hash1 == $hash2 (identical results)
```

---

## Your Task

### Phase 1: Clone and Analyze

```bash
# Setup workspace
mkdir -p /home/claude/work
cd /home/claude/work

# Clone BMW repository (NOT in workspace-transfer!)
git clone https://github.com/gray/digest-bmw.git
cd digest-bmw

# Examine implementation
ls -la
cat README* | head -50

# Check for state management methods
grep -rn "getstate\|setstate\|clone" . --include="*.pm" --include="*.xs"
```

**What to look for:**
- `clone()` method - Creates a copy of current digest state
- `getstate()` method - Serializes internal state to a string/blob
- `setstate()` method - Restores internal state from a string/blob

### Phase 2: Build and Test

```bash
cd /home/claude/work/digest-bmw

# Install build dependencies
sudo apt-get update
sudo apt-get install -y build-essential perl cpanminus libssl-dev
cpanm --installdeps .

# Build BMW module
perl Makefile.PL
make
make test  # Should pass
```

### Phase 3: Test Resumability

Create `/home/claude/work/test-bmw-resumability.pl`:

```perl
#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use lib '/home/claude/work/digest-bmw/blib/lib';
use lib '/home/claude/work/digest-bmw/blib/arch';
use Digest::BMW;

say "=== BMW Resumability Test ===\n";

my $test_data = "The quick brown fox jumps over the lazy dog";
my ($chunk1, $chunk2) = (substr($test_data, 0, 20), substr($test_data, 20));

# Method 1: All at once
my $bmw1 = Digest::BMW->new(384);
$bmw1->add($test_data);
my $digest1 = $bmw1->hexdigest;
say "Full digest: $digest1\n";

# Method 2: Sequential chunks
my $bmw2 = Digest::BMW->new(384);
$bmw2->add($chunk1);
$bmw2->add($chunk2);
my $digest2 = $bmw2->hexdigest;

# Verify consistency
die "FAIL: Inconsistent digests!" unless $digest1 eq $digest2;
say "✅ BMW is internally consistent\n";

# Method 3: Check for state save/restore
say "Checking for state management methods:";
say "  clone()    : " . ($bmw1->can('clone') ? "✅ YES" : "❌ NO");
say "  getstate() : " . ($bmw1->can('getstate') ? "✅ YES" : "❌ NO");
say "  setstate() : " . ($bmw1->can('setstate') ? "✅ YES" : "❌ NO");

if ($bmw1->can('clone')) {
    my $bmw3 = Digest::BMW->new(384);
    $bmw3->add($chunk1);
    my $bmw4 = $bmw3->clone;
    $bmw4->add($chunk2);
    my $digest3 = $bmw4->hexdigest;
    
    if ($digest3 eq $digest1) {
        say "\n✅ BMW supports resumability via clone()";
    } else {
        say "\n❌ FAIL: clone() produced different digest";
    }
}

if (!$bmw1->can('clone') && !$bmw1->can('getstate')) {
    say "\n⚠️  BMW does NOT support state save/restore";
    say "Implementation needed: getstate() and setstate() methods";
}

say "\n=== Test Complete ===";
```

Run test:
```bash
cd /home/claude/work
chmod +x test-bmw-resumability.pl
perl test-bmw-resumability.pl | tee /mnt/user-data/outputs/bmw-test-results.txt
```

### Phase 4: Analysis Report

Based on test results, create `/mnt/user-data/outputs/bmw-analysis-report.md`:

**If state methods exist:**
```markdown
# BMW Resumability Analysis Report

## Summary
✅ BMW supports resumable checksums via [clone/getstate/setstate] method(s).

## Findings
- Method available: [describe which methods exist]
- State size: [X bytes - check with length(getstate())]
- Compatibility: [verified with test script]

## Test Results
- Internal consistency: PASS
- Clone test: PASS
- State serialization: [PASS/FAIL/NOT TESTED]

## Integration Recommendations
- Update Protocol-7 `source.create_harmonic_footer` to use streaming mode
- Test with large files (GB+)
- Validate state serialization across architectures
- Add BMW continuation support similar to ELF7's seed parameter

## Example Usage Pattern
```perl
# Start hashing
my $bmw = Digest::BMW->new(384);
$bmw->add($chunk1);

# Save state
my $state = $bmw->clone;  # or getstate()

# Resume later
$state->add($chunk2);
my $final_hash = $state->hexdigest;
```
```

**If state methods missing:**
```markdown
# BMW Resumability Analysis Report

## Summary
❌ BMW does NOT currently support state save/restore.

## Findings
- No `clone()`, `getstate()`, or `setstate()` methods found
- Internal state structure: [examine BMW.xs to describe]
- BMW.xs implementation: [summarize key structures]

## Impact on Protocol-7
Without resumability:
- Cannot stream large files efficiently
- Must buffer entire file in memory for signature
- Cannot implement continuation pattern like ELF7

## Required Implementation
Add to BMW.xs:
1. `clone()` - Duplicate the BMW context structure
2. `getstate()` - Serialize `bmw_ctx` to binary string
3. `setstate()` - Restore `bmw_ctx` from binary string

## Implementation Details
Based on examining BMW.xs:
- Internal structure: `bmw_ctx` (or equivalent)
- State to serialize:
  - Hash state array (h[16] or similar)
  - Buffer contents
  - Bit/byte counter
  - Block size

## Next Steps
1. Examine BMW.xs internal structures in detail
2. Design state serialization format (binary packing)
3. Implement XS methods following Digest::SHA pattern
4. Test thoroughly with various input sizes
5. Generate patch for upstream submission
```

### Phase 5: Implementation (If Needed)

If state methods are missing:

1. **Clone Protocol-7 for reference**
   ```bash
   cd /home/claude/work
   git clone https://github.com/nailara-technologies/protocol-7.git
   cd protocol-7
   git checkout base
   
   # Study ELF resumability implementation
   cat bin/dev/elf-continue
   ```

2. **Examine BMW.xs structure**
   ```bash
   cd /home/claude/work/digest-bmw
   less BMW.xs  # Look for state structure
   
   # Find the context structure
   grep -n "typedef.*struct" BMW.xs
   grep -n "bmw.*ctx" BMW.xs
   ```

3. **Design state serialization**
   - Identify `bmw_ctx` or equivalent structure
   - Determine what needs to be saved (hash state, buffer, counters)

4. **Implement XS methods** (example):
   ```c
   // Example clone() implementation
   SV* clone(SV* self) {
       bmw_ctx* ctx = get_context(self);
       bmw_ctx* new_ctx = malloc(sizeof(bmw_ctx));
       memcpy(new_ctx, ctx, sizeof(bmw_ctx));
       return create_perl_object(new_ctx);
   }
   
   // Example getstate() implementation
   SV* getstate(SV* self) {
       bmw_ctx* ctx = get_context(self);
       return newSVpvn((char*)ctx, sizeof(bmw_ctx));
   }
   
   // Example setstate() implementation
   void setstate(SV* self, SV* state_sv) {
       bmw_ctx* ctx = get_context(self);
       STRLEN len;
       char* state_data = SvPV(state_sv, len);
       if (len != sizeof(bmw_ctx)) croak("Invalid state size");
       memcpy(ctx, state_data, sizeof(bmw_ctx));
   }
   ```

5. **Generate patch**
   ```bash
   git diff > /mnt/user-data/outputs/bmw-state-serialization.patch
   ```

---

## Deliverables

Place all outputs in `/mnt/user-data/outputs/`:

1. ✅ `bmw-test-results.txt` - Raw test output
2. ✅ `bmw-analysis-report.md` - Complete analysis with findings
3. ✅ `bmw-state-serialization.patch` - Implementation (if needed)
4. ✅ `bmw-implementation-notes.md` - Technical details

---

## Reference: ELF7 Resumability

Protocol-7's ELF7 checksum supports resumable computation:

```perl
# From Protocol-7's bin/dev/elf-continue (simplified)
sub elf_continue {
    my ($seed, $data) = @_;
    my $h = $seed;  # Resume from previous state
    
    for my $char (split //, $data) {
        my $g = ($h << 4) + ord($char);
        $h = $g & 0x0FFFFFFF;
    }
    
    return $h;  # Return new state
}
```

**Goal**: BMW should have equivalent capability.

---

## Success Criteria

- ✅ BMW module builds successfully
- ✅ Resumability status determined
- ✅ Tests pass and validate correctness
- ✅ Complete documentation generated
- ✅ Ready for Protocol-7 integration

---

**Let's enable streaming signatures for Protocol-7! 🌀✨🔐**