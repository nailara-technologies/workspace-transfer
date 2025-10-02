#!/usr/bin/env perl
use strict;
use warnings;
use v5.30;

## LIVING TREE WORKSPACE - QUICK CLONE SCRIPT
## Clones workspace from GitHub in 2-3 seconds ⚡

my $token = 'YOUR_TOKEN_HERE';
my $repo_url = "https://$token\@github.com/nailara-technologies/workspace-transfer.git";
my $workspace_dir = '/home/claude/living-tree';

say "=" x 70;
say "🌳 Living Tree Workspace - Quick Clone";
say "=" x 70;
say "";

# Check if workspace already exists
if (-d $workspace_dir) {
    say "⚠️  Workspace already exists at $workspace_dir";
    say "";
    print "Options:\n";
    print "  1. Update existing workspace (git pull)\n";
    print "  2. Delete and re-clone fresh\n";
    print "  3. Keep as-is and exit\n";
    print "\nChoice (1-3): ";
    
    my $choice = <STDIN>;
    chomp $choice;
    
    if ($choice eq '1') {
        say "\n🔄 Updating workspace...";
        chdir $workspace_dir or die "Cannot cd: $!";
        system("git pull origin base");
        say "\n✅ Workspace updated!";
        exit 0;
    } elsif ($choice eq '2') {
        say "\n🗑️  Removing old workspace...";
        system("rm -rf $workspace_dir");
        say "✅ Removed!";
    } else {
        say "\n✅ Keeping existing workspace";
        exit 0;
    }
}

# Configure git
say "⚙️  Configuring git...";
system("git config --global user.name 'workspace-transfer'");
system("git config --global user.email 'workspace-transfer\@nailara.tech'");

# Clone repository
say "\n🚀 Cloning workspace from GitHub...";
say "Repository: github.com/nailara-technologies/workspace-transfer";
say "Branch: base";
say "";

my $start_time = time;
my $result = system("git clone $repo_url $workspace_dir 2>&1");
my $elapsed = time - $start_time;

if ($result == 0) {
    say "";
    say "=" x 70;
    say "✅ Living Tree Workspace Cloned Successfully!";
    say "=" x 70;
    say "";
    say "Time taken: ${elapsed} seconds ⚡";
    say "Location: $workspace_dir";
    say "";
    
    # Show workspace contents
    say "Workspace contents:";
    chdir $workspace_dir;
    system("find . -type f -not -path './.git/*' | sort | sed 's|^./|  - |'");
    
    say "";
    say "Quick commands:";
    say "  cd $workspace_dir           - Go to workspace";
    say "  git status                       - Check status";
    say "  git pull origin base             - Update from GitHub";
    say "  git add -A && git commit && git push  - Save to GitHub";
    say "";
    say "🌳 Ready to work! 🌳";
    
} else {
    say "";
    say "=" x 70;
    say "❌ Clone Failed!";
    say "=" x 70;
    say "";
    say "Possible issues:";
    say "  • Invalid or expired token";
    say "  • Network connectivity problem";
    say "  • Repository doesn't exist or is inaccessible";
    say "";
    say "To fix:";
    say "  1. Verify token is valid: github.com/settings/tokens";
    say "  2. Check repository access: github.com/nailara-technologies/workspace-transfer";
    say "  3. Try again";
    say "";
    exit 1;
}
