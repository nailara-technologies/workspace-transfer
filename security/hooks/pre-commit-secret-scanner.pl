#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use Term::ANSIColor qw(:constants);

# Pre-commit hook: Secret Scanner
# Prevents committing GitHub tokens, SSH keys, and other secrets

my $allow_override = 0;
if (@ARGV && $ARGV[0] eq '--force') {
    $allow_override = 1;
    shift @ARGV;
}

# Secret patterns to detect
my %patterns = (
    'GitHub Classic Token' => qr/\bghp_[a-zA-Z0-9]{36}\b/,
    'GitHub Fine-grained Token' => qr/\bgithub_pat_[a-zA-Z0-9_]{82}\b/,
    'GitHub OAuth Token' => qr/\bgho_[a-zA-Z0-9]{36}\b/,
    'GitHub App Token' => qr/\b(ghu|ghs)_[a-zA-Z0-9]{36}\b/,
    'Generic API Key' => qr/\b[aA][pP][iI][_-]?[kK][eE][yY][_-]?['\"]?[:=]\s*['\"]?[a-zA-Z0-9]{20,}\b/,
    'AWS Access Key' => qr/\bAKIA[0-9A-Z]{16}\b/,
    'Private SSH Key Header' => qr/-----BEGIN (?:RSA|DSA|EC|OPENSSH) PRIVATE KEY-----/,
    'Password in URL' => qr/\b(?:https?|ftp):\/\/[^:]+:[^@]+@/,
    'Slack Token' => qr/\bxox[baprs]-[0-9a-zA-Z-]+/,
    'Generic Secret' => qr/\b(?:secret|password|passwd|pwd)[\s_-]*[:=][\s'"]*[a-zA-Z0-9!@#$%^&*()_+={}\[\]:;"'<>,.?\/\\|-]{8,}/i,
);

# Files to check (staged for commit)
my @files_to_check;
if (@ARGV) {
    @files_to_check = @ARGV;
} else {
    # Get staged files from git
    @files_to_check = `git diff --cached --name-only --diff-filter=ACM`;
    chomp @files_to_check;
}

unless (@files_to_check) {
    say GREEN "✅ No files to scan";
    exit 0;
}

# Track findings
my @violations;
my $files_scanned = 0;

for my $file (@files_to_check) {
    # Skip binary files and large files
    next unless -f $file;
    next if -B $file;
    next if -s $file > 1_000_000;  # Skip files > 1MB
    
    # Skip certain directories
    next if $file =~ m{^\.git/};
    next if $file =~ m{/node_modules/};
    next if $file =~ m{/vendor/};
    
    $files_scanned++;
    
    open my $fh, '<', $file or do {
        warn "Cannot read $file: $!\n";
        next;
    };
    
    my $line_num = 0;
    while (my $line = <$fh>) {
        $line_num++;
        
        for my $secret_type (sort keys %patterns) {
            if ($line =~ $patterns{$secret_type}) {
                my $match = $&;
                # Redact most of the secret for display
                my $redacted = substr($match, 0, 8) . '...' . substr($match, -4);
                
                push @violations, {
                    file => $file,
                    line => $line_num,
                    type => $secret_type,
                    match => $redacted,
                    full_line => $line,
                };
            }
        }
    }
    close $fh;
}

# Report findings
if (@violations) {
    say "";
    say RED BOLD "🚨 SECRET DETECTION - COMMIT BLOCKED 🚨";
    say RED "━" x 70;
    say "";
    say YELLOW "Found ", scalar(@violations), " potential secret(s) in ", scalar(@violations), " location(s):";
    say "";
    
    for my $v (@violations) {
        say RED "  ❌ $v->{file}:$v->{line}";
        say YELLOW "     Type: $v->{type}";
        say CYAN   "     Match: $v->{match}";
        say "";
    }
    
    say RED "━" x 70;
    say "";
    say BOLD "🛡️  SECURITY PROTECTION ACTIVE";
    say "";
    say "Secrets detected in files staged for commit.";
    say "These patterns match sensitive credentials that should NOT be committed.";
    say "";
    say BOLD "Options:";
    say "";
    say "  1. " . GREEN "RECOMMENDED" . RESET . ": Remove or redact secrets from files";
    say "     - Replace tokens with placeholders like: YOUR_TOKEN_HERE";
    say "     - Use environment variables or config files (gitignored)";
    say "     - Store secrets in secure credential managers";
    say "";
    say "  2. " . YELLOW "OVERRIDE" . RESET . " (use with extreme caution):";
    say "     git commit --no-verify    (bypasses this hook entirely)";
    say "     OR";
    say "     GIT_ALLOW_SECRETS=1 git commit    (environment override)";
    say "";
    say "  3. " . CYAN "REVIEW" . RESET . ": Check if detection is false positive";
    say "     - Examine the matched patterns above";
    say "     - Ensure they're not actual secrets";
    say "";
    say RED "━" x 70;
    say "";
    
    # Check for override
    if ($allow_override || $ENV{GIT_ALLOW_SECRETS}) {
        say YELLOW "⚠️  OVERRIDE ACTIVE - Allowing commit despite secrets detected";
        say YELLOW "   (You used --no-verify or GIT_ALLOW_SECRETS=1)";
        say "";
        exit 0;
    }
    
    exit 1;
}

# Success - no secrets detected
say GREEN "✅ Secret scan complete: No secrets detected";
say GREEN "   Files scanned: $files_scanned";
say GREEN "   Commit allowed to proceed";
exit 0;
