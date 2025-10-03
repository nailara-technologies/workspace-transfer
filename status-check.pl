#!/usr/bin/perl
# status-check.pl - Intelligent workspace status analyzer
# Tells you EXACTLY what to do next

use v5.24;
use strict;
use warnings;

say "";
say "=" x 70;
say "                    WORKSPACE STATUS CHECK";
say "=" x 70;
say "";

# Ensure we're in the right directory
unless (-f 'CLAUDE_ONBOARDING.md' && -d '.git') {
    die "❌ Run this from workspace-transfer root directory!\n";
}

my $needs_action = 0;

# 1. Check Phase 0 Status
say "📋 Phase 0: Archive Processing";
my @incoming_zips = glob('incoming/*.zip');
my @incoming_md = glob('incoming/*.md');
my @incoming_files = glob('incoming/*');
@incoming_files = grep { -f $_ } @incoming_files;

if (@incoming_zips > 0) {
    say "   ⚠️  INCOMPLETE: Found " . scalar(@incoming_zips) . " zip archives";
    say "       → Action: Extract archives per CLAUDE_ONBOARDING.md";
    $needs_action = 1;
} elsif (@incoming_md > 10) {
    say "   ⚠️  INCOMPLETE: Found " . scalar(@incoming_md) . " markdown files";
    say "       → Action: Process and organize markdown files";
    $needs_action = 1;
} elsif (@incoming_files > 1) {
    say "   ⚠️  FILES PRESENT: " . scalar(@incoming_files) . " files in incoming/";
    say "       → Action: Review and process files";
    $needs_action = 1;
} else {
    say "   ✅ COMPLETE: incoming/ directory clean";
}

# 2. Check Git Status
say "";
say "💾 Git Status";
my $status_count = `git status --short | wc -l`;
chomp $status_count;

if ($status_count > 0) {
    say "   ⚠️  UNCOMMITTED: $status_count files changed";
    system('git status --short | head -10');
    if ($status_count > 10) {
        say "   ... and " . ($status_count - 10) . " more files";
    }
    say "       → Action: git add -A && git commit -m 'description' && git push";
    $needs_action = 1;
} else {
    say "   ✅ CLEAN: No uncommitted changes";
}

# 3. Check Remote Sync
say "";
say "🌐 Remote Sync";
system('git fetch origin --quiet 2>/dev/null');

my $branch = `git branch --show-current`;
chomp $branch;
say "   📍 Branch: $branch";

my $ahead = `git rev-list origin/$branch..HEAD --count 2>/dev/null`;
my $behind = `git rev-list HEAD..origin/$branch --count 2>/dev/null`;
chomp($ahead, $behind);

if ($ahead > 0) {
    say "   ⚠️  AHEAD: $ahead commits not pushed";
    say "       → Action: git push origin $branch";
    $needs_action = 1;
} elsif ($behind > 0) {
    say "   ⚠️  BEHIND: $behind commits on remote";
    say "       → Action: git pull origin $branch";
    $needs_action = 1;
} else {
    say "   ✅ SYNCED: Local matches remote";
}

# 4. Check Git Config
say "";
say "🔧 Git Configuration";
my $git_user = `git config user.name`;
my $git_email = `git config user.email`;
chomp($git_user, $git_email);

if ($git_user eq 'workspace-transfer' && $git_email eq 'workspace-transfer@taeki.v7.ax') {
    say "   ✅ CONFIGURED: $git_user <$git_email>";
} else {
    say "   ⚠️  MISCONFIGURED: $git_user <$git_email>";
    say "       → Action: Run bootstrap.pl to fix";
    $needs_action = 1;
}

# 5. Quick Stats
say "";
say "📊 Repository Stats";
my $total_files = `find . -type f ! -path './.git/*' | wc -l`;
my $total_commits = `git rev-list --count HEAD 2>/dev/null`;
chomp($total_files, $total_commits);
say "   📁 Files: $total_files";
say "   💾 Commits: $total_commits";

# Final Recommendation
say "";
say "=" x 70;
if ($needs_action) {
    say "⚠️  ACTION REQUIRED - See details above";
} else {
    say "✅ ALL SYSTEMS GO!";
    say "";
    say "🎯 RECOMMENDED WORKFLOW:";
    say "";
    say "   1️⃣  Read the creative excellence checkpoint";
    say "       perl creative-checkpoint.pl";
    say "";
    say "   2️⃣  Check active development priorities";
    say "       cat CURRENT_FOCUS.md";
    say "";
    say "   3️⃣  Review quick status snapshot";
    say "       cat QUICK_STATUS.md";
    say "";
    say "   💡 Completed work archived - clean slate for new development!";
    say "   📁 Archive: archive/ (BMW analysis, session summaries)";
}
say "=" x 70;
say "";
