#!/usr/bin/perl

use strict;
use warnings;
use File::Slurp;
use Text::HybridEncoder;

# Create a HybridEncoder object
my $encoder = Text::HybridEncoder->new();

# Add some templates
$encoder->add_template('greeting', 'Hello, world!');
$encoder->add_template('farewell', 'Goodbye, everyone!');

# Add binary data (e.g., image file)
my $image_data = read_file('example_image.png', binmode => ':raw');
$encoder->add_binary_data('image', $image_data);

# Original data stream
my $data_stream = 'Hello, world! This is a test. Goodbye, everyone!';

# Encode the data stream
my $encoded_stream = $encoder->encode_stream($data_stream);
print "Encoded Stream: $encoded_stream\n";

# Decode the data stream
my $decoded_stream = $encoder->decode_stream($encoded_stream);
print "Decoded Stream: $decoded_stream\n";

# Save templates and binary data to files
$encoder->save_templates('templates.dat');
$encoder->save_binary_data('binary_data.dat');

# Load templates and binary data from files
my $decoder = Text::HybridEncoder->new();
$decoder->load_templates('templates.dat');
$decoder->load_binary_data('binary_data.dat');

# Decode the data stream using loaded templates and binary data
my $decoded_stream_loaded = $decoder->decode_stream($encoded_stream);
print "Decoded Stream (Loaded Templates and Binary Data): $decoded_stream_loaded\n";