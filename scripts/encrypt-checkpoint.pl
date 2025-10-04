#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use Crypt::Twofish;
use Crypt::Misc qw(encode_b32r decode_b32r);
use Digest::SHA qw(sha256);

# Encrypt Context Checkpoint
# Secure checkpoint files with Twofish encryption (BASE32 encoded)

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
    say "encrypt-checkpoint.pl version $VERSION";
    exit 0;
}

# Validate input
die "Error: --input required\n" unless $opt{input};
die "Error: Input file does not exist: $opt{input}\n" unless -f $opt{input};

# Determine output filename
unless ($opt{output}) {
    $opt{output} = $opt{input};
    $opt{output} =~ s/\.md$//;
    $opt{output} .= '.enc';
}

# Get encryption key
my $key = get_encryption_key(\%opt);
die "Error: Encryption key required\n" unless $key;

# Read input file
open my $in_fh, '<', $opt{input} or die "Cannot read $opt{input}: $!\n";
my $plaintext = do { local $/; <$in_fh> };
close $in_fh;

# Encrypt
my $encrypted = encrypt_checkpoint($plaintext, $key);

# Write output file
open my $out_fh, '>', $opt{output} or die "Cannot write $opt{output}: $!\n";
print $out_fh $encrypted;
close $out_fh;

say "✓ Checkpoint encrypted: $opt{output}";
say "  Algorithm: Twofish-256";
say "  Encoding:  BASE32";
say "  Size:      " . length($encrypted) . " bytes";
say "";
say "💡 To decrypt:";
say "   perl scripts/decrypt-checkpoint.pl --input=$opt{output}";
say "";

exit 0;

###############################################################################
# Subroutines
###############################################################################

sub get_encryption_key {
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
    say "Encryption key required.";
    say "Enter key (will not echo):";
    system('stty', '-echo');
    my $key = <STDIN>;
    system('stty', 'echo');
    say "";
    chomp $key;
    
    return $key if length $key;
    return undef;
}

sub encrypt_checkpoint {
    my ($plaintext, $passphrase) = @_;
    
    # Derive 256-bit key from passphrase using SHA-256
    my $key = sha256($passphrase);
    
    # Pad plaintext to 16-byte blocks (Twofish block size)
    my $block_size = 16;
    my $pad_length = $block_size - (length($plaintext) % $block_size);
    $plaintext .= chr($pad_length) x $pad_length;
    
    # Initialize Twofish cipher
    my $cipher = Crypt::Twofish->new($key);
    
    # Encrypt in CBC mode with simple IV (zeros)
    # Note: For production, use random IV and prepend to ciphertext
    my $iv = "\x00" x $block_size;
    my $ciphertext = '';
    
    for (my $i = 0; $i < length($plaintext); $i += $block_size) {
        my $block = substr($plaintext, $i, $block_size);
        
        # XOR with IV (CBC mode)
        $block ^= $iv;
        
        # Encrypt block
        my $encrypted_block = $cipher->encrypt($block);
        $ciphertext .= $encrypted_block;
        
        # Use encrypted block as next IV
        $iv = $encrypted_block;
    }
    
    # Encode as BASE32
    my $encoded = encode_b32r($ciphertext);
    
    # Create encrypted file format
    my $output = <<"END_HEADER";
# ENCRYPTED CHECKPOINT
# Algorithm: Twofish-256 (CBC mode)
# Encoding: BASE32
# DO NOT MODIFY - decryption will fail

---BEGIN ENCRYPTED CHECKPOINT---
$encoded
---END ENCRYPTED CHECKPOINT---
END_HEADER

    return $output;
}

sub print_usage {
    print <<"END_USAGE";
encrypt-checkpoint.pl - Encrypt checkpoint files with Twofish

USAGE:
    $0 --input=FILE [OPTIONS]

OPTIONS:
    --input, -i FILE      Input checkpoint file (.md)
    --output, -o FILE     Output encrypted file (.enc) [default: input.enc]
    --key, -k KEY         Encryption key (not recommended - visible in ps)
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
    $0 --input=checkpoint.md
    
    # From key file
    $0 --input=checkpoint.md --key-file=.checkpoint-key
    
    # From environment
    export CHECKPOINT_KEY="my-secret-key"
    $0 --input=checkpoint.md
    
    # Specify output
    $0 --input=checkpoint.md --output=secure.enc

ENCRYPTION:
    Algorithm: Twofish-256 (256-bit key)
    Mode:      CBC (Cipher Block Chaining)
    Encoding:  BASE32 (safe for text transmission)
    Key:       Derived from passphrase via SHA-256

SECURITY NOTES:
    - Encrypted files (.enc) are safe to commit to git
    - Original files (.md) should stay local (in .gitignore)
    - Use strong, unique passphrases
    - Store keys securely (Projects custom instructions)
    - Never commit keys to repository

SEE ALSO:
    decrypt-checkpoint.pl  - Decrypt encrypted checkpoints

END_USAGE
}
