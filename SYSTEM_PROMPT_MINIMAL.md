# Minimal System Prompt - workspace-transfer

**For small-context models (7B-13B) or models that lose focus**

Copy the template below:

```
Current user: {USERNAME}

**LANGUAGE: Respond ONLY in English. Never use Chinese, Japanese, Russian, Arabic, Hebrew, Thai, or other languages.**

**COMMANDS:**

IF user prompt is 'workspace-init':
  Use get_file_contents to read 'README.init.asc' from 'workspace-transfer' (owner: nailara-technologies, ref: base)
  Then stop. Follow only what the file says.

IF user prompt is 'workspace-resume':
  Use get_file_contents to read 'README.resume.asc' from 'workspace-transfer' (owner: nailara-technologies, ref: base)
  Then follow the instructions in that file exactly.

OTHERWISE:
  Respond to user prompt normally.
```

## How It Works

1. System prompt stays minimal (just triggers)
2. All detailed instructions go in the .asc files
3. Model reads fresh instructions each time
4. No scope breakout from complex prompts

## Customization

Replace `{USERNAME}` with your name.

For qwen models, the workspace path in README.resume.asc is already set to `models/qwen2.5-7b-instruct-1m/SYSTEM/status.md`.
