#!/usr/bin/perl
# Transfer files from workspace-transfer/protocol7-staging to protocol-7 repository
# Usage: transfer-to-protocol7.pl [--dry-run] [--interactive] [--auto]

use v5.24;
use strict;
use warnings;
use File::Spec;
use File::Copy;
use File::Path qw(make_path);
use Cwd qw(abs_path getcwd);
use FindBin qw($RealBin);

# Configuration - using Protocol-7 pattern for robust path resolution
my $up_dir = File::Spec->updir;
my $WORKSPACE_ROOT = abs_path(File::Spec->rel2abs(File::Spec->catdir($RealBin, $up_dir)));
my $STAGING_DIR = File::Spec->catdir($WORKSPACE_ROOT, 'protocol7-staging');
my $TARGET_REPO = abs_path(File::Spec->catdir($WORKSPACE_ROOT, $up_dir, 'protocol-7'));
my $MANIFEST_FILE = File::Spec->catfile($STAGING_DIR, '.manifest.yaml');

# Command line options
my $DRY_RUN = grep { $_ eq '--dry-run' } @ARGV;
my $INTERACTIVE = grep { $_ eq '--interactive' } @ARGV;
my $AUTO = grep { $_ eq '--auto' } @ARGV;
my $HELP = grep { $_ =~ /^(-h|--help)$/ } @ARGV;

# Colors for output
my $GREEN = "\e[32m";
my $YELLOW = "\e[33m";
my $RED = "\e[31m";
my $BLUE = "\e[34m";
my $RESET = "\e[0m";

# Show help
if ($HELP) {
    show_help();
    exit 0;
}

# Validate environment
validate_environment();

# Load manifest
my $manifest = load_manifest();

# Check target repo status
check_git_status() if $manifest->{options}{check_git_status};

# Display transfer plan
say "${BLUE}=== Transfer Plan ===${RESET}";
say "Source: $STAGING_DIR";
say "Target: $TARGET_REPO";
say "Mode: " . ($DRY_RUN ? "DRY RUN" : $INTERACTIVE ? "INTERACTIVE" : $AUTO ? "AUTO" : "INTERACTIVE (default)");
say "";

# Get transfers
my @transfers = @{$manifest->{transfers} || []};

if (@transfers == 0) {
    say "${YELLOW}⚠️  No transfers defined in manifest.${RESET}";
    say "Add entries to: $MANIFEST_FILE";
    exit 0;
}

say "${BLUE}Transfers to process: " . scalar(@transfers) . "${RESET}\n";

# Process each transfer
my $transferred = 0;
my $skipped = 0;
my $failed = 0;

foreach my $transfer (@transfers) {
    my $result = process_transfer($transfer);

    if ($result eq 'success') {
        $transferred++;
    } elsif ($result eq 'skip') {
        $skipped++;
    } else {
        $failed++;
    }
}

# Summary
say "";
say "${BLUE}=== Transfer Summary ===${RESET}";
say "${GREEN}✅ Transferred: $transferred${RESET}";
say "${YELLOW}⏭️  Skipped: $skipped${RESET}" if $skipped > 0;
say "${RED}❌ Failed: $failed${RESET}" if $failed > 0;

if ($DRY_RUN) {
    say "";
    say "${YELLOW}This was a DRY RUN. No files were actually transferred.${RESET}";
    say "Run without --dry-run to perform actual transfer.";
}

exit($failed > 0 ? 1 : 0);

# ============================================================================
# Functions
# ============================================================================

sub show_help {
    say "Transfer files from protocol7-staging to protocol-7 repository";
    say "";
    say "Usage: transfer-to-protocol7.pl [OPTIONS]";
    say "";
    say "Options:";
    say "  --dry-run       Show what would be transferred without doing it";
    say "  --interactive   Ask for confirmation before each transfer (default)";
    say "  --auto          Transfer all without confirmation";
    say "  -h, --help      Show this help message";
    say "";
    say "Examples:";
    say "  ./transfer-to-protocol7.pl --dry-run       # Preview transfers";
    say "  ./transfer-to-protocol7.pl --interactive   # Confirm each";
    say "  ./transfer-to-protocol7.pl --auto          # Transfer all";
    say "";
    say "Manifest file: protocol7-staging/.manifest.yaml";
}

sub validate_environment {
    # Check staging directory exists
    unless (-d $STAGING_DIR) {
        die "${RED}❌ Staging directory not found: $STAGING_DIR${RESET}\n";
    }

    # Check target repo exists
    unless (-d $TARGET_REPO) {
        die "${RED}❌ Target repository not found: $TARGET_REPO${RESET}\n";
    }

    # Check manifest exists
    unless (-f $MANIFEST_FILE) {
        die "${RED}❌ Manifest file not found: $MANIFEST_FILE${RESET}\n";
    }

    # Check target is a git repo
    unless (-d "$TARGET_REPO/.git") {
        warn "${YELLOW}⚠️  Target is not a git repository: $TARGET_REPO${RESET}\n";
    }
}

sub load_manifest {
    # Simple YAML parser for our specific manifest format
    # Parses transfers list and options hash

    open my $fh, '<', $MANIFEST_FILE or die "Cannot read $MANIFEST_FILE: $!";

    my $manifest = {
        transfers => [],
        options => {
            backup_enabled => 1,
            check_git_status => 1,
            preserve_permissions => 1,
        }
    };

    my $current_section = '';
    my $current_transfer = undef;
    my $in_transfers = 0;
    my $indent_level = 0;

    while (my $line = <$fh>) {
        chomp $line;

        # Skip comments and empty lines
        next if $line =~ /^\s*#/ || $line =~ /^\s*$/;
        next if $line =~ /^---/;  # YAML document separator

        # Detect sections
        if ($line =~ /^transfers:/) {
            $in_transfers = 1;
            next;
        }

        if ($line =~ /^options:/) {
            $in_transfers = 0;
            $current_section = 'options';
            next;
        }

        # Parse transfers section
        if ($in_transfers) {
            if ($line =~ /^\s*-\s+source:\s*"?([^"]+)"?/) {
                # New transfer entry
                $current_transfer = { source => $1 };
                push @{$manifest->{transfers}}, $current_transfer;
            }
            elsif ($current_transfer && $line =~ /^\s+(\w+):\s*"?([^"#]+?)"?\s*(?:#.*)?$/) {
                my ($key, $value) = ($1, $2);
                $value =~ s/\s+$//;  # Trim trailing whitespace
                $current_transfer->{$key} = $value;
            }
        }

        # Parse options section
        if ($current_section eq 'options' && $line =~ /^\s+(\w+):\s*(.+?)\s*(?:#.*)?$/) {
            my ($key, $value) = ($1, $2);
            # Convert YAML booleans
            $value = 1 if $value =~ /^(true|yes)$/i;
            $value = 0 if $value =~ /^(false|no)$/i;
            $value =~ s/^"(.*)"$/$1/;  # Remove quotes
            $manifest->{options}{$key} = $value;
        }
    }

    close $fh;
    return $manifest;
}

sub check_git_status {
    my $cwd = getcwd();
    chdir($TARGET_REPO) or die "Cannot cd to $TARGET_REPO: $!";

    my $status = `git status --porcelain 2>/dev/null`;

    if ($status && $status =~ /\S/) {
        say "${YELLOW}⚠️  Target repository has uncommitted changes:${RESET}";
        say $status;
        say "";

        unless ($AUTO || $DRY_RUN) {
            print "Continue anyway? [y/N] ";
            my $response = <STDIN>;
            chomp $response;

            unless ($response =~ /^y/i) {
                say "Transfer cancelled.";
                exit 0;
            }
        }
    }

    chdir($cwd);
}

sub process_transfer {
    my ($transfer) = @_;

    my $source = "$STAGING_DIR/" . $transfer->{source};
    my $dest = "$TARGET_REPO/" . $transfer->{dest};
    my $action = $transfer->{action} || 'copy';
    my $description = $transfer->{description} || $transfer->{source};

    # Check source exists
    unless (-e $source) {
        say "${RED}❌ Source not found: $transfer->{source}${RESET}";
        return 'failed';
    }

    # Display transfer info
    say "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}";
    say "Source: $transfer->{source}";
    say "Dest:   $transfer->{dest}";
    say "Action: $action";
    say "Info:   $description" if $description;

    # Check if destination exists
    my $dest_exists = -e $dest;
    if ($dest_exists) {
        say "${YELLOW}⚠️  Destination exists${RESET}";
    }

    # Interactive confirmation
    if ($INTERACTIVE && !$DRY_RUN && !$AUTO) {
        print "Proceed with this transfer? [Y/n] ";
        my $response = <STDIN>;
        chomp $response;

        if ($response =~ /^n/i) {
            say "${YELLOW}⏭️  Skipped${RESET}";
            return 'skip';
        }
    }

    # Dry run - just show what would happen
    if ($DRY_RUN) {
        say "${GREEN}✓ Would transfer${RESET}";
        return 'success';
    }

    # Perform transfer
    eval {
        # Create destination directory if needed
        my $dest_dir = dirname($dest);
        make_path($dest_dir) unless -d $dest_dir;

        # Backup existing file if configured
        if ($dest_exists && $manifest->{options}{backup_enabled}) {
            my $backup = $dest . ($manifest->{options}{backup_suffix} || '.bak');
            copy($dest, $backup) or warn "Backup failed: $!";
            say "${YELLOW}📦 Backed up to: " . basename($backup) . "${RESET}";
        }

        # Perform action
        if ($action eq 'copy') {
            copy($source, $dest) or die "Copy failed: $!";
            say "${GREEN}✅ Copied${RESET}";

        } elsif ($action eq 'move') {
            move($source, $dest) or die "Move failed: $!";
            say "${GREEN}✅ Moved${RESET}";

        } elsif ($action eq 'sync') {
            # Only copy if source is newer
            if (!$dest_exists || -M $source < -M $dest) {
                copy($source, $dest) or die "Sync failed: $!";
                say "${GREEN}✅ Synchronized${RESET}";
            } else {
                say "${YELLOW}⏭️  Destination is up-to-date${RESET}";
                return 'skip';
            }

        } else {
            die "Unknown action: $action";
        }

        # Set permissions if specified
        if ($transfer->{chmod}) {
            chmod(oct($transfer->{chmod}), $dest) or warn "chmod failed: $!";
        }

        # Preserve permissions from source
        elsif ($manifest->{options}{preserve_permissions}) {
            my $mode = (stat($source))[2] & 07777;
            chmod($mode, $dest) or warn "chmod failed: $!";
        }

    };

    if ($@) {
        say "${RED}❌ Transfer failed: $@${RESET}";
        return 'failed';
    }

    return 'success';
}

__END__

=head1 NAME

transfer-to-protocol7.pl - Transfer files from staging to protocol-7 repository

=head1 SYNOPSIS

    transfer-to-protocol7.pl [--dry-run] [--interactive] [--auto]

=head1 DESCRIPTION

Transfers files defined in protocol7-staging/.manifest.yaml to the protocol-7 repository.

Supports dry-run mode, interactive confirmation, and automatic transfer modes.

=head1 OPTIONS

=over 4

=item --dry-run

Show what would be transferred without actually doing it.

=item --interactive

Ask for confirmation before each transfer (default mode).

=item --auto

Transfer all files without confirmation.

=item -h, --help

Show help message.

=back

=head1 EXAMPLES

    # Preview what would be transferred
    ./transfer-to-protocol7.pl --dry-run

    # Transfer with confirmation for each file
    ./transfer-to-protocol7.pl --interactive

    # Transfer all automatically
    ./transfer-to-protocol7.pl --auto

=head1 MANIFEST

Edit protocol7-staging/.manifest.yaml to define transfers:

    transfers:
      - source: "modules/httpd.new_feature"
        dest: "modules/httpd.new_feature"
        action: "copy"
        description: "New HTTP feature"

=head1 AUTHOR

workspace-transfer team

=cut
