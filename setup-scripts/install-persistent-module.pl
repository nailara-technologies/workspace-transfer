#!/usr/bin/perl
use v5.24;
use strict;
use warnings;

## Install Perl modules to persistent location ##

my $persistent_lib = '/mnt/user-data/perl5';

# Set environment
$ENV{PERL5LIB}           = "$persistent_lib/lib/perl5:$ENV{PERL5LIB}";
$ENV{PERL_LOCAL_LIB_ROOT} = $persistent_lib;
$ENV{PERL_MB_OPT}        = "--install_base $persistent_lib";
$ENV{PERL_MM_OPT}        = "INSTALL_BASE=$persistent_lib";

if (!@ARGV) {
    die "Usage: $0 <Module::Name> [Module::Name2 ...]\n";
}

foreach my $module (@ARGV) {
    say "Installing $module to $persistent_lib...";
    system('cpanm', '--local-lib', $persistent_lib, $module);
    
    if ($? == 0) {
        say "✓ $module installed successfully";
    } else {
        warn "✗ Failed to install $module";
    }
}
