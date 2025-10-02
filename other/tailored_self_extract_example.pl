#!/usr/bin/perl

use strict;
use warnings;
use Text::TailoredSelfExtractingDocument;

# Define precomputed steps and state data
my @steps = (
    'echo "Installing dependencies..."',
    'apt-get update',
    'apt-get install -y apache2',
    'echo "Configuring system..."',
    'systemctl enable apache2',
    'systemctl start apache2'
);
my $state_data = read_file('initial_state.dat', binmode => ':raw');

# Create a TailoredSelfExtractingDocument object
my $doc = Text::TailoredSelfExtractingDocument->new(steps => \@steps, state_data => $state_data);

# Original content
my $content = 'This is a sample content with embedded instructions.';

# Embed the encoded steps and state data into the content
my $embedded_content = $doc->embed_in_content($content);
print "Embedded Content: $embedded_content\n";

# Extract and execute the instructions from the content
$doc->extract_and_execute($embedded_content);