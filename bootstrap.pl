#!/usr/bin/perl
# Enhanced bootstrap.pl - Auto-configures workspace in < 5 seconds
# Run this FIRST in every new session

use v5.24;
use strict;
use warnings;

say "🚀 WORKSPACE BOOTSTRAP - Starting...";
say "";

# Helper: Load credentials from file or environment
sub load_credentials {
    my %creds;
    
    # Try .credentials file first
    if (-f '.credentials') {
        open my $fh, '<', '.credentials' or die "Cannot read .credentials: $!";
        while (<$fh>) {
            next if /^\s*#/ || /^\s*$/;
            if (/^(\w+)=(.+)$/) {
                $creds{$1} = $2;
            }
        }
        close $fh;
    }
    
    # Environment variables override file
    $creds{GITHUB_TOKEN} = $ENV{GITHUB_TOKEN} if $ENV{GITHUB_TOKEN};
    $creds{GITHUB_USER} = $ENV{GITHUB_USER} || 'workspace-transfer';
    $creds{GITHUB_EMAIL} = $ENV{GITHUB_EMAIL} || 'workspace-transfer@taeki.v7.ax';
    
    return %creds;
}

# 1. Create working directories
say "📁 Creating work directories...";
system('mkdir -p /home/claude/work') == 0 or warn "mkdir failed: $?";

# 2. Check if we're already in the repo
my $in_repo = -d '.git' && -f 'CLAUDE_ONBOARDING.md';

unless ($in_repo) {
    # We're not in the repo yet, need to clone
    if (-d '/home/claude/workspace-transfer') {
        say "✅ Repository exists at /home/claude/workspace-transfer";
        chdir '/home/claude/workspace-transfer' or die "Cannot cd: $!";
    } else {
        say "📦 Cloning workspace-transfer repository...";
        say "⚠️  NOTE: Token should be provided via .credentials file or GITHUB_TOKEN env var";
        say "    See .credentials.template for format";
        
        # This will fail gracefully if no token is available
        # User can manually clone or provide token
        die "❌ Cannot clone: Not in repository and no existing clone found.\n" .
            "   Please provide token in .credentials file or GITHUB_TOKEN environment variable.\n";
    }
}

# 3. Load credentials for git operations
my %creds = load_credentials();

# 4. Configure git identity (prevents commit failures)
say "🔧 Configuring git identity...";
system(qq{git config user.name "$creds{GITHUB_USER}"});
system(qq{git config user.email "$creds{GITHUB_EMAIL}"});

# 5. Verify and fix remote URL (prevents push failures)
if ($creds{GITHUB_TOKEN}) {
    my $remote = `git remote get-url origin 2>/dev/null`;
    chomp $remote;
    
    my $expected_token = substr($creds{GITHUB_TOKEN}, 0, 10);
    
    if ($remote && $remote !~ /\Q$expected_token\E/) {
        say "🔧 Fixing remote URL for authenticated push...";
        my $new_url = "https://$creds{GITHUB_USER}:$creds{GITHUB_TOKEN}\@github.com/nailara-technologies/workspace-transfer.git";
        system(qq{git remote set-url origin "$new_url"});
        say "✅ Remote URL updated with credentials";
    } else {
        say "✅ Remote URL already configured correctly";
    }
} else {
    say "⚠️  No GitHub token found - push operations may fail";
    say "    Create .credentials file (see .credentials.template)";
}

# 6. Quick verification
my $branch = `git branch --show-current 2>/dev/null`;
chomp $branch;

say "";
say "=" x 60;
say "✅ BOOTSTRAP COMPLETE";
say "=" x 60;
say "📍 Branch: $branch";
say "📂 Location: " . `pwd`;
say "🔑 Git: $creds{GITHUB_USER} <$creds{GITHUB_EMAIL}>";
say "";
say "⏭️  NEXT STEP: perl status-check.pl";
say "=" x 60;
