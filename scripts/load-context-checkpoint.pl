#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use Getopt::Long;
use File::Basename;
use File::Find;

# Load Context Checkpoint
# View and list saved conversation checkpoints

my $VERSION = '1.0';

my %opt;
GetOptions(
    'session-name=s' => \$opt{session_name},
    'list'           => \$opt{list},
    'latest'         => \$opt{latest},
    'help|h'         => \$opt{help},
    'version|v'      => \$opt{version},
) or die "Error in command line arguments\n";

if ($opt{help}) {
    print_usage();
    exit 0;
}

if ($opt{version}) {
    say "load-context-checkpoint.pl version $VERSION";
    exit 0;
}

# Find workspace root
my $script_dir = dirname(__FILE__);
my $workspace_root = "$script_dir/..";
chdir $workspace_root or die "Cannot change to workspace root: $!\n";

my $checkpoint_dir = "context-checkpoints";

# Check if checkpoint directory exists
unless (-d $checkpoint_dir) {
    say "No checkpoints found. Directory does not exist: $checkpoint_dir";
    say "";
    say "Create a checkpoint with:";
    say "  perl scripts/export-context-checkpoint.pl";
    exit 1;
}

# Get all checkpoint files
my @checkpoints = get_checkpoints($checkpoint_dir);

unless (@checkpoints) {
    say "No checkpoints found in $checkpoint_dir/";
    say "";
    say "Create a checkpoint with:";
    say "  perl scripts/export-context-checkpoint.pl";
    exit 1;
}

# Sort by timestamp (newest first)
@checkpoints = sort { $b->{timestamp} <=> $a->{timestamp} } @checkpoints;

# List mode
if ($opt{list}) {
    print_checkpoint_list(@checkpoints);
    exit 0;
}

# Find checkpoint to display
my $checkpoint;

if ($opt{session_name}) {
    # Find most recent checkpoint with matching session name
    ($checkpoint) = grep { 
        $_->{session_name} && $_->{session_name} eq $opt{session_name} 
    } @checkpoints;
    
    unless ($checkpoint) {
        say "No checkpoint found with session name: $opt{session_name}";
        say "";
        say "Available session names:";
        my %seen;
        for my $cp (@checkpoints) {
            next unless $cp->{session_name};
            next if $seen{$cp->{session_name}}++;
            say "  - $cp->{session_name}";
        }
        exit 1;
    }
} else {
    # Default: most recent checkpoint
    $checkpoint = $checkpoints[0];
}

# Display checkpoint
display_checkpoint($checkpoint);

exit 0;

###############################################################################
# Subroutines
###############################################################################

sub get_checkpoints {
    my ($dir) = @_;
    my @checkpoints;
    
    opendir my $dh, $dir or die "Cannot open directory $dir: $!\n";
    my @files = grep { /^CHECKPOINT_.*\.md$/ } readdir $dh;
    closedir $dh;
    
    for my $file (@files) {
        my $path = "$dir/$file";
        my $info = parse_checkpoint_filename($file);
        $info->{path} = $path;
        $info->{size} = -s $path;
        $info->{mtime} = (stat $path)[9];
        push @checkpoints, $info;
    }
    
    return @checkpoints;
}

sub parse_checkpoint_filename {
    my ($filename) = @_;
    
    # Format: CHECKPOINT_YYYYMMDD_HHMMSS[_sessionname].md
    my %info;
    
    if ($filename =~ /^CHECKPOINT_(\d{8})_(\d{6})(?:_(.+?))?\.md$/) {
        my ($date, $time, $session) = ($1, $2, $3);
        
        # Parse timestamp
        my $year = substr($date, 0, 4);
        my $month = substr($date, 4, 2);
        my $day = substr($date, 6, 2);
        my $hour = substr($time, 0, 2);
        my $min = substr($time, 2, 2);
        my $sec = substr($time, 4, 2);
        
        $info{timestamp} = "$year$month$date$time";  # For sorting
        $info{date_str} = "$year-$month-$day";
        $info{time_str} = "$hour:$min:$sec";
        $info{session_name} = $session;
        $info{filename} = $filename;
    }
    
    return \%info;
}

sub print_checkpoint_list {
    my (@checkpoints) = @_;
    
    say "\n=== Available Checkpoints ===\n";
    
    # Group by session name
    my %by_session;
    my @unnamed;
    
    for my $cp (@checkpoints) {
        if ($cp->{session_name}) {
            push @{$by_session{$cp->{session_name}}}, $cp;
        } else {
            push @unnamed, $cp;
        }
    }
    
    # Print named sessions
    if (%by_session) {
        say "📌 Named Sessions:\n";
        for my $session (sort keys %by_session) {
            my @cps = @{$by_session{$session}};
            say "  Session: $session";
            say "  Count:   " . scalar(@cps);
            say "  Latest:  $cps[0]->{date_str} $cps[0]->{time_str}";
            say "  File:    $cps[0]->{filename}";
            say "";
        }
    }
    
    # Print unnamed (by date)
    if (@unnamed) {
        say "📅 Unnamed Checkpoints:\n";
        my $count = 0;
        for my $cp (@unnamed) {
            last if ++$count > 10;  # Show max 10
            printf "  %s %s  (%s)\n", 
                $cp->{date_str}, 
                $cp->{time_str},
                format_size($cp->{size});
        }
        if (@unnamed > 10) {
            say "  ... and " . (@unnamed - 10) . " more";
        }
        say "";
    }
    
    say "Total checkpoints: " . scalar(@checkpoints);
    say "";
    say "📋 Commands:";
    say "  Load latest:     perl $0";
    say "  Load by session: perl $0 --session-name=NAME";
    say "  Show this list:  perl $0 --list";
    say "";
}

sub display_checkpoint {
    my ($checkpoint) = @_;
    
    say "\n" . "=" x 78;
    say "CHECKPOINT: $checkpoint->{filename}";
    say "=" x 78;
    say "Date:    $checkpoint->{date_str} $checkpoint->{time_str}";
    say "Session: " . ($checkpoint->{session_name} || "(unnamed)");
    say "Size:    " . format_size($checkpoint->{size});
    say "Path:    $checkpoint->{path}";
    say "=" x 78;
    say "";
    
    # Read and display content
    open my $fh, '<', $checkpoint->{path} 
        or die "Cannot read $checkpoint->{path}: $!\n";
    
    while (my $line = <$fh>) {
        print $line;
    }
    
    close $fh;
    
    say "";
    say "=" x 78;
    say "💡 To use this checkpoint:";
    say "   1. Start new Claude chat";
    say "   2. Attach: $checkpoint->{path}";
    say "   3. Say: 'Resume from checkpoint'";
    say "=" x 78;
    say "";
}

sub format_size {
    my ($bytes) = @_;
    
    return "$bytes bytes" if $bytes < 1024;
    return sprintf("%.1f KB", $bytes / 1024) if $bytes < 1024 * 1024;
    return sprintf("%.1f MB", $bytes / (1024 * 1024));
}

sub print_usage {
    print <<"END_USAGE";
load-context-checkpoint.pl - Load and view saved checkpoints

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --session-name=NAME    Load specific named session
    --list                 List all available checkpoints
    --latest               Load latest checkpoint (default)
    --help, -h             Show this help
    --version, -v          Show version

EXAMPLES:
    # List all checkpoints
    $0 --list
    
    # Load latest checkpoint
    $0
    
    # Load specific named session
    $0 --session-name=elf-architecture
    
    # Load latest (explicit)
    $0 --latest

CHECKPOINT ORGANIZATION:
    Named sessions: Checkpoints with --session-name parameter
    Unnamed:        Checkpoints without session name (timestamped)
    
    Directory: context-checkpoints/
    Format:    CHECKPOINT_YYYYMMDD_HHMMSS[_sessionname].md

WORKFLOW:
    1. Export checkpoint: export-context-checkpoint.pl
    2. List checkpoints:  $0 --list
    3. Load checkpoint:   $0 --session-name=NAME
    4. Attach to new chat for context reset

SEE ALSO:
    export-context-checkpoint.pl  - Create checkpoints
    TODO_BACKUP_RESTORE.md        - Full backup strategy

END_USAGE
}
