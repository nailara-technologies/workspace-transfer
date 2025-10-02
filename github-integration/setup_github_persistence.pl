#!/usr/bin/env perl
use strict;
use warnings;
use v5.30;

=head1 LIVING TREE GITHUB PERSISTENCE SETUP

This script sets up GitHub as a fast persistence layer for the Living Tree workspace.
Transfer speed: 2-3 seconds (vs 10+ minutes via stdout)

Prerequisites (you provide):
1. GitHub repository URL (private recommended)
2. Authentication method:
   - Option A: GitHub Personal Access Token (PAT)
   - Option B: SSH key already configured
   
=cut

print "=" x 70 . "\n";
print "🌳 Living Tree GitHub Persistence Setup 🌳\n";
print "=" x 70 . "\n\n";

# Check if git is available
unless (system("which git > /dev/null 2>&1") == 0) {
    die "❌ Error: git is not installed\n" .
        "   Install with: sudo apt-get install git\n";
}

print "✅ Git is installed\n\n";

# Configuration
print "Configuration:\n";
print "Enter your GitHub repository URL:\n";
print "  Format: https://github.com/username/living-tree-workspace.git\n";
print "  or:     git\@github.com:username/living-tree-workspace.git\n";
print "\n";
print "Repository URL: ";
my $repo_url = <STDIN>;
chomp $repo_url;

unless ($repo_url =~ /github\.com/) {
    die "❌ Invalid GitHub URL\n";
}

print "\n";
print "Authentication method:\n";
print "  1. Personal Access Token (PAT) - Recommended for HTTPS\n";
print "  2. SSH Key - Already configured\n";
print "\n";
print "Choose (1/2): ";
my $auth_method = <STDIN>;
chomp $auth_method;

my $git_credential = '';

if ($auth_method eq '1') {
    print "\n";
    print "Enter your GitHub Personal Access Token:\n";
    print "(Create at: https://github.com/settings/tokens)\n";
    print "Required scopes: repo (full control)\n";
    print "\n";
    print "Token: ";
    my $token = <STDIN>;
    chomp $token;
    
    unless ($token =~ /^ghp_[a-zA-Z0-9]+$/) {
        die "❌ Invalid GitHub token format\n";
    }
    
    # Store credential helper for this repo
    # Convert URL to use token
    if ($repo_url =~ m{https://github\.com/([^/]+)/(.+?)(?:\.git)?$}) {
        my ($user, $repo) = ($1, $2);
        $repo_url = "https://$token\@github.com/$user/$repo.git";
    }
    
    print "✅ Token configured\n";
    
} elsif ($auth_method eq '2') {
    unless ($repo_url =~ /^git@/) {
        print "⚠️  Warning: SSH URL format is: git\@github.com:username/repo.git\n";
        print "   Your URL uses HTTPS. Convert? (y/n): ";
        my $convert = <STDIN>;
        chomp $convert;
        
        if ($convert eq 'y' && $repo_url =~ m{https://github\.com/([^/]+)/(.+)}) {
            $repo_url = "git\@github.com:$1/$2";
            $repo_url =~ s/\.git$//;
            $repo_url .= '.git';
            print "   Converted to: $repo_url\n";
        }
    }
    print "✅ Using SSH authentication\n";
} else {
    die "❌ Invalid choice\n";
}

# Setup workspace
my $workspace_dir = '/home/claude/living-tree';

print "\n";
print "=" x 70 . "\n";
print "Setting up workspace...\n";
print "=" x 70 . "\n\n";

if (-d $workspace_dir) {
    print "⚠️  Workspace directory already exists: $workspace_dir\n";
    print "   Remove and re-clone? (y/n): ";
    my $remove = <STDIN>;
    chomp $remove;
    
    if ($remove eq 'y') {
        system("rm -rf $workspace_dir");
        print "   Removed existing workspace\n";
    } else {
        print "   Keeping existing workspace\n";
        print "   You may need to manually configure git remote\n";
        exit 0;
    }
}

# Clone repository
print "\n";
print "Cloning repository...\n";
print "URL: $repo_url\n";
print "\n";

my $clone_result = system("git clone '$repo_url' '$workspace_dir' 2>&1");

if ($clone_result == 0) {
    print "\n";
    print "=" x 70 . "\n";
    print "✅ Living Tree workspace cloned successfully!\n";
    print "=" x 70 . "\n\n";
    
    # Configure git user (required for commits)
    chdir $workspace_dir;
    
    print "Git configuration:\n";
    print "Enter your name (for commits): ";
    my $git_name = <STDIN>;
    chomp $git_name;
    
    print "Enter your email: ";
    my $git_email = <STDIN>;
    chomp $git_email;
    
    system("git config user.name '$git_name'");
    system("git config user.email '$git_email'");
    
    print "\n✅ Git configured\n\n";
    
    # Show workspace structure
    print "Workspace structure:\n";
    system("tree -L 2 $workspace_dir 2>/dev/null || ls -la $workspace_dir");
    
    print "\n";
    print "=" x 70 . "\n";
    print "🌳 Setup Complete! 🌳\n";
    print "=" x 70 . "\n\n";
    
    print "Quick reference:\n";
    print "  Workspace: $workspace_dir\n";
    print "  Update:    cd $workspace_dir && git pull\n";
    print "  Save:      cd $workspace_dir && git add -A && git commit -m 'msg' && git push\n";
    print "\n";
    print "Next session startup time: 2-3 seconds (git pull) ⚡\n";
    print "\n";
    
} else {
    print "\n";
    print "=" x 70 . "\n";
    print "❌ Clone failed!\n";
    print "=" x 70 . "\n\n";
    
    print "Common issues:\n";
    print "  • Invalid token or credentials\n";
    print "  • Repository doesn't exist\n";
    print "  • No push access\n";
    print "  • SSH key not configured\n";
    print "\n";
    print "Check your settings and try again.\n";
    exit 1;
}

# Create helper scripts
print "Creating helper scripts...\n\n";

# Quick pull script
open my $pull_fh, '>', '/home/claude/living_tree_pull.pl' or die $!;
print $pull_fh <<'PULL_SCRIPT';
#!/usr/bin/env perl
use strict;
use warnings;

print "🌳 Updating Living Tree workspace...\n";
chdir '/home/claude/living-tree' or die "Cannot cd: $!";
system("git pull");
print "✅ Workspace updated!\n";
PULL_SCRIPT
close $pull_fh;
chmod 0755, '/home/claude/living_tree_pull.pl';

# Quick save script
open my $save_fh, '>', '/home/claude/living_tree_save.pl' or die $!;
print $save_fh <<'SAVE_SCRIPT';
#!/usr/bin/env perl
use strict;
use warnings;

my $message = $ARGV[0] || 'Update workspace';

print "🌳 Saving Living Tree workspace...\n";
chdir '/home/claude/living-tree' or die "Cannot cd: $!";

system("git add -A");
system("git commit -m '$message'");
system("git push");

print "✅ Workspace saved to GitHub!\n";
SAVE_SCRIPT
close $save_fh;
chmod 0755, '/home/claude/living_tree_save.pl';

print "✅ Helper scripts created:\n";
print "   /home/claude/living_tree_pull.pl\n";
print "   /home/claude/living_tree_save.pl\n";
print "\n";

print "=" x 70 . "\n";
print "🌳 Living Tree GitHub persistence is ready! 🌳\n";
print "=" x 70 . "\n";
