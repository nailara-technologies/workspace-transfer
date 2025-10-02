#!/usr/bin/perl
use v5.24;
use strict;
use warnings;

my @critical_modules = qw(
    Digest::Elf
    Time::HiRes
    File::Spec
    FindBin
    IO::Handle
    List::MoreUtils
    Inline::C
    Crypt::Misc
);

my @already_available;
my @missing;

foreach my $module (@critical_modules) {
    my $check = eval "require $module; 1";
    if ($check) {
        push @already_available, $module;
        my $version = eval "\$${module}::VERSION" // 'unknown';
        printf "✓ %-25s %s\n", $module, $version;
    } else {
        push @missing, $module;
        printf "✗ %-25s NOT FOUND\n", $module;
    }
}

say "\n=== SUMMARY ===";
say "Available: " . scalar(@already_available);
say "Missing: " . scalar(@missing);

# Check if we can use cpanm locally
say "\n=== CPANM Check ===";
if (system('which cpanm > /dev/null 2>&1') == 0) {
    say "✓ cpanm is available";
} else {
    say "✗ cpanm not found";
}

# Check Perl version
say "\n=== Perl Info ===";
printf "Perl version: %s\n", $^V;
printf "Install paths: %s\n", join(', ', map { s|/[^/]+$||; $_ } grep { m|perl| } @INC);
