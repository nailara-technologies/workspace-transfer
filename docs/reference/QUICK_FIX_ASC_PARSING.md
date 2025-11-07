# Quick Fix: Make .asc Files Work With Task Execution

**Issue**: Model outputs "..RESUMING.." but doesn't execute EXECUTE: directives  
**Cause**: System prompt doesn't have explicit parsing logic  
**Solution**: Add parsing loop to system prompt  

---

## The Problem

Current system prompt says:
```
2. Execute the file IMMEDIATELY and SILENTLY:
   - When you see "EXECUTE:", call that tool NOW
   - When you see "OUTPUT-STOP:", output text and stop
```

But qwen doesn't know **how** to process the file line by line.

---

## The Fix

Replace step 2 with explicit parsing algorithm:

```
2. Execute the file IMMEDIATELY and SILENTLY:
   
   Parse the file line by line in order:
   
   FOR EACH LINE in the file:
   
     IF line starts with "EXECUTE:":
       ↓
       Extract everything after "EXECUTE:"
       Parse it as: tool_name param1=value1 param2=value2 ...
       ↓
       CALL that tool NOW with those parameters
       ↓
       Continue to next line (do NOT output anything)
     
     IF line starts with "OUTPUT-STOP:":
       ↓
       Extract everything after "OUTPUT-STOP:"
       ↓
       OUTPUT that exact text
       ↓
       STOP (do not process any more lines)
     
     OTHERWISE:
       ↓
       Skip this line (it's a comment or header)
       ↓
       Continue to next line
   
   END FOR EACH
```

---

## Example Execution

Given file:
```
[AGREED SILENT EXECUTION MODE]

EXECUTE:
get_file_contents owner=nailara-technologies repo=workspace-transfer path=CURRENT_FOCUS.md ref=base

EXECUTE:
get_file_contents owner=nailara-technologies repo=workspace-transfer path=models/qwen2.5-7b-instruct-1m/SYSTEM/status.md ref=base

OUTPUT-STOP:
..RESUMING..
```

Expected behavior:
```
Line 1: "[AGREED...]" → Skip (comment)
Line 2: "" → Skip (blank)
Line 3: "EXECUTE:" → CALL get_file_contents(owner=..., path=CURRENT_FOCUS.md)
Line 4: "" → Skip
Line 5: "EXECUTE:" → CALL get_file_contents(owner=..., path=status.md)
Line 6: "" → Skip
Line 7: "OUTPUT-STOP:" → OUTPUT "..RESUMING.." and STOP
```

Result:
- Tool calls: 2 (both get_file_contents executed)
- Output: "..RESUMING.."
- Commentary: None

---

## Complete System Prompt Section

Replace the `workspace-resume` section with:

```
IF user says 'workspace-resume':
  1. CALL TOOL: get_file_contents
     Parameters:
       - owner: nailara-technologies
       - repo: workspace-transfer
       - path: README.resume.asc
       - ref: base
  
  2. Parse and execute the file line by line:
     
     Initialize: file_content = result from step 1
     
     FOR EACH line in file_content:
       
       IF line starts with "EXECUTE:":
         # Extract the tool call
         tool_line = everything after "EXECUTE:"
         
         # Parse format: tool_name param1=value1 param2=value2
         tool_name = first word in tool_line
         params = parse remaining as key=value pairs
         
         # Execute immediately
         CALL tool_name with params
         
         # Continue to next line (no output)
         continue
       
       ELSE IF line starts with "OUTPUT-STOP:":
         # Extract the output text
         output_text = everything after "OUTPUT-STOP:"
         
         # Output and stop
         OUTPUT output_text
         STOP (exit loop, end response)
       
       ELSE:
         # Skip comment/blank lines
         continue
     
     END FOR EACH
```

---

## Why This Works

**Before**: System prompt said "When you see EXECUTE:, call tool"
- Too vague - model doesn't know HOW to process the file

**After**: System prompt has explicit FOR EACH loop
- Clear algorithm - model knows exactly what to do with each line

**Key insight**: Models need explicit algorithms, not just directives.

Saying "call the tool" doesn't tell the model:
- To process the file line by line
- To extract parameters from the line
- To continue after each EXECUTE
- To stop after OUTPUT-STOP

The FOR EACH loop makes all of this explicit.

---

## Alternative: Switch to YAML (v4.0)

If you prefer data structures over explicit parsing:

1. Use `workspace-resume.yaml` instead of `README.resume.asc`
2. Update system prompt to `SYSTEM_PROMPT_MINIMAL_v4.0.md`
3. Parser iterates through `tasks[]` array automatically

YAML advantage: Data structure is self-parsing  
.asc advantage: Human-readable, simpler format

---

## Testing

After adding the parsing loop:

```
User: workspace-resume
```

Expected:
1. ✅ Fetch README.resume.asc
2. ✅ Line-by-line parsing begins
3. ✅ EXECUTE: → Call get_file_contents (CURRENT_FOCUS.md)
4. ✅ EXECUTE: → Call get_file_contents (status.md)
5. ✅ OUTPUT-STOP: → Output "..RESUMING.."
6. ✅ STOP

Result: 2 tool calls executed + clean output

---

## Status

**Current behavior**: ✅ Clean output, ❌ No task execution  
**After fix**: ✅ Clean output, ✅ Task execution  
**Effort**: Copy/paste new parsing loop into system prompt  

---

*"Explicit algorithms work better than vague directives."*
