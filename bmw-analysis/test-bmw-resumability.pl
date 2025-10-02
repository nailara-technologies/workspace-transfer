#!/usr/bin/perl
use v5.24;
use strict;
use warnings;

## Add BMW module from work directory
use lib '/home/claude/work/digest-bmw/blib/lib';
use lib '/home/claude/work/digest-bmw/blib/arch';

## [:< ##
# name = test-bmw-resumability
# desc = Verify BMW state save/restore support

say "=== BMW Resumability Test ===";
say "Loading Digest::BMW from /home/claude/work/digest-bmw";
say "";

# Try loading BMW module
eval {
    require Digest::BMW;
    Digest::BMW->import();
    1;
} or do {
    say "❌ Failed to load Digest::BMW: $@";
    say "";
    say "Build the module first:";
    say "  cd /home/claude/work/digest-bmw";
    say "  perl Makefile.PL";
    say "  make";
    say "  make test";
    exit 1;
};

say "✅ Digest::BMW loaded successfully";
say "";

# Test data
my $test_data = "The quick brown fox jumps over the lazy dog";
my ($chunk1, $chunk2) = (
    substr($test_data, 0, 20),
    substr($test_data, 20)
);

say "Test data: '$test_data'";
say "Chunk 1: '$chunk1'";
say "Chunk 2: '$chunk2'";
say "";

# Method 1: All at once
say "=== Method 1: Complete data ===";
my $bmw1 = Digest::BMW->new(384);
$bmw1->add($test_data);
my $digest1 = $bmw1->hexdigest;
say "Digest: $digest1";
say "";

# Method 2: Sequential chunks
say "=== Method 2: Sequential chunks ===";
my $bmw2 = Digest::BMW->new(384);
$bmw2->add($chunk1);
$bmw2->add($chunk2);
my $digest2 = $bmw2->hexdigest;
say "Digest: $digest2";
say "";

# Verify internal consistency
if ($digest1 eq $digest2) {
    say "✅ BMW is internally consistent";
} else {
    say "❌ FAILED: Digests don't match!";
    exit 1;
}

# Method 3: Check for state save/restore
say "";
say "=== Method 3: State resumability check ===";
say "";

my $has_clone = $bmw1->can('clone');
my $has_getstate = $bmw1->can('getstate');
my $has_setstate = $bmw1->can('setstate');

say "Methods available:";
say "  clone()    : " . ($has_clone ? "✅ YES" : "❌ NO");
say "  getstate() : " . ($has_getstate ? "✅ YES" : "❌ NO");
say "  setstate() : " . ($has_setstate ? "✅ YES" : "❌ NO");
say "";

if ($has_clone) {
    say "Testing clone() method...";
    my $bmw3 = Digest::BMW->new(384);
    $bmw3->add($chunk1);
    
    my $bmw4 = $bmw3->clone;
    $bmw4->add($chunk2);
    my $digest3 = $bmw4->hexdigest;
    
    if ($digest3 eq $digest1) {
        say "✅ BMW supports resumability via clone()";
    } else {
        say "❌ clone() produced different digest!";
        say "   Expected: $digest1";
        say "   Got:      $digest3";
    }
    say "";
}

if ($has_getstate && $has_setstate) {
    say "Testing getstate/setstate methods...";
    my $bmw5 = Digest::BMW->new(384);
    $bmw5->add($chunk1);
    
    my $state = $bmw5->getstate;
    say "State saved: " . length($state) . " bytes";
    
    my $bmw6 = Digest::BMW->new(384);
    $bmw6->setstate($state);
    $bmw6->add($chunk2);
    my $digest4 = $bmw6->hexdigest;
    
    if ($digest4 eq $digest1) {
        say "✅ BMW supports resumability via getstate/setstate";
    } else {
        say "❌ State restoration produced different digest!";
        say "   Expected: $digest1";
        say "   Got:      $digest4";
    }
    say "";
}

if (!$has_clone && !$has_getstate && !$has_setstate) {
    say "⚠️  BMW does NOT support state save/restore";
    say "";
    say "Required implementation:";
    say "  1. Add state serialization to BMW.xs";
    say "  2. Implement getstate() and setstate() methods";
    say "  3. Test with this script";
    say "";
    say "See: /home/claude/work/bmw-state-implementation.md for details";
}

say "";
say "=== Test Complete ===";