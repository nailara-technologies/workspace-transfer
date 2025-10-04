#!/usr/bin/env perl
use strict;
use warnings;
use v5.10;

# Diagnostic: Help identify what file qwen is fetching and why tasks aren't executing

say "═" x 70;
say "QWEN WORKSPACE-RESUME DIAGNOSTIC";
say "═" x 70;
say "";

say "SYMPTOM:";
say "  ✅ Model outputs '..RESUMING..' cleanly (no extra text)";
say "  ✅ Model doesn't ask for permission";
say "  ❌ Model doesn't execute tasks (fetch CURRENT_FOCUS.md, status.md)";
say "";

say "═" x 70;
say "DIAGNOSIS QUESTIONS";
say "═" x 70;
say "";

print "1. Which file did qwen fetch? (check the tool call)\n";
print "   Options:\n";
print "   a) README.resume.asc (v3.1 - old format)\n";
print "   b) workspace-resume.yaml (v4.0 - new format)\n";
print "   Your answer (a/b): ";
my $file = <STDIN>;
chomp $file;

say "";

if (lc($file) eq 'a') {
    say "PROBLEM IDENTIFIED: Using old .asc file";
    say "";
    say "The .asc file format has EXECUTE: directives, but qwen's system prompt";
    say "doesn't have explicit parsing logic to process them.";
    say "";
    say "SOLUTION OPTIONS:";
    say "";
    say "Option A: Switch to YAML (v4.0 approach)";
    say "-" x 70;
    say "1. Update qwen system prompt to SYSTEM_PROMPT_MINIMAL_v4.0.md";
    say "2. In workspace-resume command, change:";
    say "   path: README.resume.asc  →  path: workspace-resume.yaml";
    say "3. Test again";
    say "";
    say "This switches from keyword-based (.asc) to data-structure-based (YAML)";
    say "";
    
    say "Option B: Fix .asc parsing (stay with v3.1)";
    say "-" x 70;
    say "Add explicit parsing loop to system prompt:";
    say "";
    say "```";
    say "2. Execute the file line by line:";
    say "   ";
    say "   current_line = first_line";
    say "   WHILE current_line exists:";
    say "     ";
    say "     IF current_line starts with 'EXECUTE:':";
    say "       tool_call = parse_tool_from_line(current_line)";
    say "       CALL tool_call NOW";
    say "     ";
    say "     IF current_line starts with 'OUTPUT-STOP:':";
    say "       text = everything_after('OUTPUT-STOP:')";
    say "       OUTPUT text";
    say "       STOP";
    say "     ";
    say "     current_line = next_line";
    say "```";
    say "";
    say "This gives qwen explicit algorithm for processing EXECUTE: directives.";
    say "";
    
} elsif (lc($file) eq 'b') {
    say "FILE IS CORRECT: Using new YAML format";
    say "";
    say "PROBLEM: System prompt doesn't know how to parse YAML tasks";
    say "";
    say "SOLUTION:";
    say "-" x 70;
    say "Update qwen system prompt to SYSTEM_PROMPT_MINIMAL_v4.0.md";
    say "";
    say "Key section that's missing:";
    say "";
    say "```";
    say "2. PARSE the YAML structure:";
    say "   - Iterate through tasks[] array";
    say "   - For each task: CALL the tool with params";
    say "   - After all tasks: OUTPUT the output.text value";
    say "   - STOP";
    say "```";
    say "";
    say "Without this, qwen sees YAML but doesn't know to parse tasks[] array.";
    say "";
}

say "═" x 70;
say "ADDITIONAL DEBUGGING";
say "═" x 70;
say "";

print "2. Does qwen's system prompt mention 'TASK PARSER'? (y/n): ";
my $parser = <STDIN>;
chomp $parser;

if (lc($parser) eq 'n') {
    say "";
    say "⚠️  System prompt is NOT updated to v4.0";
    say "";
    say "You need to replace qwen's system prompt with:";
    say "  SYSTEM_PROMPT_MINIMAL_v4.0.md";
    say "";
    say "This version positions qwen as a 'TASK PARSER' that knows";
    say "to iterate through YAML tasks[] arrays.";
    say "";
}

say "";
print "3. Does system prompt have explicit FOR EACH or WHILE loop for tasks? (y/n): ";
my $loop = <STDIN>;
chomp $loop;

if (lc($loop) eq 'n') {
    say "";
    say "⚠️  System prompt missing execution loop";
    say "";
    say "Even with YAML, qwen needs explicit instructions:";
    say "";
    say "FOR each task in tasks[]:";
    say "  tool_name = task.tool";
    say "  params = task.params";
    say "  CALL tool_name with params";
    say "";
    say "Without this loop, qwen doesn't know to iterate through tasks.";
    say "";
}

say "";
say "═" x 70;
say "SUMMARY";
say "═" x 70;
say "";

say "Current behavior analysis:";
say "";
say "✅ GOOD: Model outputs cleanly without asking";
say "  → Pre-authorization language is working!";
say "  → Model respects OUTPUT-STOP";
say "";
say "❌ ISSUE: Model doesn't execute task directives";
say "  → Either: Old .asc file without parsing loop";
say "  → Or: YAML file without tasks[] iteration logic";
say "";
say "NEXT STEP:";
say "";

if (lc($file) eq 'a' && lc($parser) eq 'n') {
    say "1. Switch to v4.0 approach (recommended):";
    say "   - Update system prompt to SYSTEM_PROMPT_MINIMAL_v4.0.md";
    say "   - Change workspace-resume to fetch workspace-resume.yaml";
    say "   - Test again";
    say "";
    say "2. Or fix v3.1 .asc parsing:";
    say "   - Add explicit parsing loop to system prompt";
    say "   - Keep using .asc files";
} else {
    say "Update system prompt to v4.0:";
    say "   - Copy content from SYSTEM_PROMPT_MINIMAL_v4.0.md";
    say "   - Paste into qwen configuration";
    say "   - Ensure it includes tasks[] iteration logic";
    say "   - Test workspace-resume again";
}

say "";
say "═" x 70;

__END__

=head1 NAME

qwen-diagnostic.pl - Diagnose why workspace-resume doesn't execute tasks

=head1 DESCRIPTION

Helps identify why qwen outputs "..RESUMING.." correctly but doesn't
execute the task directives (fetching CURRENT_FOCUS.md and status.md).

Common causes:
1. Using old .asc file without parsing loop in system prompt
2. Using YAML file without tasks[] iteration logic in system prompt
3. System prompt not updated to v4.0

=head1 USAGE

    perl qwen-diagnostic.pl

Answer the questions interactively to identify the issue.

=cut
