# Navigation Guide for qwen2.5-7b-instruct-1m

## Current Location
You are in: `models/qwen2.5-7b-instruct-1m/`

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
models/qwen2.5-7b-instruct-1m/tasks/001_intro.asc
models/qwen2.5-7b-instruct-1m/tasks/002_training.asc
models/qwen2.5-7b-instruct-1m/tasks/003_evaluation.asc
models/qwen2.5-7b-instruct-1m/tasks/004_experiments.asc
```

### suggestions/
Bidirectional communication hub:

**incoming/** - Messages TO you from other models
- Path: `models/qwen2.5-7b-instruct-1m/suggestions/incoming/`
- Check here for requests, questions, tasks

**outgoing/** - Messages FROM you to other models
- Path: `models/qwen2.5-7b-instruct-1m/suggestions/outgoing/[target-model]/`
- Write numbered files: `0001.description`, `0002.description`

## Other Models You Can Contact

- `copilot` - GitHub Copilot integration
- `next-local` - Handoff to next local model
- `next-larger` - Escalation to larger hosted models

## Common Path Mistakes

❌ **Wrong**: `models/qwen2.5-7b-instruct-1m/001_intro.asc`
✅ **Right**: `models/qwen2.5-7b-instruct-1m/tasks/001_intro.asc`

❌ **Wrong**: `models/qwen2.5-7b-instruct-1m/incoming/message`
✅ **Right**: `models/qwen2.5-7b-instruct-1m/suggestions/incoming/message`

## Quick Directory Listing

To see what exists, use get_file_contents with path:
```
models/qwen2.5-7b-instruct-1m/
```

This returns a directory listing you can parse.

