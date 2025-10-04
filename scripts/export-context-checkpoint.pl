#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use File::Path qw(make_path);
use POSIX qw(strftime);

# Export Context Checkpoint
# Save Claude conversation state to workspace for efficient chat resets

my $VERSION = '1.0';

my %opt;
GetOptions(
    'session-name=s' => \$opt{session_name},
    'auto'           => \$opt{auto},
    'help|h'         => \$opt{help},
    'version|v'      => \$opt{version},
) or die "Error in command line arguments\n";

if ($opt{help}) {
    print_usage();
    exit 0;
}

if ($opt{version}) {
    say "export-context-checkpoint.pl version $VERSION";
    exit 0;
}

# Find workspace root
my $script_dir = dirname(__FILE__);
my $workspace_root = "$script_dir/..";
chdir $workspace_root or die "Cannot change to workspace root: $!\n";

# Create checkpoints directory if needed
my $checkpoint_dir = "context-checkpoints";
make_path($checkpoint_dir) unless -d $checkpoint_dir;

# Generate checkpoint filename
my $timestamp = strftime('%Y%m%d_%H%M%S', localtime);
my $session_part = $opt{session_name} ? "_$opt{session_name}" : "";
my $checkpoint_file = "$checkpoint_dir/CHECKPOINT_${timestamp}${session_part}.md";

# Get git state
my $git_status = get_git_status();
my $last_commit = get_last_commit();
my $branch = get_current_branch();

# Interactive prompts (unless --auto)
my %context;
unless ($opt{auto}) {
    say "\n=== Context Checkpoint Export ===\n";
    say "Creating checkpoint: $checkpoint_file\n";
    
    $context{active_task} = prompt("Active task description", "");
    $context{status} = prompt("Current status (clean/in-progress/blocked)", "clean");
    
    say "\nRecent achievements (one per line, empty line to finish):";
    $context{achievements} = prompt_multiline();
    
    say "\nOpen issues (one per line, empty line to finish):";
    $context{open_issues} = prompt_multiline();
    
    say "\nNext steps (one per line, empty line to finish):";
    $context{next_steps} = prompt_multiline();
    
    say "\nKey decisions made (one per line, empty line to finish):";
    $context{key_decisions} = prompt_multiline();
    
    say "\nImportant context (optional, one per line, empty line to finish):";
    $context{important_context} = prompt_multiline();
    
    say "\nReference files (optional, one per line, empty line to finish):";
    $context{reference_files} = prompt_multiline();
} else {
    # Auto mode - minimal context
    $context{active_task} = $opt{session_name} || "Automated checkpoint";
    $context{status} = "clean";
    $context{achievements} = ["Automated checkpoint created"];
}

# Generate checkpoint content
my $checkpoint_content = generate_checkpoint(
    timestamp => $timestamp,
    session_name => $opt{session_name},
    branch => $branch,
    last_commit => $last_commit,
    git_status => $git_status,
    %context
);

# Write checkpoint file
open my $fh, '>', $checkpoint_file or die "Cannot write $checkpoint_file: $!\n";
print $fh $checkpoint_content;
close $fh;

say "\n✓ Checkpoint created: $checkpoint_file";
say "";
say "Git status: $git_status";
say "Last commit: $last_commit";
say "";
say "📋 To use this checkpoint:";
say "   1. Start new Claude chat";
say "   2. Attach: $checkpoint_file";
say "   3. Say: 'Resume from checkpoint'";
say "";
say "💡 To load checkpoint info:";
say "   perl scripts/load-context-checkpoint.pl --session-name=$opt{session_name}"
    if $opt{session_name};
say "   perl scripts/load-context-checkpoint.pl  # loads most recent"
    unless $opt{session_name};
say "";

exit 0;

###############################################################################
# Subroutines
###############################################################################

sub prompt {
    my ($question, $default) = @_;
    my $prompt = $default ? "$question [$default]: " : "$question: ";
    print $prompt;
    my $answer = <STDIN>;
    chomp $answer;
    return $answer || $default;
}

sub prompt_multiline {
    my @lines;
    my $line_num = 1;
    while (1) {
        print "  $line_num. ";
        my $line = <STDIN>;
        chomp $line;
        last unless length $line;
        push @lines, $line;
        $line_num++;
    }
    return \@lines;
}

sub get_git_status {
    my $status = `git status --short 2>/dev/null`;
    return $status ? "Modified" : "Clean";
}

sub get_last_commit {
    my $commit = `git log -1 --format='%h - %s' 2>/dev/null`;
    chomp $commit;
    return $commit || "No commits";
}

sub get_current_branch {
    my $branch = `git branch --show-current 2>/dev/null`;
    chomp $branch;
    return $branch || "unknown";
}

sub generate_checkpoint {
    my %args = @_;
    
    my $date = strftime('%Y-%m-%d %H:%M:%S', localtime);
    my $title = $args{session_name} ? "Context Checkpoint - $args{session_name}" 
                                    : "Context Checkpoint";
    
    my $content = <<"END_HEADER";
# $title

**Created**: $date  
**Purpose**: Conversation state preservation for efficient chat reset  
**Session**: $args{session_name}

---

## Current State

- **Active task**: $args{active_task}
- **Last commit**: $args{last_commit}
- **Branch**: $args{branch}
- **Status**: $args{status}
- **Git state**: $args{git_status}

---

END_HEADER

    # Recent Achievements
    if (@{$args{achievements} || []}) {
        $content .= "## Recent Achievements\n\n";
        for my $achievement (@{$args{achievements}}) {
            $content .= "- ✅ $achievement\n";
        }
        $content .= "\n---\n\n";
    }

    # Open Issues
    if (@{$args{open_issues} || []}) {
        $content .= "## Open Issues\n\n";
        my $num = 1;
        for my $issue (@{$args{open_issues}}) {
            $content .= "$num. $issue\n";
            $num++;
        }
        $content .= "\n---\n\n";
    }

    # Next Steps
    if (@{$args{next_steps} || []}) {
        $content .= "## Next Steps\n\n";
        my $num = 1;
        for my $step (@{$args{next_steps}}) {
            $content .= "$num. $step\n";
            $num++;
        }
        $content .= "\n---\n\n";
    }

    # Key Decisions
    if (@{$args{key_decisions} || []}) {
        $content .= "## Key Decisions Made\n\n";
        for my $decision (@{$args{key_decisions}}) {
            $content .= "- **Decision**: $decision\n";
        }
        $content .= "\n---\n\n";
    }

    # Important Context
    if (@{$args{important_context} || []}) {
        $content .= "## Important Context\n\n";
        for my $context (@{$args{important_context}}) {
            $content .= "- $context\n";
        }
        $content .= "\n---\n\n";
    }

    # Reference Files
    if (@{$args{reference_files} || []}) {
        $content .= "## Reference Files\n\n";
        for my $file (@{$args{reference_files}}) {
            $content .= "- `$file`\n";
        }
        $content .= "\n---\n\n";
    }

    # Footer
    $content .= <<"END_FOOTER";
## How to Resume

**Start new chat with**:

\`\`\`
Resume Protocol-7 work from checkpoint.

Workspace: https://github.com/nailara-technologies/workspace-transfer
Branch: $args{branch}
Checkpoint: [attach this file]

Please:
1. Pull latest from workspace
2. Review checkpoint
3. Confirm current state
4. Ready to continue with next steps
\`\`\`

---

**Status**: ✅ Ready for context reset  
**Result**: Continue work with minimal token baseline

---

*"Preserve state, discard process, continue efficiently."*
END_FOOTER

    return $content;
}

sub print_usage {
    print <<"END_USAGE";
export-context-checkpoint.pl - Export conversation state for efficient resets

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --session-name=NAME    Optional session name (e.g., "elf-fix", "phase2")
    --auto                 Non-interactive mode (minimal context)
    --help, -h             Show this help
    --version, -v          Show version

EXAMPLES:
    # Interactive checkpoint with session name
    $0 --session-name=elf-architecture
    
    # Interactive checkpoint (timestamped)
    $0
    
    # Automated checkpoint
    $0 --auto --session-name=daily-backup

WORKFLOW:
    1. Complete major milestone (feature, docs, fix)
    2. Run this script to export checkpoint
    3. Start new chat and attach checkpoint file
    4. Continue with 80-90% lower token baseline

FILES:
    Checkpoints saved to: context-checkpoints/
    Format: CHECKPOINT_YYYYMMDD_HHMMSS[_sessionname].md

SEE ALSO:
    load-context-checkpoint.pl  - Load and view checkpoints
    TODO_BACKUP_RESTORE.md      - Full backup strategy

END_USAGE
}
