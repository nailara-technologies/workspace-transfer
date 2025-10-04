#!/usr/bin/env perl
use v5.24;
use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);

# Session Startup with Checkpoint Auto-Detection
# Automatically detect and offer to restore from previous checkpoints

my $VERSION = '1.0';

# Find workspace root
my $script_dir = dirname(abs_path(__FILE__));
my $workspace_root = "$script_dir/..";
chdir $workspace_root or die "Cannot change to workspace root: $!\n";

say "\n" . "=" x 78;
say "WORKSPACE SESSION STARTUP";
say "=" x 78;
say "";

# Check for checkpoints
my $checkpoint_dir = "context-checkpoints";
my @checkpoints = get_available_checkpoints($checkpoint_dir);

if (@checkpoints) {
    say "📋 Found " . scalar(@checkpoints) . " checkpoint(s)";
    say "";
    
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
    
    # Show named sessions
    if (%by_session) {
        say "Named Sessions:";
        my $num = 1;
        for my $session (sort keys %by_session) {
            my $latest = $by_session{$session}[0];
            printf "  %d. %s (latest: %s %s)\n", 
                $num++, $session, $latest->{date_str}, $latest->{time_str};
        }
        say "";
    }
    
    # Show recent unnamed
    if (@unnamed) {
        say "Recent Unnamed:";
        my $count = 0;
        for my $cp (@unnamed) {
            last if ++$count > 3;
            printf "  %d. %s %s\n", 
                scalar(%by_session) + $count, 
                $cp->{date_str}, $cp->{time_str};
        }
        say "";
    }
    
    # Ask user what to do
    say "Options:";
    say "  [number] - Restore specific checkpoint";
    say "  [l]ist   - List all checkpoints";
    say "  [s]kip   - Continue without restoring";
    say "  [q]uit   - Exit";
    say "";
    print "Select option: ";
    
    my $choice = <STDIN>;
    chomp $choice;
    say "";
    
    if ($choice =~ /^l/i) {
        # List mode
        system("perl", "scripts/load-context-checkpoint.pl", "--list");
        exit 0;
        
    } elsif ($choice =~ /^q/i) {
        say "Session startup cancelled.";
        exit 0;
        
    } elsif ($choice =~ /^\d+$/) {
        # Numeric choice
        my $selected = select_checkpoint_by_number($choice, \%by_session, \@unnamed);
        
        if ($selected) {
            restore_checkpoint($selected);
        } else {
            say "Invalid selection. Continuing without restore.";
        }
    } elsif ($choice =~ /^s/i) {
        say "Skipping checkpoint restore.";
    } else {
        say "Invalid option. Continuing without restore.";
    }
    
} else {
    say "No checkpoints found.";
    say "Create one with: perl scripts/export-context-checkpoint.pl";
    say "";
}

# Continue with normal startup
say "=" x 78;
say "Workspace ready. Continuing...";
say "=" x 78;
say "";

# Run standard bootstrap
system("perl", "scripts/../bootstrap.pl");

exit 0;

###############################################################################
# Subroutines
###############################################################################

sub get_available_checkpoints {
    my ($dir) = @_;
    my @checkpoints;
    
    return () unless -d $dir;
    
    opendir my $dh, $dir or return ();
    my @files = grep { /^CHECKPOINT_.*\.(md|enc)$/ } readdir $dh;
    closedir $dh;
    
    for my $file (@files) {
        my $path = "$dir/$file";
        my $info = parse_checkpoint_filename($file);
        $info->{path} = $path;
        $info->{encrypted} = ($file =~ /\.enc$/);
        push @checkpoints, $info;
    }
    
    # Sort by timestamp (newest first)
    @checkpoints = sort { $b->{timestamp} <=> $a->{timestamp} } @checkpoints;
    
    return @checkpoints;
}

sub parse_checkpoint_filename {
    my ($filename) = @_;
    
    my %info;
    
    if ($filename =~ /^CHECKPOINT_(\d{8})_(\d{6})(?:_(.+?))?\.(?:md|enc)$/) {
        my ($date, $time, $session) = ($1, $2, $3);
        
        my $year = substr($date, 0, 4);
        my $month = substr($date, 4, 2);
        my $day = substr($date, 6, 2);
        my $hour = substr($time, 0, 2);
        my $min = substr($time, 2, 2);
        my $sec = substr($time, 4, 2);
        
        $info{timestamp} = "$year$month$date$time";
        $info{date_str} = "$year-$month-$day";
        $info{time_str} = "$hour:$min:$sec";
        $info{session_name} = $session;
        $info{filename} = $filename;
    }
    
    return \%info;
}

sub select_checkpoint_by_number {
    my ($num, $by_session, $unnamed) = @_;
    
    my @all_sessions = sort keys %$by_session;
    
    if ($num <= @all_sessions) {
        # Named session selected
        my $session = $all_sessions[$num - 1];
        return $by_session->{$session}[0];
    } else {
        # Unnamed checkpoint selected
        my $unnamed_index = $num - @all_sessions - 1;
        return $unnamed->[$unnamed_index] if $unnamed_index < @$unnamed;
    }
    
    return undef;
}

sub restore_checkpoint {
    my ($checkpoint) = @_;
    
    say "Restoring checkpoint: $checkpoint->{filename}";
    say "";
    
    if ($checkpoint->{encrypted}) {
        say "⚠️  Checkpoint is encrypted. Decrypting...";
        say "";
        
        # Decrypt first
        my $decrypted = $checkpoint->{path};
        $decrypted =~ s/\.enc$/.md/;
        
        system("perl", "scripts/decrypt-checkpoint.pl", 
               "--input=$checkpoint->{path}", 
               "--output=$decrypted");
        
        if (-f $decrypted) {
            say "";
            display_checkpoint($decrypted);
        } else {
            say "Decryption failed. Continuing without restore.";
        }
    } else {
        display_checkpoint($checkpoint->{path});
    }
}

sub display_checkpoint {
    my ($path) = @_;
    
    say "=" x 78;
    say "CHECKPOINT CONTENT";
    say "=" x 78;
    say "";
    
    open my $fh, '<', $path or do {
        say "Error reading checkpoint: $!";
        return;
    };
    
    while (my $line = <$fh>) {
        print $line;
    }
    
    close $fh;
    
    say "";
    say "=" x 78;
    say "CHECKPOINT RESTORED";
    say "=" x 78;
    say "";
    say "💡 This checkpoint has been loaded into your session context.";
    say "   You can now continue work from where you left off.";
    say "";
}
