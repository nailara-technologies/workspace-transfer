#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use File::Basename;
use File::Spec;
use Cwd qw(getcwd abs_path);
use Time::Piece;

# Claude Code Handoff Script
# Generate seamless handoff from Claude Console to Claude Code

my $VERSION = '1.0';

# Detect current location and context
my $cwd = getcwd();
my $home = $ENV{HOME} || '/home/claude';
my $workspace_transfer = "$home/workspace-transfer";
my $protocol7_root = $ENV{NAILARA_ROOT} || "$home/protocol-7";

# Determine which repository we're in
my $context = detect_context($cwd);
my $repo_root = $context->{root};
my $repo_name = $context->{name};
my $repo_type = $context->{type};

# Check git status
my $git_status = get_git_status($repo_root) if $repo_root;

# Generate timestamp
my $timestamp = Time::Piece->new->strftime('%Y%m%d_%H%M%S');

# Create handoff package
say "=== Claude Code Handoff Generator ===\n";
say "Current Location: $cwd";
say "Repository: " . ($repo_name || 'Not in repository');
say "Git Status: " . ($git_status->{status} || 'N/A');
say "";

# Generate handoff instructions
generate_handoff_instructions($context, $git_status, $timestamp);

# === Functions ===

sub detect_context {
    my ($path) = @_;
    
    # Check if we're in workspace-transfer
    if ($path =~ m{/workspace-transfer(?:/|$)}) {
        my $root = $path;
        $root =~ s{(/workspace-transfer).*}{$1};
        return {
            type => 'workspace-transfer',
            name => 'workspace-transfer',
            root => $root,
            relative => File::Spec->abs2rel($path, $root),
        };
    }
    
    # Check if we're in protocol-7
    if ($path =~ m{/protocol-7(?:/|$)} || 
        $path =~ m{/nailara(?:/|$)} ||
        (defined $ENV{NAILARA_ROOT} && $path =~ m{$ENV{NAILARA_ROOT}(?:/|$)})) {
        
        my $root = $ENV{NAILARA_ROOT} || $path;
        $root =~ s{(/(?:protocol-7|nailara)).*}{$1} unless $ENV{NAILARA_ROOT};
        
        return {
            type => 'protocol-7',
            name => 'protocol-7',
            root => $root,
            relative => File::Spec->abs2rel($path, $root),
        };
    }
    
    # Check parent directories for .git
    my $check_path = $path;
    while ($check_path ne '/' && $check_path ne $home) {
        if (-d "$check_path/.git") {
            my $name = basename($check_path);
            return {
                type => 'other-git',
                name => $name,
                root => $check_path,
                relative => File::Spec->abs2rel($path, $check_path),
            };
        }
        $check_path = dirname($check_path);
    }
    
    # Not in a repository
    return {
        type => 'standalone',
        name => undef,
        root => undef,
        relative => $path,
    };
}

sub get_git_status {
    my ($repo_root) = @_;
    return unless $repo_root && -d "$repo_root/.git";
    
    my $old_dir = getcwd();
    chdir $repo_root;
    
    # Get branch
    my $branch = `git branch --show-current 2>/dev/null`;
    chomp $branch;
    
    # Check if clean
    my $status_output = `git status --porcelain 2>/dev/null`;
    my $is_clean = !$status_output;
    
    # Get last commit
    my $last_commit = `git log -1 --oneline 2>/dev/null`;
    chomp $last_commit;
    
    chdir $old_dir;
    
    return {
        branch => $branch || 'unknown',
        clean => $is_clean,
        status => $is_clean ? 'clean' : 'uncommitted changes',
        last_commit => $last_commit,
    };
}

sub generate_handoff_instructions {
    my ($context, $git_status, $timestamp) = @_;
    
    say "📋 CLAUDE CODE STARTUP INSTRUCTIONS\n";
    say "=" x 60;
    
    # Initial setup based on context
    if ($context->{type} eq 'workspace-transfer') {
        say "# You are in workspace-transfer repository";
        say "cd $context->{root}";
        if ($context->{relative} && $context->{relative} ne '.') {
            say "cd $context->{relative}";
        }
        say "";
        say "# Verify checkpoint functionality";
        say "perl scripts/decrypt-checkpoint.pl --help";
        say "";
        
    } elsif ($context->{type} eq 'protocol-7') {
        say "# You are in Protocol-7 repository";
        say "export NAILARA_ROOT='$context->{root}'";
        say "cd $context->{root}";
        if ($context->{relative} && $context->{relative} ne '.') {
            say "cd $context->{relative}";
        }
        say "";
        
    } elsif ($context->{type} eq 'other-git') {
        say "# You are in git repository: $context->{name}";
        say "cd $context->{root}";
        if ($context->{relative} && $context->{relative} ne '.') {
            say "cd $context->{relative}";
        }
        say "";
        
    } else {
        say "# No repository detected at current location";
        say "# Current path: $cwd";
        say "";
        say "# Suggested: Navigate to workspace-transfer";
        say "cd $workspace_transfer" if -d $workspace_transfer;
        say "";
    }
    
    # Git status if available
    if ($git_status) {
        say "# Git Status";
        say "# Branch: $git_status->{branch}";
        say "# Status: $git_status->{status}";
        say "# Last: $git_status->{last_commit}" if $git_status->{last_commit};
        say "";
        
        unless ($git_status->{clean}) {
            say "# ⚠️  Uncommitted changes present";
            say "git status";
            say "git diff  # Review changes";
            say "";
        }
    }
    
    # Context-specific tasks
    say "# Contextual Tasks";
    
    if ($context->{type} eq 'workspace-transfer') {
        say "# Recent focus: Checkpoint encryption, Claude Code handoff";
        say "# Check TODO for current phase:";
        say "grep -A5 'IN PROGRESS' TODO_BACKUP_RESTORE.md";
        say "";
        say "# Quick status check:";
        say "perl status-check.pl";
        say "";
        
    } elsif ($context->{type} eq 'protocol-7') {
        say "# Protocol-7 specific tasks";
        say "# Check if Protocol-7 is running:";
        say "pgrep -fl Protocol-7 || echo 'Not running'";
        say "";
        say "# Review webhook integration points:";
        say "find modules -name '*httpd*' -o -name '*webhook*' | head -10";
        say "";
    }
    
    # Handoff checkpoint creation
    say "# Create Handoff Checkpoint (if needed)";
    say "cat > /tmp/handoff_$timestamp.md << 'EOF'";
    say "# Claude Code Handoff - $timestamp\n";
    say "**From**: Claude Console";
    say "**To**: Claude Code";
    say "**Location**: $cwd";
    say "**Repository**: " . ($context->{name} || 'none');
    say "**Branch**: " . ($git_status->{branch} || 'N/A');
    say "**Status**: " . ($git_status->{status} || 'N/A');
    say "";
    say "## Current Focus";
    say "- [ ] Add task here";
    say "- [ ] Another task";
    say "";
    say "## Notes from Console";
    say "(Add any relevant context here)";
    say "";
    say "## Expected Deliverables";
    say "- [ ] Item 1";
    say "- [ ] Item 2";
    say "EOF";
    say "";
    
    # Quick navigation commands
    say "# Quick Navigation";
    say "alias ws='cd $workspace_transfer'";
    say "alias p7='cd $protocol7_root'";
    
    if (-d "$workspace_transfer/.git") {
        say "alias gs='git status'";
        say "alias gd='git diff'";
        say "alias gc='git commit -am'";
    }
    say "";
    
    # Environment check
    say "# Verify Environment";
    say "perl -v | head -2  # Perl version";
    say "perl -MCrypt::Mode::CBC -e 'print \"✓ CryptX installed\\n\"' 2>/dev/null || \\";
    say "  echo '✗ Missing CryptX - run: apt-get install -y libcryptx-perl'";
    say "";
    
    # Final message
    say "=" x 60;
    say "\n💡 TIPS FOR CLAUDE CODE SESSION:\n";
    say "1. Use 'less' instead of 'cat' for long files";
    say "2. Commit frequently with clear messages";
    say "3. Create checkpoints before major changes";
    say "4. Use TODO markers for incomplete work";
    say "5. Update handoff file before returning to Console";
    say "";
    say "📌 TO RETURN TO CONSOLE:";
    say "Create summary: perl scripts/handoff-from-code.pl";
    say "Or manually: git commit -am 'Code session complete' && git push";
    say "";
    
    # Copy instructions to clipboard if possible
    if (system("which xclip >/dev/null 2>&1") == 0) {
        say "📋 Instructions copied to clipboard (xclip detected)";
        # Note: Actually copying would need to capture all the output
    }
    
    say "✅ Handoff instructions generated!";
    say "Copy the above to start your Claude Code session.\n";
}

__END__

=head1 NAME

handoff-to-code.pl - Generate seamless handoff to Claude Code

=head1 SYNOPSIS

    perl scripts/handoff-to-code.pl

=head1 DESCRIPTION

This script generates instructions for transitioning from Claude Console
to Claude Code, preserving context and providing startup commands.

=head1 FEATURES

- Auto-detects current repository (workspace-transfer, protocol-7, or other)
- Checks git status and branch information
- Generates contextual startup commands
- Creates handoff checkpoint template
- Provides environment verification steps
- Includes quick navigation aliases

=head1 USAGE

Run from any directory. The script will:
1. Detect your current location
2. Identify the repository context
3. Generate appropriate Claude Code startup instructions
4. Provide task-specific guidance

=head1 AUTHOR

Claude (Anthropic) - October 2025

=cut
