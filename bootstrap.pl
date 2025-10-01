#!/usr/bin/env perl
use strict;
use warnings;
use v5.30;
use File::Spec;

## LIVING TREE BOOTSTRAP VALIDATOR
## One-command workspace validation and status check

say "=" x 70;
say "🌳 Living Tree Bootstrap Validator";
say "=" x 70;
say "";

my $all_pass = 1;
my @warnings;
my @errors;

## Check: Git repository
say "📁 Checking git repository...";
if (-d '.git') {
    my $branch = `git branch --show-current 2>/dev/null`;
    chomp $branch;
    if ($branch) {
        say "   ✓ Git repository: branch '$branch'";
    } else {
        push @warnings, "Git branch detection failed";
        say "   ⚠ Git branch detection failed";
    }
} else {
    push @errors, "Not a git repository";
    say "   ✗ Not a git repository!";
    $all_pass = 0;
}

## Check: Core files exist
say "\n📦 Checking core files...";
my @required_files = (
    'core/base32_harmonic_routing.pl',
    'core/living_tree_base32_viz.html',
    'core/BASE32_HARMONIC_INTEGRATION_GUIDE.md',
    'core/LIVING_TREE_SUMMARY.md',
    'core/PROTOCOL7_HARMONIC_LIVING_TREE.md',
);

my $files_ok = 1;
for my $file (@required_files) {
    if (-f $file) {
        my $size = -s $file;
        say "   ✓ $file ($size bytes)";
    } else {
        push @errors, "Missing file: $file";
        say "   ✗ Missing: $file";
        $files_ok = 0;
        $all_pass = 0;
    }
}

## Check: Perl syntax
say "\n🔍 Checking Perl syntax...";
my @perl_files = glob('core/*.pl implementations/*.pl *.pl');
my $syntax_ok = 1;
for my $pl (@perl_files) {
    next if $pl =~ /bootstrap\.pl$/; # Don't check ourselves while running
    my $result = `perl -c $pl 2>&1`;
    if ($result =~ /syntax OK/) {
        say "   ✓ $pl";
    } else {
        push @errors, "Syntax error in $pl";
        say "   ✗ $pl: $result";
        $syntax_ok = 0;
        $all_pass = 0;
    }
}

## Test: Run BASE32 implementation
say "\n🧪 Testing BASE32 implementation...";
my $test_output = `perl core/base32_harmonic_routing.pl 2>&1`;
if ($? == 0 && $test_output =~ /Octal Frame Tests|Demo Output/) {
    say "   ✓ BASE32 implementation runs successfully";
} else {
    push @warnings, "BASE32 test produced unexpected output";
    say "   ⚠ BASE32 test output unusual (check manually)";
}

## Check: Dependencies
say "\n📚 Checking system dependencies...";
my @deps = (
    ['perl', 'perl --version'],
    ['git', 'git --version'],
    ['base32', 'base32 --version'],
);

for my $dep (@deps) {
    my ($name, $cmd) = @$dep;
    my $check = `which $name 2>/dev/null`;
    if ($check) {
        chomp $check;
        say "   ✓ $name: $check";
    } else {
        push @warnings, "Optional dependency missing: $name";
        say "   ⚠ $name not found (may be needed for some operations)";
    }
}

## Summary
say "\n" . "=" x 70;
say "📊 VALIDATION SUMMARY";
say "=" x 70;

if ($all_pass && @warnings == 0) {
    say "\n✅ ALL CHECKS PASSED - System fully operational!";
    say "\n🚀 Ready to:";
    say "   • Run: perl core/base32_harmonic_routing.pl";
    say "   • View: core/living_tree_base32_viz.html";
    say "   • Code: Start developing new features";
    say "   • Commit: ./commit_checkpoint.pl 'your changes'";
} elsif ($all_pass && @warnings > 0) {
    say "\n⚠️  PASSED WITH WARNINGS";
    say "\nWarnings:";
    say "   • $_" for @warnings;
    say "\nSystem is functional but check warnings above.";
} else {
    say "\n❌ VALIDATION FAILED";
    if (@errors) {
        say "\nErrors:";
        say "   • $_" for @errors;
    }
    if (@warnings) {
        say "\nWarnings:";
        say "   • $_" for @warnings;
    }
    say "\nFix errors above before proceeding.";
}

say "\n📖 Documentation:";
say "   • Quick start: INSTANT_BOOT.md";
say "   • Current status: QUICK_STATUS.md";
say "   • Work plan: WORK_PLAN.md";

say "\n" . "=" x 70;

exit($all_pass ? 0 : 1);
