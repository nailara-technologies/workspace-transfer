# Tasks Directory

## Purpose

Compressed, token-efficient task tracking for workspace-transfer development.

---

## Files

### `active.yaml`
**Current active tasks** organized by priority (high/medium/low/blocked)

**Size**: <500 tokens (75% more efficient than traditional task lists)

**Update frequency**: On every task status change

**Format**:
```yaml
high_priority:
  - id: "fs_001"
    name: "Implement FUSE filesystem mount"
    status: "in_progress"
    assignee: "claude-code"
    progress: "60%"
    blocker: null
    detail: "See documentation/tasks/fs_001_fuse_mount.md"
```

---

## Usage

### View Active Tasks
```bash
cat tasks/active.yaml
```

### Add New Task
```bash
# Edit tasks/active.yaml
# Copy quick_add_template
# Fill in details
# Commit: git commit -m "task: Add [task_id] - [brief description]"
```

### Update Task Status
```bash
# Edit tasks/active.yaml
# Change status field
# Update progress %
# Commit: git commit -m "task: Update [task_id] to [status]"
```

### Complete Task
```bash
# Move task details to archive/[category]/
# Update active.yaml: increment completed_summary.total
# Remove task from priority list
# Commit: git commit -m "task: Complete [task_id] - [accomplishment]"
```

---

## Task States

| State | Meaning |
|-------|---------|
| `pending` | Defined but not started |
| `in_progress` | Actively being worked on |
| `review` | Complete, awaiting review |
| `blocked` | Cannot proceed due to dependency |
| `completed` | Done - moved to archive |

---

## Task Categories

| Prefix | Category |
|--------|----------|
| `fs` | Filesystem integration |
| `net` | Network protocol |
| `learn` | Learning system |
| `arch` | Archive system |
| `cmd` | Workspace commands |
| `doc` | Documentation |
| `infra` | Infrastructure/tooling |

---

## Detailed Task Specifications

For complex tasks, create detailed spec files in:
```
documentation/tasks/[task_id]_[task_name].md
```

Then reference from active.yaml:
```yaml
detail: "See documentation/tasks/fs_001_fuse_mount.md"
```

---

## Archive Policy

**When to archive**:
- Task status changes to "completed"
- Within 24 hours of completion

**Where to archive**:
```
archive/[category]/
```

**What to keep in active.yaml**:
```yaml
completed_summary:
  total: 47
  by_category:
    fs: 5
    net: 8
    # ... etc
```

---

## Token Efficiency

### Old Approach (CURRENT_FOCUS.md)
```markdown
### 1. Filesystem Integration 🗂️
**Priority**: HIGH
**Status**: Not started

**Objective**: Mount Living Tree filesystem with BASE32 validation

**Key Requirements**:
- FUSE filesystem implementation
- BASE32 path validation
- Harmonic directory structure
...
```
**Cost**: ~500 tokens per task × 4 tasks = ~2000 tokens

### New Approach (active.yaml)
```yaml
high_priority:
  - id: "fs_001"
    name: "FUSE filesystem mount"
    status: "pending"
    detail: "See CURRENT_FOCUS.md:L32-L50"
```
**Cost**: ~125 tokens per task × 4 tasks = ~500 tokens

**Savings**: 75% reduction

---

## Relationship with CURRENT_FOCUS.md

**CURRENT_FOCUS.md**:
- Comprehensive overview
- Detailed requirements and context
- Full documentation
- Update: When priorities shift significantly

**tasks/active.yaml**:
- Lightweight active task list
- Quick status overview
- Points to CURRENT_FOCUS.md for details
- Update: On every task status change

**Best practice**: Keep both in sync
- CURRENT_FOCUS.md = "What and why"
- tasks/active.yaml = "Status and who"

---

## Integration with Handover System

When creating handover files, reference active tasks:

```yaml
# In session-handover-template.yaml
context_summary:
  task: "Working on fs_001: FUSE filesystem mount"

  progress: |
    - Completed fs_001 design
    - Started implementation (60%)

next_steps:
    - "[ ] Complete fs_001 implementation"
    - "[ ] Update tasks/active.yaml: fs_001 status to 'review'"
    - "[ ] Start fs_002: BASE32 path validation"
```

---

## Maintenance

### Weekly Review
```bash
# Check for stale tasks
# Update progress estimates
# Verify blockers are still valid
# Archive completed tasks
```

### Monthly Cleanup
```bash
# Review completed_summary
# Ensure archive is organized
# Update category definitions if needed
# Check for tasks stuck in "in_progress" >30 days
```

---

## Example Workflow

### Starting New Work

```bash
# 1. Check active tasks
cat tasks/active.yaml

# 2. Pick highest priority pending task
# Example: fs_001

# 3. Update status
vim tasks/active.yaml
# Change status to "in_progress"
# Set assignee to your name

# 4. Commit
git commit -m "task: Start fs_001 - FUSE filesystem mount"

# 5. Do the work...

# 6. Update progress periodically
vim tasks/active.yaml
# Change progress: "30%" → "60%"
git commit -m "task: fs_001 progress 60% - Core implementation complete"
```

### Completing Work

```bash
# 1. Move detailed notes to archive
mkdir -p archive/filesystem/
cat > archive/filesystem/fs_001_fuse_mount.md << 'EOF'
# FS_001: FUSE Filesystem Mount

## Completion Summary
...
EOF

# 2. Update active.yaml
vim tasks/active.yaml
# Remove fs_001 from high_priority
# Increment completed_summary.by_category.fs
# Increment completed_summary.total

# 3. Commit
git commit -m "task: Complete fs_001 - FUSE filesystem implemented and tested"

# 4. Push
git push origin base
```

---

## Tips for Token Efficiency

✅ **DO**:
- Keep task names brief (5-8 words)
- Use detail field to reference full specs
- Update status frequently (shows progress)
- Archive completed tasks immediately

❌ **DON'T**:
- Embed full requirements in active.yaml
- Keep completed tasks in priority lists
- Create tasks without unique IDs
- Leave tasks in "in_progress" indefinitely

---

**Estimated Load Time**: <500 tokens for all active tasks
**Update Frequency**: On every status change
**Archive When**: Within 24 hours of completion
