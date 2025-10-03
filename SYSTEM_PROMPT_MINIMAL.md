# Minimal System Prompt - workspace-transfer

**For small-context models (7B-13B) or models that lose focus**

**Version**: 2.1 - Explicit repo parameter fix

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
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-resume':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.resume.asc
    - ref: base
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-improve':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.improve.asc
    - ref: base
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-edit':
  CALL TOOL: get_file_contents
  Parameters:
    - owner: nailara-technologies
    - repo: workspace-transfer
    - path: README.edit.asc
    - ref: base
  Follow instructions in that file exactly.
  Stop when file says STOP.

OTHERWISE:
  Normal response.
```

## How It Works

1. **Ultra-minimal system prompt** - Just trigger conditions
2. **Explicit tool parameters** - Every parameter spelled out including repo
3. **All instructions in .asc files** - Model reads explicit steps
4. **STOP instruction** - Prevents runaway verbosity

## Why This Works for Small Models

- **No ambiguity**: "CALL TOOL: get_file_contents" with all params
- **Explicit repo parameter**: repo: workspace-transfer (not implicit)
- **Clear stopping point**: "Stop when file says STOP."
- **No freestyle thinking**: Just follow the recipe

## Customization

Replace `{USERNAME}` with your name.

## Testing

1. Say `workspace-init` → Model should call tool with ALL 4 parameters (owner, repo, path, ref)
2. Model should read README.init.asc
3. Model should follow instructions in that file
4. Model should STOP after confirmation (not keep talking)

## Troubleshooting

**Model missing repo parameter?**
- Check system prompt has "repo: workspace-transfer" explicitly listed
- Make sure Parameters: section is indented under CALL TOOL

**Model calls wrong tool?**
- Verify "CALL TOOL: get_file_contents" is explicit
- Check tool name matches API exactly

**Model doesn't stop?**
- Strengthen STOP command: "Stop when file says STOP."
- Add to end: "Do not continue after STOP."

**Model too verbose?**
- System prompt should trigger file fetch only
- All other instructions go in .asc files
