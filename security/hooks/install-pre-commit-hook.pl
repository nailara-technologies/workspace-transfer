#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Copy;
use File::Basename;
use Cwd qw(abs_path getcwd);

# Install Pre-commit Secret Scanner Hook
# This script installs the secret scanning hook into .git/hooks/

my $script_dir = dirname(abs_path($0));
my $hook_source = "$script_dir/pre-commit-secret-scanner.pl";

# Find git repository root
sub find_git_root {
    my $dir = getcwd();
    
    while ($dir ne '/') {
        return $dir if -d "$dir/.git";
        $dir = dirname($dir);
    }
    
    die "❌ Not in a git repository. Please run from within a git repo.\n";
}

# Main installation
say "🔒 Pre-commit Secret Scanner - Installation";
say "=" x 60;
say "";

# Verify source file exists
unless (-f $hook_source) {
    die "❌ Source hook not found: $hook_source\n";
}

# Find repository
my $repo_root = find_git_root();
say "📁 Repository: $repo_root";

my $hooks_dir = "$repo_root/.git/hooks";
my $hook_dest = "$hooks_dir/pre-commit";

# Check if hooks directory exists
unless (-d $hooks_dir) {
    die "❌ Hooks directory not found: $hooks_dir\n";
}

# Backup existing hook if present
if (-f $hook_dest) {
    my $backup = "$hook_dest.backup." . time();
    say "⚠️  Existing pre-commit hook found";
    say "   Creating backup: $backup";
    copy($hook_dest, $backup) or die "Cannot backup: $!\n";
}

# Install the hook
say "📦 Installing hook...";
copy($hook_source, $hook_dest) or die "Cannot install hook: $!\n";

# Make executable
chmod 0755, $hook_dest or die "Cannot set executable: $!\n";

# Verify installation
unless (-x $hook_dest) {
    die "❌ Hook installed but not executable\n";
}

say "✅ Installation complete!";
say "";
say "=" x 60;
say "🛡️  Secret Scanner Active";
say "=" x 60;
say "";
say "The pre-commit hook is now active and will scan for:";
say "  • GitHub tokens (classic, fine-grained, OAuth, App)";
say "  • SSH private keys";
say "  • AWS access keys";
say "  • API keys and passwords in URLs";
say "  • Slack tokens";
say "  • Generic secrets/passwords";
say "";
say "Override options (use with caution):";
say "  git commit --no-verify           (bypass all hooks)";
say "  GIT_ALLOW_SECRETS=1 git commit   (bypass secret check only)";
say "";
say "Hook location: $hook_dest";
say "";
say "✅ Your commits are now protected!";
