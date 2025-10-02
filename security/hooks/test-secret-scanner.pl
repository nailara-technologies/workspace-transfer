#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Temp qw(tempdir tempfile);
use File::Path qw(make_path remove_tree);

# Test Suite for Pre-commit Secret Scanner
# Note: Test secrets stored in __DATA__ section with obfuscation
# Pattern: * characters are replaced with real chars to avoid detection

say "🧪 Testing Pre-commit Secret Scanner";
say "=" x 60;
say "";

my $scanner = '/home/claude/work/pre-commit-secret-scanner.pl';

unless (-x $scanner) {
    die "❌ Scanner not found or not executable: $scanner\n";
}

# Create temporary test directory
my $test_dir = tempdir(CLEANUP => 1);
say "📁 Test directory: $test_dir";
say "";

# Load and deobfuscate test cases from __DATA__
sub deobfuscate {
    my $text = shift;
    # Replace * with actual characters to create real patterns
    $text =~ s/g\*p_/ghp_/g;              # GitHub classic
    $text =~ s/g\*thub_pat/github_pat/g;  # GitHub fine-grained
    $text =~ s/AK\*A/AKIA/g;               # AWS
    $text =~ s/x\*xb/xoxb/g;               # Slack
    $text =~ s/BEG\*N/BEGIN/g;             # SSH key header
    $text =~ s/\*AT\*/\@/g;                # @ symbol in URLs
    return $text;
}

my %tests;
my $current_test;
my $in_content = 0;
my $content_buffer = '';

while (my $line = <DATA>) {
    chomp $line;
    
    if ($line =~ /^\[TEST: (.+)\]$/) {
        # Save previous test if exists
        if ($current_test && $content_buffer) {
            $tests{$current_test}{content} = deobfuscate($content_buffer);
            $content_buffer = '';
        }
        $current_test = $1;
        $in_content = 0;
    } elsif ($line =~ /^SHOULD_FAIL: (\d)$/) {
        $tests{$current_test}{should_fail} = $1;
    } elsif ($line =~ /^CONTENT:$/) {
        $in_content = 1;
        $content_buffer = '';
    } elsif ($in_content && $line =~ /^---$/) {
        $in_content = 0;
    } elsif ($in_content) {
        $content_buffer .= $line . "\n";
    }
}

# Save last test
if ($current_test && $content_buffer) {
    $tests{$current_test}{content} = deobfuscate($content_buffer);
}

my $passed = 0;
my $failed = 0;

for my $test_name (sort keys %tests) {
    my $test = $tests{$test_name};
    
    # Create test file
    my ($fh, $filename) = tempfile(DIR => $test_dir, SUFFIX => '.txt');
    print $fh $test->{content};
    close $fh;
    
    # Run scanner
    my $exit_code = system($scanner, $filename, '>/dev/null', '2>&1');
    my $detected_secret = ($exit_code != 0);
    
    my $test_passed = ($detected_secret == $test->{should_fail});
    
    if ($test_passed) {
        say "✅ PASS: $test_name";
        $passed++;
    } else {
        say "❌ FAIL: $test_name";
        say "   Expected: " . ($test->{should_fail} ? "detect" : "allow");
        say "   Got: " . ($detected_secret ? "detected" : "allowed");
        $failed++;
    }
    
    unlink $filename;
}

say "";
say "=" x 60;
say "📊 Test Results";
say "=" x 60;
say "✅ Passed: $passed";
say "❌ Failed: $failed";
say "📈 Total: " . ($passed + $failed);
say "";

if ($failed > 0) {
    say "❌ Some tests failed!";
    exit 1;
} else {
    say "✅ All tests passed!";
    exit 0;
}

__DATA__
# Test Data Section
# ==================
# Test secrets are stored with obfuscation to prevent detection by GitHub's
# push protection and similar scanning tools. The deobfuscate() function
# replaces * characters with real characters at runtime.
#
# Obfuscation patterns:
#   g*p_        → ghp_          (GitHub classic tokens)
#   g*thub_pat  → github_pat    (GitHub fine-grained tokens)
#   AK*A        → AKIA          (AWS access keys)
#   x*xb        → xoxb          (Slack tokens)
#   BEG*N       → BEGIN         (SSH key headers)
#   *AT*        → @             (@ symbol in URLs/emails)
#
# This allows realistic test data while avoiding false positives in
# automated security scans.

[TEST: Clean file]
SHOULD_FAIL: 0
CONTENT:
# This is a clean file
NO_SECRETS_HERE=true
---

[TEST: GitHub classic token]
SHOULD_FAIL: 1
CONTENT:
TOKEN=g*p_1234567890123456789012345678901234AB
---

[TEST: GitHub fine-grained token]
SHOULD_FAIL: 1
CONTENT:
AUTH=g*thub_pat_11AHC76DY0twCDz61ohJX3_iq2xdiHiVC2FMzW7pXMMp6Ab3WqiSVGdBZrTJXkPBwPP4LL4EYS71a9BRLR
---

[TEST: SSH private key]
SHOULD_FAIL: 1
CONTENT:
-----BEG*N RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
---

[TEST: AWS access key]
SHOULD_FAIL: 1
CONTENT:
AWS_KEY=AK*AIOSFODNN7EXAMPLE
---

[TEST: Password in URL]
SHOULD_FAIL: 1
CONTENT:
URL=https://user:secret123*AT*example.com/repo
---

[TEST: Safe placeholder]
SHOULD_FAIL: 0
CONTENT:
TOKEN=YOUR_TOKEN_HERE
KEY=INSERT_KEY
---

[TEST: Slack token]
SHOULD_FAIL: 1
CONTENT:
SLACK=x*xb-123456789012-1234567890123-AbCdEfGhIjKlMnOpQrStUvWx
---
