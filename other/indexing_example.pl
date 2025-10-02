#!/usr/bin/perl

use v5.24;
use strict;
use warnings;
use AMOS7::CHKSUM;

sub generate_checksum {
    my ($input, $reduced_length) = @_;
    my $checksum;
    if ($reduced_length) {
        $checksum = AMOS7::CHKSUM::amos_reduced_chksum(\$input);
    } else {
        $checksum = AMOS7::CHKSUM::amos_chksum(\$input);
    }
    return $checksum;
}

sub create_checksum_matrix {
    my ($payload, $rows, $cols, $reduced_length) = @_;
    my @matrix;

    for my $i (0 .. $rows - 1) {
        for my $j (0 .. $cols - 1) {
            my $checksum = generate_checksum("$payload-$i-$j", $reduced_length);
            push @{$matrix[$i]}, $checksum;
        }
    }

    return \@matrix;
}

sub print_matrix {
    my ($matrix) = @_;
    for my $row (@$matrix) {
        say join(' ', @$row);
    }
}

# Example Usage
my $payload = 'HARMONIC_PAYLOAD';
my $rows = 5;
my $cols = 5;
my $reduced_length = 1; # Set to 1 for reduced length, 0 for full length

my $checksum_matrix = create_checksum_matrix($payload, $rows, $cols, $reduced_length);
print_matrix($checksum_matrix);