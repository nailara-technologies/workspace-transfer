# Task: System Prompt Optimization Strategy

**Date**: 2025-10-03
**Status**: Active Discussion Needed
**Priority**: HIGH
**For**: Claude Code (Anthropic)

---

## Problem Statement

We've developed a workspace command system (`workspace-init`, `workspace-resume`) for AI models to bootstrap into the workspace-transfer repository. The system works but has evolved into complexity that causes issues with smaller models (7B-13B parameters).

### Current Issues

1. **System Prompt Bloat**: Full template is ~200+ lines with examples, explanations, testing checklists
2. **Scope Breakout**: Qwen 7B model loses focus, switches languages, makes up tasks instead of reading files
3. **Verbose Execution**: Model explains what it's doing instead of just executing and stopping
4. **Fragile Instructions**: Need extremely explicit formatting to prevent model confusion

### What Works

- **workspace-init**: Model reads `README.init.asc`, sees "SYSTEM READY", stops ✅
- **workspace-resume**: Model reads 3 files, outputs task names... but gets verbose ⚠️
- **Minimal prompts**: Shorter = better for small models ✅

---

## Current Architecture

### System Prompt Pattern
```
IF user prompt is 'workspace-init':
  Read README.init.asc
  Stop

IF user prompt is 'workspace-resume':
  Read README.resume.asc
  Read status.md
  Read CURRENT_FOCUS.md
  Output: task list
  Stop
```

### Remote Files
- `README.init.asc`: Contains "SYSTEM READY.\n\nThis is workspace initialization..."
- `README.resume.asc`: Contains "..RESUMING.." (just signal, no instructions)
- `README.asc`: Bootstrap instructions for limited-context models
- `README.details.asc`: Extended details (optional)

### The Tension

**Option A: Instructions in System Prompt**
- ✅ Pro: Model has clear commands to execute
- ❌ Con: Prompt gets long, model loses focus
- ❌ Con: Can't update instructions without changing prompt

**Option B: Instructions in Remote Files**
- ✅ Pro: Prompt stays minimal
- ✅ Pro: Instructions updateable via git
- ❌ Con: Model treats file content as text to display, not commands to execute
- ❌ Con: Model gets verbose reading instructions aloud

---

## Proposed Solution (Needs Strategy Discussion)

### Concept: URL-Based Command Routing

Instead of complex instructions, use ultra-simple mapping:

```
Command System:
workspace-init → https://raw.githubusercontent.com/.../README.init.asc
workspace-resume → https://raw.githubusercontent.com/.../README.resume.asc
workspace-improve → https://raw.githubusercontent.com/.../README.improve.asc
workspace-edit → https://raw.githubusercontent.com/.../README.edit.asc
```

System prompt becomes:
```
Current user: {USERNAME}
LANGUAGE: English only.

Commands:
workspace-init: <remote-url>/README.init.asc
workspace-resume: <remote-url>/README.resume.asc
workspace-improve: <remote-url>/README.improve.asc
workspace-edit: <remote-url>/README.edit.asc

Execute: Read URL file, follow instructions, stop.
```

### Files Contain Executable Instructions

Each .asc file would have:
```
[CONFIRMATION MESSAGE]
[TOOL CALLS TO MAKE]
[OUTPUT FORMAT]
[STOP]
```

But presented in a way that's **executable** not **displayable**.

---

## Questions for Claude Code

### 1. Instruction Format
How can we format instructions in a remote file so models **execute** them rather than **display** them?

**Ideas:**
- Use imperative commands: "CALL get_file_contents(...)"
- Use structured format: `TOOL: get_file_contents | PARAMS: {...}`
- Use minimal natural language: "Read X. Read Y. Output Z. Stop."

### 2. Separation of Concerns
Should we split into:
- **Trigger files** (README.init.asc, README.resume.asc): Just confirmation messages
- **Instruction files** (INIT_PROCEDURE.asc, RESUME_PROCEDURE.asc): Actual steps
- **System prompt**: Just maps command → instruction file URL

Or keep it integrated?

### 3. Model Capability Tiers
Should we have different strategies for:
- **Tier 1**: Large capable models (Claude, GPT-4) - can handle complex prompts
- **Tier 2**: Medium models (13B-70B) - need structured simplicity
- **Tier 3**: Small models (7B) - need absolute minimal prompts

And provide different templates for each?

### 4. Output Control
How do we prevent models from being verbose after reading files?

**Current attempts:**
- "Stop. Do not explain." → Still explains
- "Silent mode" → Still talks
- Files say "STOP NOW" → Outputs that text

**Possible solutions:**
- Acceptance: Let models be slightly verbose if functional
- Format trick: Make files so short there's nothing to explain
- Post-processing: User ignores verbose output, just waits for task list

### 5. Scalability
We want to add more commands (workspace-improve, workspace-edit, workspace-status). How do we keep the system prompt from growing with each new command?

**Pattern ideas:**
- Single line per command: `workspace-X: <url>`
- Config file approach: System prompt says "Read COMMANDS.asc for command list"
- Prefix matching: Any `workspace-*` command reads `README.<command>.asc`

---

## Success Criteria

A successful solution would:

1. ✅ System prompt under 20 lines total
2. ✅ Works reliably with 7B models (qwen2.5-7b-instruct-1m tested)
3. ✅ Commands are git-updateable (don't require system prompt changes)
4. ✅ Model outputs minimal confirmation + data (not verbose explanations)
5. ✅ New commands can be added without prompt bloat
6. ✅ Clear separation: trigger → read → execute → output → stop

---

## Current Experiments

### SYSTEM_PROMPT_SIGNATURE.md (NEW - Cryptographic Approach)
Uses validate-signature.pl tool to cryptographically verify command files.
- Models verify signatures themselves via tool calls
- Trust through verification, not agreement
- Protocol-7 ELF checksums (ELF4/ELF7 with BMW pattern)
- Tamper-proof: any modification invalidates signature
- Status: Implemented, signatures validated successfully

### SYSTEM_PROMPT_MINIMAL.md
16-line prompt with AGREED SILENT EXECUTION MODE keywords.
- Uses EXECUTE: and OUTPUT-STOP: keywords
- Agreement-based protocol
- Fallback for models without signature validation tools

### SYSTEM_PROMPT_TEMPLATE.md
Full template (~200 lines) with all documentation. Works but overwhelming.

### File Structure
- `README.init.asc`: Unsigned version with EXECUTE: keywords
- `README.init.elf7.asc`: Signed version (checksum: 1047b26)
- `README.resume.asc`: Unsigned version
- `README.resume.elf7.asc`: Signed version (checksum: 0a00101)
- `validate-signature.pl`: Signature creation and validation tool

---

## Request

**Please analyze this problem and propose:**

1. **Optimal instruction format** for remote .asc files that models will execute (not just display)
2. **System prompt architecture** that stays minimal while supporting multiple commands
3. **Tier strategy** for different model capabilities
4. **Output control mechanism** to prevent verbose explanations
5. **Scalability pattern** for adding workspace-improve, workspace-edit, etc.

**Deliverable:**
Strategic recommendations with examples for each point. Focus on:
- What's actually achievable with small models vs. what requires larger models
- Trade-offs between simplicity and functionality
- Practical patterns that work across model types

---

## Context Files to Review

- `/SYSTEM_PROMPT_TEMPLATE.md` - Full current template
- `/SYSTEM_PROMPT_MINIMAL.md` - Minimal experiment
- `/README.init.asc` - Init trigger file
- `/README.resume.asc` - Resume trigger file
- `/models/claude-code/sessions/2025-10-03-models-optimization.md` - Previous session context

**Session token usage**: ~105K / 200K (plenty of room for analysis)

---

**Ready for your strategic input on simplifying this system while maintaining reliability!**

---

## Important Note on Task Delegation

**You can hand off implementation tasks back to the local model (Qwen) if it will save tokens!**

This task is about **strategy and architecture design** - that's where your (Claude Code) capabilities shine. But for:

- **Repetitive file edits** (updating multiple .asc files with similar content)
- **Testing iterations** (trying different prompt variations)
- **Documentation updates** (recording what works/doesn't work)
- **Git operations** (committing incremental changes)

Feel free to:
1. **Analyze and strategize** (your strength - complex reasoning)
2. **Provide clear implementation instructions** (what to change, how, why)
3. **Suggest handing off to local model** for execution if it will save significant tokens

Example handoff format:
```
HANDOFF TO LOCAL MODEL:
Task: Update README.resume.asc with new format
Changes needed:
  - Line 1: Change X to Y
  - Add section Z after line 5
Reasoning: This is a simple file edit that doesn't require my reasoning capabilities
```

The local model has shown it can:
- ✅ Make file edits when given explicit instructions
- ✅ Commit and push changes
- ✅ Follow structured task lists
- ❌ Complex multi-step reasoning (needs your help here)

**Token efficiency matters** - use your reasoning for strategy, delegate execution when appropriate!
