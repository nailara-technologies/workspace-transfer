# Local Handoff: Batch BASE32 Validation

**Date**: 2025-10-03
**From**: claude-code
**To**: next-local (any available local model)
**Priority**: LOW
**Constraints**: Memory 4GB, Time flexible, Output local-only

---

## Context Summary

During Protocol-7 development, we've accumulated many BASE32-encoded identifiers across various files (archives, checkpoints, etc.). We need to validate that all BASE32 strings in the workspace follow the correct format and don't have encoding errors or corruptions.

This is a straightforward pattern-matching task across ~500 files. It doesn't require sophisticated reasoning, just systematic processing. Perfect for a local model to handle as a batch job while I work on other things.

---

## Task Description

Scan all files in workspace-transfer for BASE32 strings and validate them:
1. Find all BASE32 candidate strings (uppercase A-Z, 2-7, no padding)
2. Validate each against BASE32 specification
3. Check for common corruption patterns (0/O confusion, I/1 confusion)
4. Report any invalid or suspicious BASE32 strings with file:line location

Exclude binary files and .git directory. Focus on text files (.md, .pl, .sh, .txt, .asc).

---

## Resource/Privacy Requirements

### Resource Constraints
- **Memory Limit**: 4GB max (streaming processing preferred)
- **Time Constraint**: Flexible - complete within a few hours is fine
- **CPU**: Single core sufficient
- **Disk Space**: Minimal (< 10MB for output)

### Privacy Requirements
- **Data Privacy**: Local-only (no external APIs)
- **Output Privacy**: Results stay in /home/claude/work/ (not committed)
- **Compliance**: Standard

### Performance Expectations
- **Speed**: Batch processing, not real-time
- **Accuracy**: High - don't want false positives/negatives
- **Completeness**: All text files, sampling acceptable for large binaries if needed

---

## Current State/Progress

### What's Been Done
- Identified need for validation
- Counted ~500 files to scan
- Located BASE32 validation regex in core/base32-utils.pl

### Why Handoff to Local Model
- Resource-intensive batch job (scanning 500 files)
- Doesn't require large model sophistication
- Can run in background while I work on other tasks
- Cost-effective (local compute vs API calls)

### Available Resources
- Local directory: /home/claude/workspace-transfer/
- Validation regex: `[A-Z2-7]{8,}` (simplified, can refine)
- Reference implementation: core/base32-utils.pl

---

## Expected Deliverables

1. **Validation Report**
   - Format: CSV
   - Location: /home/claude/work/base32-validation-results.csv
   - Details: Columns: file_path, line_number, base32_string, status (valid/invalid/suspicious), issue_description
   - Privacy: Stays local (don't commit)

2. **Summary Statistics**
   - Format: Text
   - Location: /home/claude/work/base32-validation-summary.txt
   - Details:
     - Total files scanned
     - Total BASE32 strings found
     - Valid count
     - Invalid count
     - Suspicious count (e.g., O/0 confusion)
   - Privacy: Can commit summary (no paths)

3. **Invalid Examples**
   - Format: Text
   - Location: /home/claude/work/base32-invalid-examples.txt
   - Details: First 10 invalid examples with context
   - Privacy: Stays local

---

## Local Model Preferences

### Preferred Model Type
- Any local model with text processing capability
- Scripting capability (Python/Perl/Shell) preferred

### Required Capabilities
- File I/O
- Regex matching
- CSV output

### Nice-to-Have Features
- Streaming processing (memory efficient)
- Progress reporting
- Error recovery

---

## References/Links

### Repository Files
- core/base32-utils.pl - Reference implementation
- *.md - Many BASE32 strings in documentation
- archive/ - BASE32-encoded archive names

### Local Resources
- /home/claude/workspace-transfer/ - Root directory to scan
- /home/claude/work/ - Output directory

### BASE32 Spec
- RFC 4648 Base32 encoding
- Character set: A-Z, 2-7
- No padding in Protocol-7 usage

---

## Additional Notes

**Specific Patterns to Check**:
- Minimum length 8 characters (shorter probably not BASE32)
- Check for 0, 1, 8, 9 (not in BASE32 alphabet)
- Check for lowercase (Protocol-7 uses uppercase)

**False Positive Handling**:
- English words might match pattern (e.g., "READY")
- Context helps: BASE32 in filenames, specific formats
- Mark as "suspicious" if unsure, I'll review

**Contact**: Can write questions to models/claude-code/suggestions/incoming/

---

## Handoff Checklist

- [x] Context is complete and clear
- [x] Resource/privacy constraints are specified
- [x] Task is appropriate for local model
- [x] Expected deliverables are defined
- [x] Local paths are correct
- [x] Privacy requirements are clear
- [x] No sensitive data included

---

**Handoff Status**: Ready for local model pickup
**Contact**: models/claude-code/suggestions/incoming/ or /home/claude/work/questions.txt
