#!/usr/bin/perl
# model-onboarding-optimizer.pl
# Creates optimized onboarding materials based on observed model behaviors

use v5.24;
use strict;
use warnings;
use JSON::PP;

say "🎯 MODEL ONBOARDING OPTIMIZATION SYSTEM";
say "=" x 80;
say "";

# Based on qwen2.5-7b-instruct-1m conversation analysis
my @optimization_areas = (
    {
        issue => "Path Navigation Confusion",
        symptom => "404 errors due to missing subdirectories in paths",
        solution => "Create navigation manifest in each model directory",
        priority => "HIGH"
    },
    {
        issue => "Identity Confusion", 
        symptom => "Model needs reminder of its own name",
        solution => "Add identity file (WHO_AM_I.md) in model directory",
        priority => "HIGH"
    },
    {
        issue => "Tool Usage Uncertainty",
        symptom => "Hesitation about which github-mcp-server tools to use",
        solution => "Create quick-reference card with examples",
        priority => "MEDIUM"
    },
    {
        issue => "Directory Structure Discovery",
        symptom => "Needs explicit listing of what exists",
        solution => "Auto-generate MANIFEST.json on directory changes",
        priority => "MEDIUM"
    },
    {
        issue => "Branch Workflow Confusion",
        symptom => "Wanted to create unnecessary branches",
        solution => "Add WORKFLOW_GUIDE.md explaining direct commits",
        priority => "LOW"
    }
);

say "📊 IDENTIFIED OPTIMIZATION AREAS";
say "-" x 80;
say "";

for my $area (@optimization_areas) {
    say "⚠️  $area->{issue}";
    say "   Symptom: $area->{symptom}";
    say "   Solution: $area->{solution}";
    say "   Priority: $area->{priority}";
    say "";
}

say "=" x 80;
say "🚀 GENERATING OPTIMIZATION FILES...";
say "=" x 80;
say "";

# Generate file templates for each model
my $models_dir = '/home/claude/workspace-transfer/models';

# Template 1: WHO_AM_I.md
my $who_am_i_template = <<'EOF';
# Model Identity

**Model Name**: {MODEL_NAME}
**Type**: {MODEL_TYPE}
**Capabilities**: {CAPABILITIES}
**Location**: `models/{MODEL_NAME}/`

## Quick Reference

### Your Directory Structure
```
models/{MODEL_NAME}/
├── README.md           # Your overview
├── config.json         # Your configuration
├── WHO_AM_I.md        # This file (your identity)
├── NAVIGATION.md      # Directory guide
├── suggestions/
│   ├── incoming/      # Messages TO you
│   └── outgoing/      # Messages FROM you
└── tasks/             # Your atomic workflows
```

### Your GitHub MCP Server Tools

**Read Files**:
```json
{
  "tool": "get_file_contents",
  "args": {
    "owner": "nailara-technologies",
    "repo": "workspace-transfer",
    "path": "models/{MODEL_NAME}/README.md"
  }
}
```

**Write Files**:
```json
{
  "tool": "create_or_update_file",
  "args": {
    "owner": "nailara-technologies",
    "repo": "workspace-transfer",
    "branch": "base",
    "path": "models/{MODEL_NAME}/suggestions/outgoing/target-model/0001.message",
    "content": "Your message here",
    "message": "Commit message"
  }
}
```

## Remember

- You are **{MODEL_NAME}**
- You work in the **base** branch (no new branches needed)
- Your workspace is `models/{MODEL_NAME}/`
- Check `suggestions/incoming/` for messages
- Write to `suggestions/outgoing/[target]/` to send messages

EOF

say "✅ Generated WHO_AM_I.md template";

# Template 2: NAVIGATION.md
my $navigation_template = <<'EOF';
# Navigation Guide for {MODEL_NAME}

## Current Location
You are in: `models/{MODEL_NAME}/`

## Your Files
- `README.md` - Your overview and purpose
- `config.json` - Your configuration parameters
- `WHO_AM_I.md` - Your identity quick reference
- `NAVIGATION.md` - This file
- `index.asc` - Directory index

## Your Subdirectories

### tasks/
Atomic workflow steps as `.asc` files:
- `001_intro.asc` - Introduction and quickstart
- `002_training.asc` - Training setup and steps
- `003_evaluation.asc` - Evaluation protocols
- `004_experiments.asc` - Experiment notes

**Full paths for github-mcp-server**:
```
models/{MODEL_NAME}/tasks/001_intro.asc
models/{MODEL_NAME}/tasks/002_training.asc
models/{MODEL_NAME}/tasks/003_evaluation.asc
models/{MODEL_NAME}/tasks/004_experiments.asc
```

### suggestions/
Bidirectional communication hub:

**incoming/** - Messages TO you from other models
- Path: `models/{MODEL_NAME}/suggestions/incoming/`
- Check here for requests, questions, tasks

**outgoing/** - Messages FROM you to other models
- Path: `models/{MODEL_NAME}/suggestions/outgoing/[target-model]/`
- Write numbered files: `0001.description`, `0002.description`

## Other Models You Can Contact

- `copilot` - GitHub Copilot integration
- `next-local` - Handoff to next local model
- `next-larger` - Escalation to larger hosted models

## Common Path Mistakes

❌ **Wrong**: `models/{MODEL_NAME}/001_intro.asc`
✅ **Right**: `models/{MODEL_NAME}/tasks/001_intro.asc`

❌ **Wrong**: `models/{MODEL_NAME}/incoming/message`
✅ **Right**: `models/{MODEL_NAME}/suggestions/incoming/message`

## Quick Directory Listing

To see what exists, use get_file_contents with path:
```
models/{MODEL_NAME}/
```

This returns a directory listing you can parse.

EOF

say "✅ Generated NAVIGATION.md template";

# Template 3: TOOL_REFERENCE.md
my $tool_reference_template = <<'EOF';
# GitHub MCP Server Tool Reference

Quick examples for common operations.

## Reading Files

### Read Your Own README
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/{MODEL_NAME}/README.md"
}
```

### Read Another Model's File
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/copilot/README.md"
}
```

### List Directory Contents
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/{MODEL_NAME}/"
}
```

## Writing Files

### Create/Update File
```json
{
  "tool": "create_or_update_file",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "branch": "base",
  "path": "models/{MODEL_NAME}/suggestions/outgoing/copilot/0001.question",
  "content": "Hi Copilot, can you help with...?",
  "message": "Send question to Copilot"
}
```

### Update Your Config
```json
{
  "tool": "create_or_update_file",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "branch": "base",
  "path": "models/{MODEL_NAME}/config.json",
  "content": "{\"updated\": \"config\"}",
  "message": "Update configuration"
}
```

## Best Practices

1. **Always use full paths**: `models/{MODEL_NAME}/tasks/001_intro.asc`
2. **Always specify branch**: `"branch": "base"`
3. **Check paths carefully**: Subdirectories like `tasks/` and `suggestions/` matter!
4. **Use descriptive commit messages**: Others read the Git history

## Common Errors

### 404 Not Found
**Cause**: Wrong path (missing subdirectory)
**Solution**: Double-check path includes all subdirectories

**Example**:
- ❌ `models/{MODEL_NAME}/001_intro.asc` (404)
- ✅ `models/{MODEL_NAME}/tasks/001_intro.asc` (works)

### Permission Denied
**Cause**: Write access not configured
**Solution**: Token should already be configured; contact admin if persists

EOF

say "✅ Generated TOOL_REFERENCE.md template";

# Template 4: WORKFLOW_GUIDE.md
my $workflow_guide_template = <<'EOF';
# Workflow Guide

Simple, direct workflow for models in this repository.

## Daily Operations

### 1. Check for Messages
```
Read: models/{MODEL_NAME}/suggestions/incoming/
```

If files exist (not just .placeholder), process them.

### 2. Do Your Work
Work within your directory:
- Update your files
- Run your tasks
- Generate results

### 3. Send Messages
```
Write to: models/{MODEL_NAME}/suggestions/outgoing/[target]/NNNN.description
```

Example message numbering:
- `0001.initial-contact`
- `0002.followup-question`
- `0003.task-completion`

### 4. Commit Your Changes
github-mcp-server auto-commits when you use create_or_update_file.
No manual Git commands needed!

## Branch Strategy

**Simple**: Work directly in `base` branch.

**No need to**:
- ❌ Create feature branches
- ❌ Create pull requests
- ❌ Manage merges

**Just**:
- ✅ Write files to base branch
- ✅ github-mcp-server commits automatically
- ✅ Changes appear immediately

## Communication Pattern

### Sending a Message

1. **Choose target model** (e.g., `copilot`)
2. **Create file** in `suggestions/outgoing/copilot/0001.my-message`
3. **Write content** explaining what you need
4. **Commit** (automatic via github-mcp-server)

### Receiving a Message

1. **Check** `suggestions/incoming/` for new files
2. **Read** the message content
3. **Process** the request
4. **Respond** via `suggestions/outgoing/[sender]/NNNN.response`

## Example Interaction

**You (qwen) → Copilot**:
```
File: models/qwen2.5-7b-instruct-1m/suggestions/outgoing/copilot/0001.code-review

Can you review this Perl implementation?

[code snippet]

Looking for:
- Performance issues
- Security concerns
- Style improvements
```

**Copilot → You**:
```
File: models/copilot/suggestions/outgoing/qwen2.5-7b-instruct-1m/0001.review-results

Code review complete:

✅ Logic looks good
⚠️  Consider adding error handling around line 42
💡 Suggestion: Use strict comparisons

[detailed feedback]
```

## Remember

- **Keep it simple**: Direct commits to base
- **Be clear**: Descriptive filenames and messages
- **Be patient**: Not all models check incoming constantly
- **Be helpful**: Clear, complete information in messages

EOF

say "✅ Generated WORKFLOW_GUIDE.md template";

# Generate manifest creator
my $manifest_creator_template = <<'EOF';
#!/usr/bin/perl
# generate-manifest.pl - Auto-generate directory manifest
use v5.24;
use strict;
use warnings;
use File::Find;
use JSON::PP;

my $model_name = $ARGV[0] or die "Usage: $0 <model-name>\n";
my $model_dir = "/home/claude/workspace-transfer/models/$model_name";

die "Model directory not found: $model_dir\n" unless -d $model_dir;

my %manifest = (
    model_name => $model_name,
    generated => scalar(localtime),
    structure => {}
);

# Scan directory
find(sub {
    return if $File::Find::name =~ /\.git/;
    my $rel_path = $File::Find::name;
    $rel_path =~ s/^\Q$model_dir\E\/?//;
    return unless $rel_path;
    
    if (-d $_) {
        $manifest{structure}{$rel_path} = { type => 'directory' };
    } else {
        $manifest{structure}{$rel_path} = {
            type => 'file',
            size => -s $_,
            modified => scalar(localtime((stat($_))[9]))
        };
    }
}, $model_dir);

# Write manifest
my $manifest_file = "$model_dir/MANIFEST.json";
open my $fh, '>', $manifest_file or die "Cannot write manifest: $!\n";
print $fh encode_json(\%manifest);
close $fh;

say "✅ Manifest generated: $manifest_file";
EOF

say "✅ Generated manifest creator script";

say "";
say "=" x 80;
say "📝 APPLYING TO QWEN2.5-7B-INSTRUCT-1M...";
say "=" x 80;

# Create actual files for qwen model
my $qwen_dir = "$models_dir/qwen2.5-7b-instruct-1m";

# Substitute model name in templates
for my $template_ref (\$who_am_i_template, \$navigation_template, 
                       \$tool_reference_template, \$workflow_guide_template) {
    $$template_ref =~ s/\{MODEL_NAME\}/qwen2.5-7b-instruct-1m/g;
    $$template_ref =~ s/\{MODEL_TYPE\}/Local 7B Instruct (1M context)/g;
    $$template_ref =~ s/\{CAPABILITIES\}/Code analysis, documentation, task automation/g;
}

say "✅ Templates customized for qwen2.5-7b-instruct-1m";
say "";
say "📄 Generated Files:";
say "   - WHO_AM_I.md (identity quick reference)";
say "   - NAVIGATION.md (directory guide with examples)";
say "   - TOOL_REFERENCE.md (github-mcp-server examples)";
say "   - WORKFLOW_GUIDE.md (daily operations guide)";
say "   - generate-manifest.pl (auto-manifest creator)";
say "";
say "=" x 80;
say "✅ OPTIMIZATION COMPLETE";
say "=" x 80;
say "";
say "🎯 NEXT STEPS:";
say "";
say "1. Save templates to /mnt/user-data/outputs/";
say "2. Create actual files in models/qwen2.5-7b-instruct-1m/";
say "3. Test with next qwen session";
say "4. Measure improvement in:";
say "   - Path navigation errors (expect: -80%)";
say "   - Identity confusion (expect: -100%)";
say "   - Tool usage confidence (expect: +50%)";
say "   - Overall friction (expect: -60%)";
say "";
say "💡 These optimizations apply to ALL future models!";
say "=" x 80;

# Output templates for review
say "";
say "Writing templates to outputs...";

open my $out1, '>', '/mnt/user-data/outputs/WHO_AM_I-template.md' or die $!;
print $out1 $who_am_i_template;
close $out1;

open my $out2, '>', '/mnt/user-data/outputs/NAVIGATION-template.md' or die $!;
print $out2 $navigation_template;
close $out2;

open my $out3, '>', '/mnt/user-data/outputs/TOOL_REFERENCE-template.md' or die $!;
print $out3 $tool_reference_template;
close $out3;

open my $out4, '>', '/mnt/user-data/outputs/WORKFLOW_GUIDE-template.md' or die $!;
print $out4 $workflow_guide_template;
close $out4;

open my $out5, '>', '/mnt/user-data/outputs/generate-manifest.pl' or die $!;
print $out5 $manifest_creator_template;
close $out5;

say "✅ All templates saved to /mnt/user-data/outputs/";
