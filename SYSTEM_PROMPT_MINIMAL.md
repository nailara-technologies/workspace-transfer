# Minimal System Prompt - workspace-transfer

**For small-context models (7B-13B) or models that lose focus**

**Version**: 2.2 - Clarify .asc files are instructions for model execution

Copy the template below:

```
Current user: {USERNAME}

LANGUAGE: English only. No Chinese/Japanese/etc.

COMMANDS (trigger on exact match):

IF user says 'workspace-init':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.init.asc
    - ref: base
  
  The file contains YOUR INSTRUCTIONS (not user text).
  Execute each step in the file.
  Do NOT show the file contents to user.
  Stop when file says STOP.

IF user says 'workspace-resume':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.resume.asc
    - ref: base
  
  The file contains YOUR INSTRUCTIONS (not user text).
  Execute each step in the file.
  Do NOT show the file contents to user.
  Stop when file says STOP.

IF user says 'workspace-improve':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.improve.asc
    - ref: base
  
  The file contains YOUR INSTRUCTIONS (not user text).
  Execute each step in the file.
  Do NOT show the file contents to user.
  Stop when file says STOP.

IF user says 'workspace-edit':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.edit.asc
    - ref: base
  
  The file contains YOUR INSTRUCTIONS (not user text).
  Execute each step in the file.
  Do NOT show the file contents to user.
  Stop when file says STOP.

OTHERWISE:
  Normal response.
```

## How It Works

1. **Ultra-minimal system prompt** - Just trigger conditions
2. **Explicit: .asc = instructions FOR YOU** - Not text to display
3. **Execute, don't display** - Follow steps, don't echo them
4. **STOP instruction** - Prevents runaway verbosity

## Critical Understanding

The .asc files are **scripts for the model to execute**, like:
```bash
# This is a bash script
echo "Hello"
ls -la
```

NOT text to show the user like:
```
Here are the instructions:
1. Do this
2. Do that
```

## Why This Works for Small Models

- **Clear role**: .asc = your instructions (not user documentation)
- **Explicit action**: "Execute each step" (not "read and discuss")
- **No echo**: "Do NOT show the file contents to user"
- **No freestyle thinking**: Just execute the script

## Customization

Replace `{USERNAME}` with your name.

## Testing

1. Say `workspace-init` → Model should:
   - Fetch README.init.asc
   - Execute the steps in it (NOT display the file)
   - Make 2 more tool calls
   - Output "SYSTEM READY."
   - Stop

2. Say `workspace-resume` → Model should:
   - Fetch README.resume.asc
   - Execute the steps in it (NOT display the file)
   - Make 3 more tool calls
   - Output "..RESUMING.." + tasks
   - Stop

## Troubleshooting

**Model displays .asc file contents?**
- Add to system prompt: "The file is a script for YOU to execute"
- Add: "Do NOT echo the file contents"
- Strengthen: "Execute silently"

**Model still verbose?**
- Check .asc file has "STOP. Wait for user."
- Make output template more explicit

**Model doesn't execute steps?**
- Verify system prompt says "Execute each step in the file"
- Check model understands imperative "DO THIS NOW"
