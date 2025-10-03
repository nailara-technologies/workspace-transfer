#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Path qw(make_path);
use File::Copy qw(move);
use File::Basename;

say "🧹 WORKSPACE CLEANUP - Archiving Completed Work";
say "=" x 70;

# Define archive structure
my $archive_base = 'archive';
my %moves = (
    # Completed BMW Analysis
    'bmw-analysis/' => 'archive/completed/bmw-resumability-oct3-2025/',
    
    # Completed Session Summaries
    'SESSION_COMPLETION_SUMMARY.md' => 'archive/sessions/oct3-2025/',
    'SESSION_SUMMARY_OCT3_2025.md' => 'archive/sessions/oct3-2025/',
    'SESSION_SYNTHESIS_OCT3_2025.md' => 'archive/sessions/oct3-2025/',
    'CLEANUP_CHECK.md' => 'archive/sessions/oct1-2025/',
    'WORK_PLAN.md' => 'archive/sessions/oct1-2025/',
    
    # Old onboarding versions (keep current at root)
    'CLAUDE_ONBOARDING_P7_WORKSPACE.md' => 'archive/old-docs/',
    'INSTANT_BOOT.md' => 'archive/old-docs/',
);

# Create archive directories
say "\n📁 Creating archive structure...";
for my $dest (values %moves) {
    if ($dest =~ m{/$}) {
        make_path($dest) unless -d $dest;
        say "   ✅ $dest";
    } else {
        my $dir = dirname($dest);
        make_path($dir) unless -d $dir;
        say "   ✅ $dir";
    }
}

# Move files/directories
say "\n📦 Moving completed work to archive...";
for my $src (sort keys %moves) {
    my $dest = $moves{$src};
    
    if (-e $src) {
        if (-d $src) {
            # Directory move
            my $target_dir = $dest;
            system("cp -r '$src' '$target_dir'") == 0 
                or die "Failed to copy directory $src: $!";
            say "   ✅ $src -> $target_dir";
        } else {
            # File move
            my $target_file = $dest =~ m{/$} ? "$dest" . basename($src) : $dest;
            my $target_dir = dirname($target_file);
            make_path($target_dir) unless -d $target_dir;
            
            system("cp '$src' '$target_file'") == 0
                or die "Failed to copy $src: $!";
            say "   ✅ $src -> $target_file";
        }
    } else {
        say "   ⏭️  $src (not found, skipping)";
    }
}

# Now remove originals (only if copies succeeded)
say "\n🗑️  Removing originals after successful archiving...";
for my $src (sort keys %moves) {
    if (-e $src) {
        if (-d $src) {
            system("rm -rf '$src'") == 0
                or warn "Failed to remove directory $src: $!";
            say "   ✅ Removed $src";
        } else {
            unlink $src or warn "Failed to remove $src: $!";
            say "   ✅ Removed $src";
        }
    }
}

# Create archive index
say "\n📋 Creating archive index...";
my $index_file = "$archive_base/INDEX.md";
open my $idx, '>', $index_file or die "Cannot create index: $!";

print $idx "# Archive Index\n\n";
print $idx "**Generated**: " . scalar(localtime) . "\n\n";
print $idx "This directory contains completed work that has been archived to maintain\n";
print $idx "workspace clarity. All work here is finished and documented.\n\n";
print $idx "---\n\n";

print $idx "## Completed Projects\n\n";
print $idx "### BMW Resumability Analysis (October 3, 2025)\n";
print $idx "- **Location**: `completed/bmw-resumability-oct3-2025/`\n";
print $idx "- **Status**: ✅ Production ready\n";
print $idx "- **Result**: Added getstate/setstate methods to Digest::BMW\n";
print $idx "- **Key Files**: BMW_ANALYSIS_COMPLETE.md, enhanced-BMW.xs\n\n";

print $idx "## Session Summaries\n\n";
print $idx "### October 3, 2025 Session\n";
print $idx "- **Location**: `sessions/oct3-2025/`\n";
print $idx "- **Highlights**: BMW resumability, 5/13 harmonics, covert channels\n";
print $idx "- **Duration**: ~2.5 hours\n\n";

print $idx "### October 1, 2025 Session\n";
print $idx "- **Location**: `sessions/oct1-2025/`\n";
print $idx "- **Highlights**: Instant boot system, workspace optimization\n\n";

print $idx "## Old Documentation\n\n";
print $idx "- **Location**: `old-docs/`\n";
print $idx "- **Contents**: Superseded onboarding documents\n\n";

print $idx "---\n\n";
print $idx "*All archived work is preserved for reference and can be restored if needed.*\n";

close $idx;
say "   ✅ Created $index_file";

say "\n" . "=" x 70;
say "✅ CLEANUP COMPLETE";
say "";
say "📊 Summary:";
say "   - Archived: BMW analysis (complete project)";
say "   - Archived: Session summaries (Oct 1 & 3)";
say "   - Archived: Old documentation versions";
say "   - Created: Archive index for reference";
say "";
say "🎯 Next: Update QUICK_STATUS.md and create CURRENT_FOCUS.md";
say "=" x 70;
