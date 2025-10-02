#!/usr/bin/perl

use strict;
use warnings;
use Text::LayeredHashingWithApprox;

# Create a LayeredHashingWithApprox object
my $hasher = Text::LayeredHashingWithApprox->new();

# Example messages
my @messages = (
    'Message 1: The quick brown fox jumps over the lazy dog.',
    'Message 2: Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
    'Message 3: Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
);

# Apply layered hashing with approximation to each message
foreach my $message (@messages) {
    my $hash = $hasher->layered_hash($hasher->approximate_message($message));
    print "Layered Hash with Approximation: $hash\n";
}

# Create a Merkle tree from the messages
my $merkle_root = $hasher->create_merkle_tree(@messages);
print "Merkle Root: $merkle_root\n";