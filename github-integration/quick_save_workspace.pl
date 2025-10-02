#!/usr/bin/env perl
use strict;
use warnings;
use v5.30;

## LIVING TREE WORKSPACE - QUICK SAVE SCRIPT
## Saves workspace to GitHub in 2-3 seconds ⚡

my $workspace_dir = '/home/claude/living-tree';
my $default_message = "Session update: " . localtime();

say "=" x 70;
say "🌳 Living Tree Workspace - Quick Save";
say "=" x 70;
say "";

# Check if workspace exists
unless (-d $workspace_dir) {
    say "❌ Workspace not found at $workspace_dir";
    say "";
    say "Run quick_clone_workspace.pl first to clone the workspace.";
    exit 1;
}

chdir $workspace_dir or die "Cannot cd to workspace: $!";

# Check if it's a git repository
unless (-d '.git') {
    say "❌ Not a git repository!";
    say "";
    say "The directory exists but isn't initialized with git.";
    say "Run quick_clone_workspace.pl to set up properly.";
    exit 1;
}

# Get commit message
my $message = $ARGV[0] || $default_message;

say "📝 Commit message: $message";
say "";

# Check for changes
say "🔍 Checking for changes...";
my $status_output = `git status --short`;

if ($status_output eq '') {
    say "";
    say "✅ No changes to save!";
    say "Workspace is already up to date with GitHub.";
    exit 0;
}

say "Changes found:";
say $status_output;
say "";

# Stage all changes
say "📦 Staging changes...";
system("git add -A");

# Commit
say "💾 Creating commit...";
my $commit_result = system("git commit -m '$message'");

if ($commit_result != 0) {
    say "";
    say "❌ Commit failed!";
    say "This shouldn't happen after staging. Check git status.";
    exit 1;
}

# Push to GitHub
say "🚀 Pushing to GitHub...";
say "";

my $start_time = time;
my $push_result = system("git push origin base 2>&1");
my $elapsed = time - $start_time;

if ($push_result == 0) {
    say "";
    say "=" x 70;
    say "✅ Living Tree Workspace Saved Successfully!";
    say "=" x 70;
    say "";
    say "Time taken: ${elapsed} seconds ⚡";
    say "Repository: github.com/nailara-technologies/workspace-transfer";
    say "Branch: base";
    say "";
    say "Latest commits:";
    system("git log --oneline -3");
    say "";
    say "🌳 Progress preserved! 🌳";
    
} else {
    say "";
    say "=" x 70;
    say "❌ Push Failed!";
    say "=" x 70;
    say "";
    say "Possible issues:";
    say "  • Network connectivity problem";
    say "  • Token expired";
    say "  • Branch diverged (need to pull first)";
    say "";
    say "To fix:";
    say "  1. Try: git pull origin base";
    say "  2. Resolve any conflicts";
    say "  3. Try saving again";
    say "";
    exit 1;
}
