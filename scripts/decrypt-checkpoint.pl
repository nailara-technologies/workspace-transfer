#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Crypt::Twofish;
use Crypt::Misc qw(encode_b32r decode_b32r);
use Digest::SHA qw(sha256);

# Decrypt Context Checkpoint
# Decrypt Twofish-encrypted checkpoint files

my $VERSION = '1.0';

my %opt;
GetOptions(
    'input|i=s'   => \$opt{input},
    'output|o=s'  => \$opt{output},
    'key|k=s'     => \$opt{key},
    'key-file=s'  => \$opt{key_file},
    'help|h'      => \$opt{help},
    'version|v'   => \$opt{version},
) or die "Error in command line arguments\n";

if ($opt{help}) {
    print_usage();
    exit 0;
}

if ($opt{version}) {
    say "decrypt-checkpoint.pl version $VERSION";
    exit 0;
}

# Validate input
die "Error: --input required\n" unless $opt{input};
die "Error: Input file does not exist: $opt{input}\n" unless -f $opt{input};

# Determine output filename
unless ($opt{output}) {
    $opt{output} = $opt{input};
    $opt{output} =~ s/\.enc$//;
    $opt{output} .= '.md' unless $opt{output} =~ /\.md$/;
}

# Get decryption key
my $key = get_decryption_key(\%opt);
die "Error: Decryption key required\n" unless $key;

# Read encrypted file
open my $in_fh, '<', $opt{input} or die "Cannot read $opt{input}: $!\n";
my $encrypted_content = do { local $/; <$in_fh> };
close $in_fh;

# Extract BASE32 ciphertext
my ($ciphertext_b32) = $encrypted_content =~ 
    /---BEGIN ENCRYPTED CHECKPOINT---\s*(.+?)\s*---END ENCRYPTED CHECKPOINT---/s;

die "Error: Invalid encrypted checkpoint format\n" unless $ciphertext_b32;

# Decrypt
my $plaintext = decrypt_checkpoint($ciphertext_b32, $key);

unless ($plaintext) {
    die "Error: Decryption failed (wrong key or corrupted file)\n";
}

# Write output file
open my $out_fh, '>', $opt{output} or die "Cannot write $opt{output}: $!\n";
print $out_fh $plaintext;
close $out_fh;

say "✓ Checkpoint decrypted: $opt{output}";
say "  Algorithm: Twofish-256";
say "  Size:      " . length($plaintext) . " bytes";
say "";

exit 0;

###############################################################################
# Subroutines
###############################################################################

sub get_decryption_key {
    my ($opt) = @_;
    
    # Priority 1: --key parameter
    return $opt->{key} if $opt->{key};
    
    # Priority 2: --key-file parameter
    if ($opt->{key_file}) {
        die "Key file does not exist: $opt->{key_file}\n" 
            unless -f $opt->{key_file};
        open my $fh, '<', $opt->{key_file} 
            or die "Cannot read key file: $!\n";
        my $key = <$fh>;
        close $fh;
        chomp $key;
        return $key if length $key;
    }
    
    # Priority 3: Environment variable
    return $ENV{CHECKPOINT_KEY} if $ENV{CHECKPOINT_KEY};
    
    # Priority 4: Prompt user
    say "Decryption key required.";
    say "Enter key (will not echo):";
    system('stty', '-echo');
    my $key = <STDIN>;
    system('stty', 'echo');
    say "";
    chomp $key;
    
    return $key if length $key;
    return undef;
}

sub decrypt_checkpoint {
    my ($ciphertext_b32, $passphrase) = @_;
    
    # Derive 256-bit key from passphrase using SHA-256
    my $key = sha256($passphrase);
    
    # Decode from BASE32
    my $ciphertext = decode_b32r($ciphertext_b32);
    
    # Initialize Twofish cipher
    my $cipher = Crypt::Twofish->new($key);
    
    # Decrypt in CBC mode
    my $block_size = 16;
    my $iv = "\x00" x $block_size;
    my $plaintext = '';
    
    for (my $i = 0; $i < length($ciphertext); $i += $block_size) {
        my $encrypted_block = substr($ciphertext, $i, $block_size);
        
        # Decrypt block
        my $decrypted_block = $cipher->decrypt($encrypted_block);
        
        # XOR with IV (CBC mode)
        $decrypted_block ^= $iv;
        
        $plaintext .= $decrypted_block;
        
        # Use encrypted block as next IV
        $iv = $encrypted_block;
    }
    
    # Remove padding
    my $pad_length = ord(substr($plaintext, -1));
    
    # Validate padding
    if ($pad_length > 0 && $pad_length <= $block_size) {
        # Check if all padding bytes are correct
        my $valid_padding = 1;
        for (my $i = 1; $i <= $pad_length; $i++) {
            if (ord(substr($plaintext, -$i, 1)) != $pad_length) {
                $valid_padding = 0;
                last;
            }
        }
        
        if ($valid_padding) {
            $plaintext = substr($plaintext, 0, length($plaintext) - $pad_length);
            return $plaintext;
        }
    }
    
    # Padding validation failed - wrong key or corrupted
    return undef;
}

sub print_usage {
    print <<"END_USAGE";
decrypt-checkpoint.pl - Decrypt Twofish-encrypted checkpoints

USAGE:
    $0 --input=FILE [OPTIONS]

OPTIONS:
    --input, -i FILE      Input encrypted file (.enc)
    --output, -o FILE     Output decrypted file (.md) [default: input.md]
    --key, -k KEY         Decryption key (not recommended - visible in ps)
    --key-file FILE       Read key from file
    --help, -h            Show this help
    --version, -v         Show version

KEY SOURCES (in order of priority):
    1. --key parameter (not recommended - visible in process list)
    2. --key-file parameter (recommended)
    3. CHECKPOINT_KEY environment variable
    4. Interactive prompt (secure, no echo)

EXAMPLES:
    # Interactive (most secure)
    $0 --input=checkpoint.enc
    
    # From key file
    $0 --input=checkpoint.enc --key-file=.checkpoint-key
    
    # From environment
    export CHECKPOINT_KEY="my-secret-key"
    $0 --input=checkpoint.enc
    
    # Specify output
    $0 --input=checkpoint.enc --output=restored.md

DECRYPTION:
    Algorithm: Twofish-256 (256-bit key)
    Mode:      CBC (Cipher Block Chaining)
    Encoding:  BASE32 (text-safe)
    Key:       Derived from passphrase via SHA-256

SECURITY NOTES:
    - Keep decryption keys secure
    - Use same key as encryption
    - Wrong key will fail gracefully
    - Decrypted files (.md) should not be committed

SEE ALSO:
    encrypt-checkpoint.pl  - Encrypt checkpoints

END_USAGE
}
