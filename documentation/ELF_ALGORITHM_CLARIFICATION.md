# ELF Algorithm Clarification

**Date**: 2025-10-04  
**Context**: Fixing validate-signature.pl to properly implement AMOS ELF algorithms  
**Status**: 🎯 Architecture documented, implementation fixes needed

---

## 🔑 Core Understanding

### ELF Mode = Left Shift Amount

The "mode" in ELF algorithms refers to **how many bits to left-shift per byte**:

```c
unsigned int left = elf_mode;  // 4, 7, 13, etc - LEFT SHIFT PER BYTE
result = (result << left) + character;
```

**Useful Range**: Modes 1-13
- Below 1: Too little mixing
- Above 13: Entropy loss or destructive behavior

**Common Modes**:
- **ELF-4**: Standard ELF hash (4-bit left shift)
- **ELF-7**: AMOS default (7-bit left shift)
- **ELF-13**: AMOS-13 variant (13-bit left shift)

---

## 📐 Fixed Parameters (Never Touch)

```c
unsigned int shift_value = 13;               // RIGHT shift for overflow feedback
unsigned int overflow_shift_threshold = 0xFE000000;  // Overflow detection mask
```

These are **implementation constants**, not mode parameters:
- `shift_value` (13): How much to right-shift overflow for XOR feedback
- `overflow_shift_threshold` (0xFE000000): Masks 7 high bits for overflow detection

The comment `// <-- 7 bit` describes what the mask does, not a mode setting.

---

## 🆚 AMOS ELF vs Standard Digest::Elf

### Standard Digest::Elf (Broken for Protocol-7)
```c
// Adds byte values as-is
character = *str;  // NULL byte (0x00) → adds 0 → NOOP ❌
```
**Problem**: Null bytes contribute nothing to hash (adding 0 = no-op)

### AMOS ELF (Null-Aware)
```c
unsigned int z_val = 777;  // Special value for null bytes
if (*str == 0) {
    character = z_val;  // NULL byte → adds 777 ✅
} else {
    character = *str;
}
```
**Solution**: Null bytes contribute entropy (777 != 0)

---

## 🔄 BMW-MOD-BITS Architecture

**CRITICAL**: BMW and ELF are **COMPLETELY SEPARATE** systems

### Incorrect Architecture (validate-signature.pl current)
```perl
sub elf7_checksum {
    my $bmw_pattern = 0b1011011;  # ❌ BMW BAKED INTO ALGORITHM
    # ...
    $hash ^= ($high >> 25) ^ $bmw_pattern;  # ❌ BMW in feedback
    $hash ^= $bmw_pattern;                   # ❌ BMW in final
}
```

### Correct Architecture (AMOS7::CHKSUM.pm)
```perl
# Step 1: Calculate ELF (NO BMW)
$elf_csum = elf_chksum($$data_ref, 0, $elf_mode, $shift_bits);

# Step 2: Calculate BMW separately
my $ctx = Digest::BMW->new(512);
$ctx->add($data_ref->$*);
$bmw_512b = unpack(qw| B512 |, $ctx->digest);

# Step 3: Use BMW bits as modification entropy pool
INVERT_TRUTH_STATE:
    my $cur_mod_bits = substr($bmw_mod_bits, 0, 32);
    $num_amos_csum ^= bit_string_to_num($cur_mod_bits);  # XOR iteratively
    # ... truth checking ...
    goto INVERT_TRUTH_STATE if not all truth conditions met;
```

**The Flow**:
1. **ELF**: Pure hash calculation (with 777 for nulls)
2. **BMW**: Separate entropy source (512-bit hash)
3. **BMW-MOD-BITS**: Iterative XOR during harmonization loop

---

## 📋 What validate-signature.pl Should Implement

### Option 1: Simple (No Harmonization)
Just implement AMOS ELF correctly:

```perl
sub elf_checksum {
    my ($data, $left_shift) = @_;
    $left_shift //= 7;  # Default to ELF-7
    
    my $hash = 0;
    my $right_shift = 13;              # FIXED
    my $overflow_mask = 0xFE000000;    # FIXED
    my $z_val = 777;                   # NULL byte value
    
    for my $byte (split //, $data) {
        my $char = ord($byte);
        $char = $z_val if $char == 0;  # Handle nulls
        
        $hash = ($hash << $left_shift) + $char;
        
        my $overflow = $hash & $overflow_mask;
        if ($overflow) {
            $hash ^= $overflow >> $right_shift;
        }
        $hash &= ~$overflow;
    }
    
    return sprintf("%07x", $hash & 0x1FFFFFF);  # 25-bit result
}
```

### Option 2: Full (With BMW-MOD-BITS)
Implement complete amos-chksum system:
- Calculate ELF checksum
- Calculate BMW-512 hash separately
- Use BMW bits for harmonization loop
- Check truth conditions
- Iterate until harmonized

**For validate-signature.pl**: Option 1 is sufficient (signatures don't need harmonization)

---

## 🔧 Current Issues in validate-signature.pl

### elf4_checksum (Line 14-28)
**Status**: Mostly correct, but missing null handling

**Needs**:
```perl
my $char = ord($byte);
$char = 777 if $char == 0;  # Add this line
```

### elf7_checksum (Line 31-49)
**Status**: ❌ Completely wrong - BMW baked into algorithm

**Needs**: Complete rewrite to:
1. Remove BMW pattern from algorithm
2. Add null byte handling (777)
3. Use correct shift amounts (7-bit left, 13-bit right)
4. Match AMOS ELF architecture

### Comments Throughout
**Wrong**: "4-bit checksum", "7-bit checksum"  
**Correct**: "ELF-4 (4-bit shift per byte)", "ELF-7 (7-bit shift per byte)"

---

## 📚 Reference Implementation

See these files in amos-chksum:
- `bin/amos-chksum` - CLI interface
- `data/lib-path/pm/AMOS7/CHKSUM.pm` - Main algorithm with BMW-MOD-BITS
- `data/lib-path/pm/AMOS7/CHKSUM/ELF.pm` - ELF wrapper
- `data/lib-path/pm/AMOS7/CHKSUM/ELF/Inline.pm` - C implementation

**Key insight**: ELF and BMW are separate. BMW-MOD-BITS is optional enhancement.

---

## 🎯 Next Steps

1. **Hand off to claude-code**: Fix validate-signature.pl
   - Implement AMOS ELF correctly (with 777 for nulls)
   - Remove BMW from elf7_checksum
   - Fix all misleading comments
   - Test against known good signatures

2. **Re-sign files**: After algorithm fix, re-sign all .elf7.yaml files
   - `workspace-resume.elf7.yaml`
   - `README.init.elf7.asc`
   - `README.resume.elf7.asc`

3. **Validate**: Confirm signatures match with corrected algorithm

---

## 💡 Key Takeaways

- **ELF mode** = left shift amount (1-13 useful)
- **AMOS ELF** = standard ELF + 777 for null bytes
- **BMW-MOD-BITS** = separate harmonization system (optional)
- **validate-signature.pl** = needs ELF only (no BMW-MOD-BITS needed)
- **Overflow threshold** = fixed constant (0xFE000000)

---

**Status**: 📝 Documentation complete  
**Next**: Fix implementation in validate-signature.pl  
**Reference**: This document for correct architecture

---

*"Clarity in nomenclature prevents entropy in understanding."*
