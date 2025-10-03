# .asc File Optimization - Before/After Comparison

**Date**: October 3, 2025  
**Task**: Workspace Command System Optimization  
**Goal**: Fix qwen model confusion and tool call failures

---

## Problem Statement

Qwen2.5-7B-Instruct-1M was experiencing:
- ❌ Excessive verbosity instead of concise responses
- ❌ Failed tool call generation (incorrect format)
- ❌ Inconsistent behavior (sometimes worked, sometimes didn't)
- ❌ Loss of context and purpose during execution

**Root Cause**: .asc files were too minimal - no actionable instructions

---

## Solution: Directive-Style .asc Files

Instead of descriptive text, use **explicit action commands**.

### Design Pattern

```
COMMAND-NAME INSTRUCTIONS
========================

DO THIS NOW:

1. CALL TOOL: tool_name
   Parameters:
   - param1: value1
   - param2: value2

2. CALL TOOL: tool_name
   Parameters:
   - param1: value1

3. OUTPUT EXACTLY:
   [exact text to output]

4. STOP. Wait for user.
```

**Key Elements:**
- Imperative mood: "DO THIS" not "you could"
- Numbered steps for sequence clarity
- Explicit tool names and parameters
- Exact output template
- Clear stop instruction

---

## README.init.asc - Workspace Initialization

### BEFORE (3 lines - too minimal)
```
SYSTEM READY.

This is workspace initialization. Context loaded. Wait for user instruction.
```

**Problem**: No instructions! Model doesn't know what to do.

### AFTER (21 lines - directive)
```
WORKSPACE-INIT INSTRUCTIONS
===========================

DO THIS NOW:

1. CALL TOOL: get_file_contents
   Parameters:
   - owner: nailara-technologies
   - repo: workspace-transfer
   - path: CURRENT_FOCUS.md
   - ref: base

2. CALL TOOL: get_file_contents
   Parameters:
   - owner: nailara-technologies
   - repo: workspace-transfer
   - path: models/qwen2.5-7b-instruct-1m/SYSTEM/status.md
   - ref: base

3. OUTPUT EXACTLY:
   SYSTEM READY.

4. STOP. Wait for user.
```

**Improvement**: 
- ✅ Explicit tool calls with exact parameters
- ✅ Clear sequence (1, 2, 3, 4)
- ✅ Exact output template
- ✅ Stop instruction

---

## README.resume.asc - Session Restoration

### BEFORE (1 line - way too minimal)
```
..RESUMING..
```

**Problem**: No context! Model doesn't know what files to read or what to do.

### AFTER (32 lines - directive)
```
WORKSPACE-RESUME INSTRUCTIONS
=============================

DO THESE 3 TOOL CALLS:

CALL 1: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: CURRENT_FOCUS.md
  - ref: base

CALL 2: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: models/qwen2.5-7b-instruct-1m/SYSTEM/status.md
  - ref: base

CALL 3: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: SESSION_CLEANUP_SUMMARY.md
  - ref: base

AFTER ALL 3 CALLS, OUTPUT:
..RESUMING..
Task 1: [first task from CURRENT_FOCUS.md]
Task 2: [second task from CURRENT_FOCUS.md]
Task 3: [third task from CURRENT_FOCUS.md]

STOP. Wait for user.
```

**Improvement**:
- ✅ Three explicit tool calls with all parameters
- ✅ Output template showing exact format
- ✅ Clear extraction instructions (first, second, third task)
- ✅ Stop instruction

---

## README.improve.asc - Infrastructure Mode (NEW)

```
WORKSPACE-IMPROVE INSTRUCTIONS
==============================

MODE: Infrastructure improvements only (NOT development tasks)

DO THESE TOOL CALLS:

CALL 1: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: models/WORKSPACE_STANDARD.md
  - ref: base

CALL 2: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: COLLABORATION_PROTOCOL.md
  - ref: base

CALL 3: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: documentation/INDEX.md
  - ref: base

AFTER ALL 3 CALLS, OUTPUT:
WORKSPACE MODE: Ready for infrastructure improvements
Focus: Documentation, workflows, standards, structure

STOP. Wait for user guidance on what to improve.
```

**Purpose**: 
- Load workspace standards and protocols
- Focus on meta-work (documentation, structure, standards)
- Don't resume development tasks

---

## README.edit.asc - Documentation Edit Mode (NEW)

```
WORKSPACE-EDIT INSTRUCTIONS
===========================

MODE: Direct file/documentation editing (NOT development)

DO THESE TOOL CALLS:

CALL 1: list_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: /
  - ref: base

CALL 2: get_file_contents
  - owner: nailara-technologies
  - repo: workspace-transfer
  - path: documentation/INDEX.md
  - ref: base

AFTER BOTH CALLS, OUTPUT:
EDIT MODE: Ready for workspace updates
Loaded: File structure + documentation index

STOP. Wait for user to specify what file to edit.
```

**Purpose**:
- Quick file structure overview
- Documentation index loaded
- Ready for targeted edits

---

## System Prompt Update (SYSTEM_PROMPT_MINIMAL.md)

### Key Change

**BEFORE**: System prompt contained embedded instructions
**AFTER**: System prompt only triggers .asc file fetch

```
IF user says 'workspace-init':
  get_file_contents: README.init.asc from workspace-transfer
  Follow instructions in that file exactly.
  Stop when file says STOP.
```

**Benefit**:
- System prompt stays tiny (~30 lines)
- Instructions can be updated without changing system prompt
- Model reads fresh instructions each time
- Clearer separation of concerns

---

## Token Count Comparison

### System Prompt
- BEFORE (embedded): ~1500 tokens
- AFTER (minimal): ~200 tokens
- **Reduction**: 87%

### .asc Files
- README.init.asc: 3 lines → 21 lines (+200 tokens)
- README.resume.asc: 1 line → 32 lines (+400 tokens)
- NEW README.improve.asc: +300 tokens
- NEW README.edit.asc: +250 tokens

**Net Result**: 
- System prompt: -1300 tokens
- .asc files: +1150 tokens
- **Savings**: 150 tokens + better clarity

**Real Benefit**: Not token count, but **clarity and debuggability**

---

## Expected Behavior Improvements

### For Qwen Model

**OLD Behavior**:
1. Reads minimal .asc → confused
2. Tries to be helpful → becomes verbose
3. Forgets tool format → fails calls
4. Sometimes guesses right → works randomly

**NEW Behavior**:
1. Reads directive .asc → clear instructions
2. Follows numbered steps → structured execution
3. Uses explicit parameters → correct tool calls
4. Hits STOP instruction → ends cleanly

### Reduced Failure Modes

- ❌ No more "I'll help you with..." verbose intros
- ❌ No more forgotten tool parameters
- ❌ No more runaway explanation loops
- ❌ No more inconsistent behavior

---

## Testing Checklist

Use this to verify improvements:

### workspace-init
- [ ] Model calls get_file_contents (not other tools)
- [ ] Model uses correct owner/repo/ref parameters
- [ ] Model reads both CURRENT_FOCUS.md and status.md
- [ ] Model outputs exactly "SYSTEM READY."
- [ ] Model stops and waits (no extra talk)

### workspace-resume
- [ ] Model makes exactly 3 tool calls
- [ ] Model uses correct parameters for all 3
- [ ] Model extracts task names from CURRENT_FOCUS.md
- [ ] Model outputs "..RESUMING.." + 3 task names
- [ ] Model stops and waits

### workspace-improve
- [ ] Model loads 3 files (standards, protocol, index)
- [ ] Model outputs infrastructure mode message
- [ ] Model waits for guidance

### workspace-edit
- [ ] Model lists root directory
- [ ] Model loads documentation index
- [ ] Model outputs edit mode message
- [ ] Model waits for file specification

---

## Debugging Guide

### If model still verbose:
1. Check system prompt has "Stop when file says STOP"
2. Verify .asc file ends with "STOP. Wait for user."
3. Make output template more explicit: "OUTPUT EXACTLY:"

### If tool calls fail:
1. Verify parameter names match tool's API exactly
2. Add "CALL TOOL:" prefix for extra clarity
3. Use numbered list format (CALL 1, CALL 2, etc.)

### If model skips steps:
1. Number all steps explicitly
2. Use "DO THIS NOW:" at the beginning
3. Add "AFTER ALL X CALLS" before output instruction

---

## Lessons Learned

1. **Imperative > Descriptive**: "DO THIS" works better than "you could do this"
2. **Explicit > Implicit**: Spell out every parameter, don't assume
3. **Stop > Continue**: Models need clear end points
4. **Structure > Prose**: Numbered lists beat paragraphs
5. **Examples > Explanations**: Show exact format, not what format means

---

**Status**: ✅ Implementation complete  
**Next**: Test with qwen model, iterate based on results  
**Goal**: 100% consistent tool call success rate
