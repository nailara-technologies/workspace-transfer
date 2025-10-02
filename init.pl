#!/usr/bin/perl
# init.pl - MANDATORY FIRST STEP
# Run this BEFORE reading anything else

use v5.24;
use strict;
use warnings;

say "";
say "=" x 70;
say "🚦 INITIALIZATION CHECKPOINT";
say "=" x 70;
say "";

# Check if already initialized
if (-f '.initialized') {
    say "✅ Already initialized - you may proceed";
    say "";
    say "Next step: perl status-check.pl";
    say "=" x 70;
    exit 0;
}

say "⚠️  CRITICAL: You are attempting to work without initialization!";
say "";
say "This session requires bootstrap before proceeding.";
say "Reading documentation before initialization wastes tokens.";
say "";
say "=" x 70;
say "REQUIRED ACTIONS:";
say "=" x 70;
say "";
say "1. Run bootstrap:";
say "   perl bootstrap.pl";
say "";
say "2. Create initialization marker:";
say "   touch .initialized";
say "";
say "3. Run this script again to verify:";
say "   perl init.pl";
say "";
say "=" x 70;
say "";
say "🛑 DO NOT PROCEED until you see the ✅ message above";
say "";

exit 1;
