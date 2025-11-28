#!/usr/bin/perl
# Enhanced bootstrap.pl - Auto-configures workspace in < 5 seconds
# Works across all environments: Claude Console, Code Web, local machines
# Run this FIRST in every new session

use v5.24;
use strict;
use warnings;
use Cwd qw(abs_path);
use File::Spec;

say "🚀 WORKSPACE BOOTSTRAP - Starting...";
say "";

# ===== ENVIRONMENT DETECTION =====
# Detect which environment we're in and set paths accordingly

sub detect_environment {
    my $home = $ENV{HOME} || $ENV{USERPROFILE} || (getpwuid($<))[7] || '/tmp';
    my $pwd = abs_path('.');
    my $user = $ENV{USER} || $ENV{USERNAME} || 'unknown';
    
    # Check for Anthropic JWT proxy signature
    # Anthropic proxies have format: http://container_...:jwt_<jwt_token>
    my $has_anthropic_proxy = 0;
    if ($ENV{HTTPS_PROXY} && $ENV{HTTPS_PROXY} =~ /container_.*:jwt_/) {
        $has_anthropic_proxy = 1;
    } elsif ($ENV{HTTP_PROXY} && $ENV{HTTP_PROXY} =~ /container_.*:jwt_/) {
        $has_anthropic_proxy = 1;
    }
    
    my $env_type = 'unknown';
    
    if ($has_anthropic_proxy) {
        # We're in an Anthropic environment
        if ($home =~ /\/home\/claude/) {
            $env_type = 'Claude Console';
        } elsif ($home =~ /\/home\/user/) {
            $env_type = 'Claude Code Web';
        } else {
            $env_type = 'Anthropic Container';
        }
    } else {
        # No Anthropic proxy = local or remote machine
        $env_type = 'Local Machine';
    }
    
    return {
        home => $home,
        pwd => $pwd,
        user => $user,
        type => $env_type,
        has_anthropic_proxy => $has_anthropic_proxy,
    };
}

my $env = detect_environment();

say "📍 Environment: $env->{type}";
say "👤 User: $env->{user}";
say "🏠 Home: $env->{home}";
say "📂 Current: $env->{pwd}";
say "";

# ===== HELPER FUNCTIONS =====

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

# ===== REPOSITORY DETECTION =====

# 1. Create working directories (in home directory, environment-agnostic)
say "📁 Creating work directories...";
my $work_dir = File::Spec->catdir($env->{home}, 'work');
mkdir($work_dir) unless -d $work_dir;
say "   ✓ $work_dir" if -d $work_dir;
say "";

# 2. Check if we're already in the repo
my $in_repo = -d '.git' && (-f 'bootstrap.pl' || -f 'START_HERE.md');

unless ($in_repo) {
    # Not in repo - try to locate or guide user
    say "⚠️  Not currently in workspace-transfer directory";
    say "";
    
    # Check if workspace-transfer exists in home directory
    my $expected_dir = File::Spec->catdir($env->{home}, 'workspace-transfer');
    if (-d $expected_dir && -d File::Spec->catdir($expected_dir, '.git')) {
        say "✅ Repository found at: $expected_dir";
        say "   Changing to repository directory...";
        chdir $expected_dir or die "Cannot cd to $expected_dir: $!";
        $in_repo = 1;
    } else {
        say "❌ Cannot find workspace-transfer repository";
        say "";
        say "PLEASE DO ONE OF:";
        say "  1. Clone the repository:";
        say "     git clone https://github.com/nailara-technologies/workspace-transfer.git";
        say "     cd workspace-transfer";
        say "     perl bootstrap.pl";
        say "";
        say "  2. OR change to existing repository directory:";
        say "     cd ~/workspace-transfer";
        say "     perl bootstrap.pl";
        say "";
        say "Token sources (in order of preference):";
        say "  • Anthropic JWT proxy (automatic in Claude environments)";
        say "  • GITHUB_TOKEN environment variable";
        say "  • .credentials file (see .credentials.template)";
        say "";
        exit 1;
    }
}

# ===== GIT CONFIGURATION =====

# 3. Load credentials for git operations
my %creds = load_credentials();

# 4. Configure git identity (prevents commit failures)
say "🔧 Configuring git identity...";
system(qq{git config user.name "$creds{GITHUB_USER}"});
system(qq{git config user.email "$creds{GITHUB_EMAIL}"});

# 5. Configure authentication based on environment
say "🔐 Configuring authentication for $env->{type}...";

if ($env->{has_anthropic_proxy}) {
    # Anthropic environments (Console, Code Web, etc.) have JWT proxy
    # Use it for transparent authentication
    my $proxy = $ENV{HTTPS_PROXY} || $ENV{HTTP_PROXY};
    if ($proxy) {
        say "   ✓ Using Anthropic JWT proxy for authentication";
        system(qq{git config http.proxy "$proxy"});
        system(qq{git config https.proxy "$proxy"});
        system(q{git config http.sslverify false});
    }
} elsif ($creds{GITHUB_TOKEN}) {
    # Local environments: use embedded token if available
    say "   ✓ Using GitHub token from credentials";
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
    say "   ℹ️  No explicit credentials needed for this environment";
    if ($env->{type} eq 'Local Machine') {
        say "   ℹ️  SSH keys or stored credentials may be used by git";
    }
}

# ===== VERIFICATION & SUMMARY =====

# 6. Quick verification
my $branch = `git branch --show-current 2>/dev/null`;
chomp $branch;

# 7. Create initialization marker with environment info
open my $marker, '>', '.initialized' or warn "Cannot create marker: $!";
print $marker "Initialized: " . scalar(localtime) . "\n";
print $marker "Environment: $env->{type}\n";
print $marker "Branch: $branch\n";
print $marker "Email: $creds{GITHUB_EMAIL}\n";
close $marker;

say "";
say "=" x 60;
say "✅ BOOTSTRAP COMPLETE ($env->{type})";
say "=" x 60;
say "📍 Branch: $branch";
say "📂 Location: " . abs_path('.');
say "🔑 Git: $creds{GITHUB_USER} <$creds{GITHUB_EMAIL}>";
say "🎫 Initialization marker created";
say "";
say "⏭️  NEXT STEP: perl status-check.pl";
say "";
say "For detailed guidance, see: START_HERE.md";
say "=" x 60;
