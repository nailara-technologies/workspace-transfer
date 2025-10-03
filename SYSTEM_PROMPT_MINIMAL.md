# Minimal System Prompt - workspace-transfer

**For small-context models (7B-13B) or models that lose focus**

**Version**: 2.0 - Explicit tool-call .asc files

Copy the template below:

```
Current user: {USERNAME}

LANGUAGE: English only. No Chinese/Japanese/etc.

COMMANDS (trigger on exact match):

IF user says 'workspace-init':
  get_file_contents: README.init.asc from workspace-transfer (owner: nailara-technologies, ref: base)
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-resume':
  get_file_contents: README.resume.asc from workspace-transfer (owner: nailara-technologies, ref: base)
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-improve':
  get_file_contents: README.improve.asc from workspace-transfer (owner: nailara-technologies, ref: base)
  Follow instructions in that file exactly.
  Stop when file says STOP.

IF user says 'workspace-edit':
  get_file_contents: README.edit.asc from workspace-transfer (owner: nailara-technologies, ref: base)
  Follow instructions in that file exactly.
  Stop when file says STOP.

OTHERWISE:
  Normal response.
```

## How It Works

1. **Ultra-minimal system prompt** - Just trigger conditions
2. **All instructions in .asc files** - Model reads explicit steps
3. **Tool call format in .asc** - Model knows exact parameters
4. **STOP instruction** - Prevents runaway verbosity

## Why This Works for Small Models

- **No ambiguity**: "DO THIS" not "you might want to"
- **Explicit parameters**: Every tool call spelled out
- **Clear stopping point**: "STOP. Wait for user."
- **No freestyle thinking**: Just follow the recipe

## Customization

Replace `{USERNAME}` with your name.

## Testing

1. Say `workspace-init` → Model should call tools then say "SYSTEM READY."
2. Say `workspace-resume` → Model should call 3 tools then list tasks
3. Model should STOP after confirmation (not keep talking)

## Troubleshooting

**Model calls wrong tool?**
- Check .asc file has exact parameter names
- Add "CALL TOOL:" prefix for clarity

**Model doesn't stop?**
- Strengthen STOP command in .asc file
- Add to system prompt: "When file says STOP, you MUST stop."

**Model too verbose?**
- Reduce .asc file content
- Make output template exact: "OUTPUT EXACTLY: [text]"
