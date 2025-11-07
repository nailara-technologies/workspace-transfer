# Context Management System

**Persistent task and research tracking for stateless AI collaboration**

## The Problem

AI models don't retain memory between sessions. Every new session requires:
- Re-explaining what tasks are in progress (~500-1000 tokens)
- Re-discovering research questions (~300-500 tokens)
- Re-establishing context and priorities (~200-500 tokens)

This token tax compounds across sessions, wasting **1-2k tokens per session** just to resume work.

---

## The Solution

Two integrated systems that persist context across sessions:

### 1. **`bin/todo`** - Persistent Task Management
Track tasks with priorities, status, and context. Never re-explain work in progress.

### 2. **`bin/research`** - Research Question Tracking
Defer investigations to keep current context focused. Batch research into dedicated sessions.

---

## `bin/todo` - Task Management

### Philosophy

Tasks persist across sessions. Models should never spend tokens re-explaining "what I was working on."

Instead:
- Add tasks as you discover them
- Mark progress as you work
- Archive when complete
- Resume next session from persistent state

### Quick Start

```bash
# Add tasks
bin/todo add "Implement filesystem integration" high
bin/todo add "Fix resonant pair bug" critical
bin/todo add "Update documentation" low

# List tasks
bin/todo list              # All tasks
bin/todo list critical     # Filter by priority
bin/todo list pending      # Filter by status

# Work on tasks
bin/todo done t-20251107-010000

# Manage priorities
bin/todo prioritize t-20251107-010001 high
bin/todo defer t-20251107-010002

# Clean up
bin/todo archive           # Archive completed tasks
```

### Priority Levels

| Priority | Emoji | Meaning | Use When |
|----------|-------|---------|----------|
| `critical` | 🔴 | Blocking work | Must do now, nothing else works |
| `high` | 🟠 | Important | Do soon, significant impact |
| `medium` | 🟡 | Normal | Default priority, standard work |
| `low` | 🟢 | Nice to have | When time permits |
| `deferred` | ⚪ | Maybe later | Explicitly postponed |

### All Commands

```bash
bin/todo add "<content>" [priority]    # Add new todo
bin/todo list [filter]                 # List todos
bin/todo done <id>                     # Mark complete
bin/todo defer <id>                    # Defer (low priority)
bin/todo prioritize <id> <priority>    # Change priority
bin/todo archive                       # Archive completed
bin/todo show <id>                     # Show details
bin/todo rm <id>                       # Delete todo
bin/todo help                          # Show help
```

### Files

- `.todos/active.yaml` - Active todos (local only, gitignored)
- `.todos/archive/YYYY-MM-DD.yaml` - Archived completed todos

---

## `bin/research` - Question Tracking

### Philosophy

Questions arise during work:
- "How does this algorithm work?"
- "Should we use approach A or B?"
- "What's the performance impact?"

**Don't investigate immediately** - this bloats context with tangential exploration.

Instead:
- Track the question
- Continue focused work
- Investigate in dedicated research session
- Answer informs future work or creates todos

### Quick Start

```bash
# Track questions as they arise
bin/research ask "How does resonant pair generation work?" high
bin/research ask "Compare SQLite vs PostgreSQL for metrics" medium

# List pending questions
bin/research list
bin/research list blocking    # Filter by priority

# Answer in dedicated session
bin/research show r-20251107-010000
# ... investigate ...
bin/research answer r-20251107-010000 "Uses BMW pattern matching with cubic space"

# Clean up
bin/research archive          # Archive answered questions
```

### Priority Levels

| Priority | Emoji | Meaning | Use When |
|----------|-------|---------|----------|
| `blocking` | 🔴 | Blocks current work | Must answer to proceed |
| `high` | 🟠 | Important context | Answer soon to inform decisions |
| `medium` | 🟡 | Normal curiosity | Useful to know (default) |
| `low` | 🟢 | Eventually | Nice to understand someday |

### All Commands

```bash
bin/research ask "<question>" [priority]  # Add research question
bin/research list [filter]                # List questions
bin/research answer <id> ["answer"]       # Mark answered
bin/research defer <id>                   # Defer (low priority)
bin/research prioritize <id> <priority>   # Change priority
bin/research archive                      # Archive answered
bin/research show <id>                    # Show details
bin/research rm <id>                      # Delete question
bin/research help                         # Show help
```

### Files

- `.research/questions.yaml` - Active questions (local only, gitignored)
- `.research/answered/YYYY-MM-DD.yaml` - Archived answered questions

---

## Integration with Status Automation

Both systems integrate with `.user/CURRENT`:

```bash
$ cat .user/CURRENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CURRENT ACTIVITY
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Branch: base
📝 Uncommitted changes: 3 files

Recent commits:
   abc1234 feat: Implement context management system
   def5678 refactor: Optimize token tracking

📋 Todos: 3 pending (1 critical, 2 high)
   💡 bin/todo list

🔬 Research: 2 pending (1 blocking, 1 high)
   💡 bin/research list

💾 Session tokens: 45,000

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

This gives you immediate visibility into:
- What tasks are pending
- What questions need answers
- Current priorities

---

## Token Savings

### Per Session Resume

**Without context management**:
- Explain current tasks: ~500-1000 tokens
- Rediscover research questions: ~300-500 tokens
- Re-establish context: ~200-500 tokens
- **Total**: ~1-2k tokens

**With context management**:
- Read `.user/CURRENT`: ~100-200 tokens
- Run `bin/todo list`: ~50-100 tokens
- Run `bin/research list`: ~50-100 tokens
- **Total**: ~200-400 tokens

**Savings per session**: ~1-1.6k tokens (80-85% reduction)

### Compound Savings

Over 100 sessions: **~100k-160k tokens saved**

---

## Workflow Patterns

### Pattern 1: Feature Development

```bash
# Start feature
bin/todo add "Implement user authentication" high
bin/todo add "Add JWT token validation" high
bin/todo add "Create login endpoint" medium

# Work on tasks
bin/todo list
# ... implement authentication ...
bin/todo done t-20251107-010000

# Question arises mid-work
bin/research ask "Should we use RS256 or HS256 for JWT?" blocking

# Continue focused work (don't investigate JWT now)
# ... complete login endpoint ...
bin/todo done t-20251107-010002

# Later: dedicated research session
bin/research show r-20251107-010100
# ... investigate JWT algorithms ...
bin/research answer r-20251107-010100 "Use RS256 for better security"

# Research informs new todo
bin/todo add "Implement RS256 JWT signing" high

# Archive when done
bin/todo archive
bin/research archive
```

### Pattern 2: Bug Investigation

```bash
# Track bug
bin/todo add "Fix memory leak in resonant pair generation" critical

# Questions arise during investigation
bin/research ask "How does current memory allocation work?" high
bin/research ask "What's the expected memory usage pattern?" medium

# Continue debugging (defer deep dives)
# ... fix immediate issue ...
bin/todo done t-20251107-020000

# Answer questions to prevent future bugs
bin/research answer r-20251107-020100 "Uses pool allocator with 1MB chunks"
bin/todo add "Document memory allocation patterns" low

# Clean up
bin/todo archive
bin/research archive
```

### Pattern 3: Session Handover

```bash
# End of current session
bin/todo add "Continue filesystem integration - implement FUSE callbacks" high
bin/research ask "Should we use async or sync FUSE operations?" high

# Commit work in progress
git add -A
git commit -m "WIP: Filesystem integration - FUSE skeleton complete"
bin/push-to-base

# Next session - instant resume
cat .user/CURRENT     # See pending todos and research
bin/todo list         # Full task context
bin/research list     # Pending questions

# No re-explanation needed - just continue
```

---

## Best Practices

### 1. **Add tasks immediately**
Don't try to remember - add todos as you discover work:
```bash
bin/todo add "Update API documentation" low
```

### 2. **Track questions, don't investigate**
When curiosity strikes mid-work, track it instead of exploring:
```bash
bin/research ask "Why is this algorithm O(n²)?" medium
# Continue focused work
```

### 3. **Use priorities meaningfully**
- `critical` = blocks everything
- `high` = important, do soon
- `medium` = normal work
- `low` = nice to have
- `deferred` = explicitly postponed

### 4. **Archive regularly**
Don't let completed items accumulate:
```bash
bin/todo archive
bin/research archive
```

### 5. **Reference in handovers**
When handing off to next session:
```bash
git commit -m "WIP: See bin/todo list for pending work"
```

### 6. **Batch research**
Dedicate sessions to answering grouped questions:
```bash
bin/research list blocking   # Answer blocking questions first
bin/research list high        # Then high priority
```

---

## Integration with Other Systems

### Token Tracking

```bash
bin/track-tokens "answering research questions" 3500
bin/session-tokens add 3500
```

### Status Automation

Todos and research automatically appear in `.user/CURRENT` after every update.

### Session Planning

```bash
# Planning session
bin/todo list critical        # What blocks us?
bin/research list blocking    # What questions block us?

# Development session
bin/todo list high           # What's important to build?

# Research session
bin/research list            # What to investigate?
```

---

## Technical Details

### Data Format

Both systems use YAML for human-readable persistence:

```yaml
# .todos/active.yaml
todos:
  - id: t-20251107-012345
    content: "Implement filesystem integration"
    priority: high
    status: pending
    created: 1699315425
    branch: base
```

```yaml
# .research/questions.yaml
questions:
  - id: r-20251107-012345
    question: "How does resonant pair generation work?"
    priority: high
    status: pending
    created: 1699315425
    branch: base
    related_files: ["core/resonant.pl", "core/pairs.pl"]
```

### IDs

- Todo IDs: `t-YYYYMMDD-HHMMSS`
- Research IDs: `r-YYYYMMDD-HHMMSS`

Unique within their type, timestamp-based for chronological ordering.

### Context Tracking

Both systems track:
- **Branch**: Which git branch the item was created on
- **Created timestamp**: When it was added
- **Age**: Calculated on display (e.g., "3h 25m")

---

## See Also

- `docs/reference/STATUS_AUTOMATION.md` - Status summary system
- `docs/reference/TOKEN_TRACKING_GUIDE.md` - Token efficiency tracking
- `docs/reference/RECURRING_PATTERNS.md` - Common workflow patterns

---

**Version**: 1.0
**Last Updated**: 2025-11-07
**Estimated Token Savings**: ~80-85% per session resume (~100k-160k over 100 sessions)
