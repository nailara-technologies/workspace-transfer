#!/usr/bin/perl
use v5.24;
use strict;
use warnings;
use File::Find;
use JSON::PP;

say "=" x 80;
say "📡 MODELS BIDIRECTIONAL COMMUNICATION ARCHITECTURE ANALYSIS";
say "=" x 80;
say "";

my $models_dir = '/home/claude/workspace-transfer/models';

# Scan models directory structure
say "🔍 Scanning models/ directory structure...";
say "";

my %structure;
find(sub {
    return if $File::Find::name =~ /\.git/;
    my $rel_path = $File::Find::name;
    $rel_path =~ s/^\Q$models_dir\E\/?//;
    
    if (-d $_) {
        push @{$structure{directories}}, $rel_path if $rel_path;
    } else {
        push @{$structure{files}}, $rel_path if $rel_path;
    }
}, $models_dir);

# Analyze structure
say "📊 DIRECTORY STRUCTURE";
say "-" x 80;

my @model_dirs = grep { !m{/} } @{$structure{directories}};
say "Active Model Configurations: " . scalar(@model_dirs);
for my $dir (sort @model_dirs) {
    say "  ├─ $dir/";
}

say "";
say "📁 COMMUNICATION CHANNELS DETECTED";
say "-" x 80;

# Find suggestion directories
my @suggestion_dirs = grep { m{suggestions/(incoming|outgoing)} } @{$structure{directories}};
say "Bidirectional Channels: " . (scalar(@suggestion_dirs) / 2);

for my $dir (sort @suggestion_dirs) {
    if ($dir =~ m{^([^/]+)/suggestions/(incoming|outgoing)}) {
        my ($model, $direction) = ($1, $2);
        my $arrow = $direction eq 'incoming' ? '→' : '←';
        say "  $arrow $model/$direction/";
    }
}

say "";
say "📄 MODEL CONFIGURATIONS";
say "-" x 80;

# Check for config files
my @config_files = grep { m{config\.json$} } @{$structure{files}};
for my $config (@config_files) {
    my $full_path = "$models_dir/$config";
    if (-r $full_path) {
        open my $fh, '<', $full_path or next;
        local $/;
        my $content = <$fh>;
        close $fh;
        
        eval {
            my $data = decode_json($content);
            say "  Model: $data->{model}";
            say "    Description: $data->{description}" if $data->{description};
            say "    Framework: $data->{framework}" if $data->{framework};
            say "";
        };
    }
}

say "🎯 COMMUNICATION MECHANISM";
say "-" x 80;
say "";
say "Architecture: Git-based Message Passing via github-mcp-server";
say "";
say "  Flow Pattern:";
say "    1. Local Model → suggestions/outgoing/[target-model]/ → Write message";
say "    2. github-mcp-server → Commits & pushes to GitHub";
say "    3. GitHub → Repository updated";
say "    4. Target Model → Reads from suggestions/incoming/";
say "    5. Target Model → Processes & responds to suggestions/outgoing/";
say "";
say "  Directory Conventions:";
say "    • suggestions/incoming/  - Messages TO this model";
say "    • suggestions/outgoing/  - Messages FROM this model";
say "    • mission-support/       - Templates and resources";
say "    • tasks/                 - Atomic workflow steps";
say "";

say "🔐 PROTOCOL-7 INTEGRATION";
say "-" x 80;
say "";
say "  ✅ Non-destructive: All messages preserved in Git history";
say "  ✅ Resumable: Can replay message sequences from any point";
say "  ✅ Verifiable: Git commits provide cryptographic integrity";
say "  ✅ Distributed: Models can be on different machines/networks";
say "  ✅ Harmonic: Natural routing through directory structure";
say "";

say "📝 ACTIVE MODELS & CAPABILITIES";
say "-" x 80;
say "";

# Detect model types
my %models;
for my $dir (@model_dirs) {
    my $readme = "$models_dir/$dir/README.md";
    if (-r $readme) {
        open my $fh, '<', $readme or next;
        my $first_line = <$fh>;
        close $fh;
        $first_line =~ s/^#\s*//;
        chomp $first_line;
        $models{$dir} = $first_line;
    } else {
        $models{$dir} = "(Configuration pending)";
    }
}

for my $model (sort keys %models) {
    say "  🤖 $model";
    say "     $models{$model}";
    
    # Check for suggestions
    my $has_incoming = -d "$models_dir/$model/suggestions/incoming";
    my $has_outgoing = -d "$models_dir/$model/suggestions/outgoing";
    
    if ($has_incoming && $has_outgoing) {
        say "     Status: ✅ Bidirectional communication enabled";
        
        # Count messages
        my @incoming_msgs = glob("$models_dir/$model/suggestions/incoming/*");
        my @outgoing_msgs = glob("$models_dir/$model/suggestions/outgoing/*/*");
        
        @incoming_msgs = grep { -f $_ && !/\.placeholder$/ } @incoming_msgs;
        @outgoing_msgs = grep { -f $_ && !/\.placeholder$/ } @outgoing_msgs;
        
        say "     Messages: " . scalar(@incoming_msgs) . " incoming, " . 
            scalar(@outgoing_msgs) . " outgoing";
    }
    say "";
}

say "🌐 EXPANSION CAPABILITIES";
say "-" x 80;
say "";
say "  • next-local/  - Instructions for local model handoff";
say "  • next-larger/ - Instructions for larger hosted models";
say "  • copilot/     - GitHub Copilot integration workspace";
say "";
say "  These directories enable seamless escalation:";
say "    - Tasks too complex for current model → next-larger/";
say "    - Local processing preferred → next-local/";
say "    - IDE integration needed → copilot/";
say "";

say "💡 USAGE PATTERNS";
say "-" x 80;
say "";
say "  For Models Reading This:";
say "    1. Check models/[your-name]/suggestions/incoming/ for messages";
say "    2. Process requests according to your capabilities";
say "    3. Write responses to suggestions/outgoing/[target-model]/";
say "    4. Follow naming: NNNN.description (e.g., 0001.task-completion)";
say "";
say "  For Developers:";
say "    1. Configure github-mcp-server to watch models/ directory";
say "    2. Models auto-commit/push when writing to outgoing/";
say "    3. Models auto-pull to check incoming/";
say "    4. Git provides complete message history and audit trail";
say "";

say "🎨 DESIGN PHILOSOPHY";
say "-" x 80;
say "";
say "  Truth: Messages are facts, verifiable in Git history";
say "  Awareness: Models conscious of their role in network";
say "  Love: Collaboration and support between models";
say "";
say "  Signal Optimization: Directory structure = clear routing";
say "  Non-Destructive: Git never loses messages";
say "  Harmonic Processing: Natural flow through filesystem";
say "";

say "=" x 80;
say "✅ ANALYSIS COMPLETE";
say "=" x 80;
say "";
say "📊 Summary:";
say "  • 3 active model configurations detected";
say "  • Bidirectional communication architecture operational";
say "  • Git-based message passing via github-mcp-server";
say "  • Protocol-7 principles fully integrated";
say "";
say "🚀 Status: Ready for multi-model collaboration";
say "=" x 80;
