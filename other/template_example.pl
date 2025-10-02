#!/usr/bin/perl

use strict;
use warnings;
use Text::TemplateEncoder;

# Create a TemplateEncoder object
my $encoder = Text::TemplateEncoder->new();

# Add some templates
$encoder->add_template('greeting', 'Hello, world!');
$encoder->add_template('farewell', 'Goodbye, everyone!');

# Original data stream
my $data_stream = 'Hello, world! This is a test. Goodbye, everyone!';

# Encode the data stream
my $encoded_stream = $encoder->encode_stream($data_stream);
print "Encoded Stream: $encoded_stream\n";

# Decode the data stream
my $decoded_stream = $encoder->decode_stream($encoded_stream);
print "Decoded Stream: $decoded_stream\n";

# Save templates to a file
$encoder->save_templates('templates.dat');

# Load templates from a file
my $decoder = Text::TemplateEncoder->new();
$decoder->load_templates('templates.dat');

# Decode the data stream using loaded templates
my $decoded_stream_loaded = $decoder->decode_stream($encoded_stream);
print "Decoded Stream (Loaded Templates): $decoded_stream_loaded\n";