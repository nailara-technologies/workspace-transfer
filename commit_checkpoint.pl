#!/usr/bin/env perl
use strict;
use warnings;
use v5.30;
use POSIX qw(strftime);

## WORKSPACE COMMIT CHECKPOINT HELPER
## Quick commits to avoid losing work at chat context limits

my $message = $ARGV[0] || sprintf("Checkpoint: %s", strftime("%Y-%m-%d %H:%M:%S", localtime));

# Add all changes
system("git add -A") == 0 or die "git add failed: $!\n";

# Show what will be committed
say "=" x 70;
say "COMMITTING CHANGES";
say "=" x 70;
system("git status --short");
say "";

# Commit
say "Message: $message";
my $commit_result = system("git commit -m '$message'");

if ($commit_result == 0) {
    say "✓ Committed successfully";
    
    # Push to remote
    say "\nPushing to GitHub...";
    my $push_result = system("git push origin base");
    
    if ($push_result == 0) {
        say "✓ Pushed to remote successfully";
        say "\n🌳 Checkpoint saved to GitHub! 🌳";
    } else {
        say "⚠ Push failed, but commit is local. Will retry on next checkpoint.";
    }
} else {
    say "ℹ Nothing to commit (working tree clean)";
}

say "=" x 70;
