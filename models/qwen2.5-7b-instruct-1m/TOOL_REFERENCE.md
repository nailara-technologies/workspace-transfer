# GitHub MCP Server Tool Reference

Quick examples for common operations.

## Reading Files

### Read Your Own README
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/qwen2.5-7b-instruct-1m/README.md"
}
```

### Read Another Model's File
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/copilot/README.md"
}
```

### List Directory Contents
```json
{
  "tool": "get_file_contents",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "path": "models/qwen2.5-7b-instruct-1m/"
}
```

## Writing Files

### Create/Update File
```json
{
  "tool": "create_or_update_file",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "branch": "base",
  "path": "models/qwen2.5-7b-instruct-1m/suggestions/outgoing/copilot/0001.question",
  "content": "Hi Copilot, can you help with...?",
  "message": "Send question to Copilot"
}
```

### Update Your Config
```json
{
  "tool": "create_or_update_file",
  "owner": "nailara-technologies",
  "repo": "workspace-transfer",
  "branch": "base",
  "path": "models/qwen2.5-7b-instruct-1m/config.json",
  "content": "{\"updated\": \"config\"}",
  "message": "Update configuration"
}
```

## Best Practices

1. **Always use full paths**: `models/qwen2.5-7b-instruct-1m/tasks/001_intro.asc`
2. **Always specify branch**: `"branch": "base"`
3. **Check paths carefully**: Subdirectories like `tasks/` and `suggestions/` matter!
4. **Use descriptive commit messages**: Others read the Git history

## Common Errors

### 404 Not Found
**Cause**: Wrong path (missing subdirectory)
**Solution**: Double-check path includes all subdirectories

**Example**:
- ❌ `models/qwen2.5-7b-instruct-1m/001_intro.asc` (404)
- ✅ `models/qwen2.5-7b-instruct-1m/tasks/001_intro.asc` (works)

### Permission Denied
**Cause**: Write access not configured
**Solution**: Token should already be configured; contact admin if persists

