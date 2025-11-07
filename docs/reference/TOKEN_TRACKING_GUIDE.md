# Token Tracking & Self-Optimization Guide

**Self-optimizing best practice system for compound efficiency**

The token tracking system provides proactive efficiency coaching that doesn't require the model to remember policies - the scripts remember for you.

---

## Philosophy

**Problem**: Models have finite context and are stateless across sessions. Relying on model memory for best practices isn't sustainable.

**Solution**: Offload policy enforcement to scripts. The model just needs to:
1. Call tracking commands
2. Read the output
3. Act on suggestions

---

## Core Tools

### 1. Track Token Usage

```bash
bin/track-tokens <task> <tokens>
```

**What it does**:
- Logs token usage to `.token-stats.log`
- Calculates running statistics (mean, median, stddev)
- Detects anomalies (>2σ from mean)
- **NEW**: Provides positive reinforcement on improvements
- **NEW**: Suggests session handovers at efficient points

**Examples**:

```bash
# After initialization
bin/track-tokens init 2400

# After development work
bin/track-tokens development 8500

# Silent mode (no output)
bin/track-tokens onboarding 15000 --silent
```

**Output (normal)**:
```
📊 Token Usage Tracked
Task: init
Tokens: 2300

Historical Stats (n=3):
  Mean:   2367 tokens
  ...

✅ Normal range
```

**Output (improvement)**:
```
✅ EFFICIENCY IMPROVEMENT DETECTED!
   Current: 1800 tokens (-37.5% from baseline)

   Excellent work! This optimization will compound:
   - Over 10 sessions:  ~10,800 tokens saved
   - Over 100 sessions: ~108,000 tokens saved

   💡 Keep this pattern for future similar tasks.
```

**Output (anomaly)**:
```
⚠️  ANOMALY DETECTED!
   This usage is 112.8% above average
   Threshold: 2608 tokens

   Review for inefficiency:
   - Unnecessary file exploration?
   - Verbose output?
   - Repeated documentation reading?
   - Missing optimization opportunities?
```

---

### 2. Session Handover Suggestions

```bash
bin/suggest-handover [--session-tokens <N>]
```

**What it does**:
- Evaluates current session health
- **Detects context efficiency degradation** (same tasks costing more tokens)
- Suggests handovers at natural checkpoints
- Exit code 1 = handover recommended

**Detection Logic**:
1. **Token limits**: 70k (soft), 100k (hard)
2. **Natural checkpoints**: After commits, transfers, documentation
3. **Efficiency degradation**: Recent tasks using >25% more tokens for same work

**Example usage**:

```bash
bin/suggest-handover --session-tokens 75000
```

**Output (healthy)**:
```
✅ Session context healthy (75,000 tokens used)
   Continue working. Handover suggestion at ~70,000 tokens.
```

**Output (recommended)**:
```
💡 SESSION HANDOVER RECOMMENDED

Current context: ~75,000 tokens used
Optimal handover range: 70k-80k tokens

Reason: Natural checkpoint reached at optimal token range + Context efficiency degrading

Benefits of handing over now:
  ✓ Good stopping point (work completed)
  ✓ Optimal handover range (70k-80k tokens)
  ✓ Fresh session will be more efficient
  ✓ ⚠️  Recent tasks using more tokens for similar work
  ✓ Prevent compounding inefficiency

Suggested actions:
  1. Commit current work
  2. Update STATUS.md with progress
  3. Document blockers or next steps
  4. Start fresh session
```

---

### 3. Session Token Counter

```bash
bin/session-tokens [add|set|get|reset]
```

**What it does**:
- Tracks cumulative tokens in current session
- Auto-suggests handover when adding tokens
- Stores count in `.current-session` (gitignored)

**Examples**:

```bash
# Start new session
bin/session-tokens reset

# Add tokens after a task
bin/session-tokens add 2400

# Check current total
bin/session-tokens get

# Set explicit count
bin/session-tokens set 50000
```

**Auto-suggestion**:
When adding tokens reaches threshold, you'll see:
```
75000

💡 Tip: bin/suggest-handover  # Check if handover recommended
```

---

### 4. View Analytics

```bash
bin/token-report [--summary|--detail|--trends]
```

See full documentation in main README or `bin/token-report --help`.

---

## Workflow Integration

### Recommended Pattern

```bash
# 1. Start new session
bin/session-tokens reset

# 2. Initialize workspace
bin/init
INIT_TOKENS=2400  # Manually count or estimate
bin/track-tokens init $INIT_TOKENS
bin/session-tokens add $INIT_TOKENS

# 3. After each major task
TASK_TOKENS=8500
bin/track-tokens development $TASK_TOKENS
bin/session-tokens add $TASK_TOKENS

# 4. Periodically check session health
bin/suggest-handover

# 5. When handover recommended
git add -A
git commit -m "Work in progress"
bin/session-tokens reset
# Start fresh session
```

---

## Self-Optimizing Features

### 1. Positive Reinforcement

When efficiency improves (>15% below baseline), you get:
- Recognition of the improvement
- Compound savings projection
- Encouragement to maintain pattern

**Why this matters**: Models don't need to track "am I doing well?" - the script tells them.

### 2. Anomaly Alerts

When usage spikes (>2σ above mean), you get:
- Alert with specific threshold
- Checklist of common inefficiencies
- Immediate feedback

**Why this matters**: Catch regressions early, before they cost thousands of tokens.

### 3. Context Efficiency Monitoring

When same tasks start costing more tokens:
- Detects degradation trend (>25% increase)
- Suggests handover to restore efficiency
- Prevents compounding inefficiency

**Why this matters**: Even at 60k tokens, if context is "polluted", handover saves future token cost.

### 4. Checkpoint Detection

Recognizes natural stopping points:
- After commits
- After transfers
- After documentation updates
- After refactoring

**Why this matters**: Model doesn't need to remember "is this a good stopping point?" - script knows.

---

## Context Efficiency Degradation

**What it detects**:

Early in session:
```
init: 2400 tokens
development: 8500 tokens
init: 2300 tokens
```

Later in session (degraded):
```
init: 3200 tokens  ← Same task, more tokens
development: 11000 tokens  ← Same task, more tokens
init: 3500 tokens  ← Trend continuing
```

**Calculation**:
- Compare early vs. late averages per task type
- If late average >25% higher → degradation detected
- Works even when total tokens < normal handover point

**Why this happens**:
- Context filled with irrelevant information
- Model has to "work harder" to extract relevant bits
- Each response costs more tokens for same value
- Efficiency compounds downward

**Solution**: Hand over earlier than normal to restore efficiency.

---

## Best Practices (Built Into Scripts)

### Threshold Policy

- **40k tokens**: Check for efficiency degradation
- **70k tokens**: Suggest handover at checkpoints
- **100k tokens**: Strongly recommend handover

### Efficiency Criteria

- **>15% improvement**: Celebrate and project savings
- **>25% degradation**: Suggest handover
- **>2σ anomaly**: Alert immediately

### Checkpoint Recognition

- Commits = natural stopping point
- Transfers = work packaged for protocol-7
- Documentation = knowledge captured
- Refactoring = codebase improved

---

## Anti-Patterns (Automatically Detected)

### 1. Token Creep
**Symptom**: Same task trending upward (2.4k → 2.8k → 3.2k)
**Detection**: Trends report shows upward trend >20%
**Solution**: Script suggests reviewing workflow

### 2. Context Pollution
**Symptom**: Later tasks cost more than earlier identical tasks
**Detection**: Efficiency degradation algorithm
**Solution**: Script recommends handover

### 3. Over-Extended Sessions
**Symptom**: Session exceeds 100k tokens
**Detection**: Hard limit check
**Solution**: Script strongly recommends handover

---

## Example Session

```bash
# Session start
$ bin/session-tokens reset
Session tokens reset to 0

# Init workspace
$ bin/init
# ... output ...

$ bin/track-tokens init 2400
✅ Normal range (first measurement)

$ bin/session-tokens add 2400
2400

# Do some work
$ bin/track-tokens development 8500
✅ Normal range

$ bin/session-tokens add 8500
10900

# More work...
$ bin/session-tokens add 12000
22900

# ... continue working ...

$ bin/session-tokens get
78000

$ bin/suggest-handover
💡 SESSION HANDOVER RECOMMENDED
# ... suggestions ...

# Hand over
$ git commit -m "WIP: Feature development"
$ bin/session-tokens reset
$ # Start fresh session
```

---

## Future Enhancements

Potential additions:
- Auto-tracking integrated into bin/init
- Real-time token estimation (parse AI responses)
- Per-model efficiency baselines
- Long-term trend analysis
- Efficiency score (compound metric)

---

## Summary

**The model doesn't need to remember**:
- ✅ When to hand over (script suggests)
- ✅ If efficiency is good (script alerts)
- ✅ What thresholds matter (script enforces)
- ✅ Best practice policies (script knows)

**The model just needs to**:
- ✅ Call tracking commands periodically
- ✅ Read the output
- ✅ Act on suggestions
- ✅ Focus on actual work

**Result**: Self-optimizing system that compounds efficiency over time without requiring the model to maintain stateful policy memory.

---

**Version**: 1.1
**Last Updated**: 2025-11-07
**See also**: STATUS.md, README.md
