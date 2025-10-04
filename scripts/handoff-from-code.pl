#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use File::Basename;
use File::Spec;
use Cwd qw(getcwd);
use Time::Piece;
use Getopt::Long;

# Claude Code Return Handoff Script
# Generate summary for returning from Code to Console

my $VERSION = '1.0';

my %opt;
GetOptions(
    'message|m=s'    => \$opt{message},
    'checkpoint|c'   => \$opt{checkpoint},
    'verbose|v'      => \$opt{verbose},
    'help|h'         => \$opt{help},
) or die "Error in command line arguments\n";

if ($opt{help}) {
    print_usage();
    exit 0;
}

# Detect current location
my $cwd = getcwd();
my $home = $ENV{HOME} || '/home/claude';
my $timestamp = Time::Piece->new->strftime('%Y%m%d_%H%M%S');

say "=== Claude Code Session Summary Generator ===\n";

# Collect git changes
my $git_summary = collect_git_changes();

# Collect TODO markers
my $todo_markers = collect_todo_markers();

# Generate session summary
generate_session_summary($git_summary, $todo_markers, \%opt);

# Optionally create checkpoint
if ($opt{checkpoint}) {
    create_return_checkpoint($git_summary, $timestamp);
}

# === Functions ===

sub print_usage {
    say <<'EOF';
Usage: handoff-from-code.pl [OPTIONS]

Generate summary for returning from Claude Code to Console

Options:
    -m, --message MSG    Add custom message to summary
    -c, --checkpoint     Create encrypted checkpoint
    -v, --verbose        Show detailed changes
    -h, --help          Show this help

Examples:
    perl scripts/handoff-from-code.pl
    perl scripts/handoff-from-code.pl -m "Webhook implementation started"
    perl scripts/handoff-from-code.pl --checkpoint

EOF
}

sub collect_git_changes {
    my %summary;
    
    # Check if in git repository
    return \%summary unless -d '.git';
    
    # Get current branch
    $summary{branch} = `git branch --show-current 2>/dev/null`;
    chomp $summary{branch};
    
    # Get uncommitted changes
    my @status = `git status --porcelain 2>/dev/null`;
    $summary{uncommitted} = scalar @status;
    
    # Get recent commits (since last handoff or last 10)
    my @commits = `git log --oneline -10 2>/dev/null`;
    chomp @commits;
    $summary{recent_commits} = \@commits;
    
    # Get changed files
    if ($summary{uncommitted} > 0) {
        my @changed_files = map { 
            my $line = $_;
            chomp $line;
            $line =~ s/^..\s+//;
            $line;
        } @status;
        $summary{changed_files} = \@changed_files;
    }
    
    # Get diff stats
    my $diff_stat = `git diff --stat 2>/dev/null`;
    $summary{diff_stat} = $diff_stat if $diff_stat;
    
    return \%summary;
}

sub collect_todo_markers {
    my @todos;
    
    # Search for TODO/FIXME/XXX markers in recently modified files
    my @search_patterns = (
        'TODO:',
        'FIXME:',
        'XXX:',
        'HACK:',
        'NOTE:',
        '[ ]',  # Unchecked task boxes
    );
    
    # Get recently modified files (last 24 hours)
    my @recent_files = `find . -type f -name '*.pl' -o -name '*.pm' -o -name '*.md' -mtime -1 2>/dev/null | head -20`;
    
    for my $file (@recent_files) {
        chomp $file;
        next unless -f $file;
        
        open my $fh, '<', $file or next;
        my $line_num = 0;
        
        while (my $line = <$fh>) {
            $line_num++;
            for my $pattern (@search_patterns) {
                if ($line =~ /\Q$pattern\E\s*(.+)/) {
                    my $todo_text = $1;
                    push @todos, {
                        file => $file,
                        line => $line_num,
                        type => $pattern,
                        text => substr($todo_text, 0, 60),
                    };
                }
            }
        }
        close $fh;
    }
    
    return \@todos;
}

sub generate_session_summary {
    my ($git_summary, $todo_markers, $opt) = @_;
    
    say "📊 CODE SESSION SUMMARY FOR CONSOLE\n";
    say "=" x 60;
    
    # Git summary
    if ($git_summary->{branch}) {
        say "\n## Git Activity\n";
        say "**Branch**: $git_summary->{branch}";
        say "**Uncommitted Files**: $git_summary->{uncommitted}";
        
        if ($git_summary->{recent_commits} && @{$git_summary->{recent_commits}}) {
            say "\n### Recent Commits";
            say "```";
            for my $commit (@{$git_summary->{recent_commits}}[0..4]) {
                say $commit;
            }
            say "```";
        }
        
        if ($git_summary->{changed_files} && @{$git_summary->{changed_files}}) {
            say "\n### Uncommitted Changes";
            say "```";
            for my $file (@{$git_summary->{changed_files}}[0..9]) {
                say "  $file";
            }
            say "..." if @{$git_summary->{changed_files}} > 10;
            say "```";
            
            if ($opt->{verbose} && $git_summary->{diff_stat}) {
                say "\n### Diff Statistics";
                say "```";
                print $git_summary->{diff_stat};
                say "```";
            }
        }
    }
    
    # TODO markers
    if ($todo_markers && @$todo_markers) {
        say "\n## Pending Items (TODO/FIXME)\n";
        
        my %by_type;
        for my $todo (@$todo_markers) {
            push @{$by_type{$todo->{type}}}, $todo;
        }
        
        for my $type (sort keys %by_type) {
            say "### $type";
            for my $todo (@{$by_type{$type}}[0..4]) {
                say "- `$todo->{file}:$todo->{line}` - $todo->{text}";
            }
            say "- ... and " . (@{$by_type{$type}} - 5) . " more" 
                if @{$by_type{$type}} > 5;
        }
    }
    
    # Custom message
    if ($opt->{message}) {
        say "\n## Session Notes\n";
        say $opt->{message};
    }
    
    # Return instructions
    say "\n## Return to Console Instructions\n";
    say "```markdown";
    say "Returning from Claude Code session.";
    say "";
    say "**Completed**:";
    say "- See commits above";
    say "";
    say "**Pending**:";
    
    if ($git_summary->{uncommitted} && $git_summary->{uncommitted} > 0) {
        say "- $git_summary->{uncommitted} files with uncommitted changes";
        say "- Review with: git diff";
    }
    
    if ($todo_markers && @$todo_markers) {
        say "- " . scalar(@$todo_markers) . " TODO/FIXME markers";
    }
    
    say "";
    say "**Continue with**: [Next task description]";
    say "```";
    
    # Copy instructions
    say "\n" . "=" x 60;
    say "\n📋 TO RETURN TO CONSOLE:\n";
    say "1. Copy the summary above";
    say "2. Start new Console chat (or continue existing)";
    say "3. Paste summary as context";
    say "4. Continue work\n";
    
    if ($git_summary->{uncommitted} && $git_summary->{uncommitted} > 0) {
        say "⚠️  WARNING: You have uncommitted changes!";
        say "Consider: git commit -am 'WIP: Description' before switching";
    }
    
    say "\n✅ Summary generated successfully!";
}

sub create_return_checkpoint {
    my ($git_summary, $timestamp) = @_;
    
    say "\n📦 Creating return checkpoint...";
    
    # Check if we're in workspace-transfer
    unless (-f 'scripts/export-context-checkpoint.pl') {
        say "⚠️  Not in workspace-transfer, checkpoint creation skipped";
        return;
    }
    
    # Create checkpoint
    my $checkpoint_name = "code-return-$timestamp";
    system("perl scripts/export-context-checkpoint.pl --session-name='$checkpoint_name' --encrypt");
    
    say "✓ Checkpoint created: $checkpoint_name";
    say "  Use in Console: perl scripts/load-context-checkpoint.pl --session-name='$checkpoint_name'";
}

__END__

=head1 NAME

handoff-from-code.pl - Generate summary when returning from Claude Code

=head1 SYNOPSIS

    perl scripts/handoff-from-code.pl [OPTIONS]

=head1 DESCRIPTION

This script generates a summary of work done in Claude Code session
for seamless return to Claude Console.

=head1 OPTIONS

    -m, --message MSG    Add custom message to summary
    -c, --checkpoint     Create encrypted checkpoint
    -v, --verbose        Show detailed changes
    -h, --help          Show this help

=head1 FEATURES

- Collects git commits and changes
- Finds TODO/FIXME markers in code
- Generates markdown summary for Console
- Optionally creates encrypted checkpoint
- Warns about uncommitted changes

=head1 AUTHOR

Claude (Anthropic) - October 2025

=cut
