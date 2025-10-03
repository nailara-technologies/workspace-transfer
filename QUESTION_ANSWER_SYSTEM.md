# Question-Answer Out-of-Band Communication System

**Purpose**: Enable asynchronous communication between user and models without interrupting ongoing work.

---

## 🎯 Core Concept

Models work autonomously but may need clarification or user input. Instead of aborting work, questions can be logged and answered out-of-band. Models check for questions/answers at natural checkpoints (commits).

---

## 📁 File-Based Communication

### User Asks Question

**General Question (any model can answer)**:
```bash
echo "How should I prioritize the filesystem vs network work?" > QUESTION
git add QUESTION
git commit -m "User question"
# QUESTION file auto-processed and deleted by git hook
```

**Targeted Question (specific model)**:
```bash
echo "Can you review my Perl code in core/?" > QUESTION.claude
git add QUESTION.claude  
git commit -m "Question for Claude"
# Logged with target: claude
```

**Urgent Question**:
```bash
echo "URGENT: Stop current work, critical bug found in BMW analysis" > QUESTION
git add QUESTION
git commit -m "Urgent question"
# Logged with URGENT priority
```

### User Provides Answer

When a model asks a question (logged in QUESTIONS.log), user responds:

```bash
echo "Prioritize filesystem integration first, network can wait" > ANSWER
git add ANSWER
git commit -m "Answer to model question"
# Matches most recent pending question, marks as answered
```

---

## 📋 Question Logging

### QUESTIONS.log (Pending)

Contains unanswered questions from models or flagged user questions:

```
[2025-10-03 10:30:45] PENDING | claude | PRIORITY:NORMAL | Should I optimize for speed or clarity?
[2025-10-03 10:35:12] PENDING | qwen2.5-7b-instruct-1m | PRIORITY:URGENT | Conflicting requirements in spec
```

### QUESTIONS_ANSWERED.log (Archive)

Contains answered questions with both Q and A:

```
[2025-10-03 10:40:00] ANSWERED | claude | PRIORITY:NORMAL
  Q: Should I optimize for speed or clarity?
  A: Clarity first, then optimize hot paths

[2025-10-03 10:45:30] ANSWERED | qwen2.5-7b-instruct-1m | PRIORITY:URGENT
  Q: Conflicting requirements in spec
  A: Use approach from section 3.2, ignore outdated section 1.5
```

---

## 🔄 Workflow

### For Models (Claude, qwen, etc.)

1. **Work normally** on current task
2. **Before commits**, check if questions pending:
   ```bash
   perl question-answer-system.pl --show
   ```
3. **If urgent questions**, handle immediately:
   - Save current work state
   - Address urgent question
   - Log follow-up if needed
   - Resume or pivot based on answer
4. **If normal questions**, decide:
   - Continue work and answer later
   - Pause to clarify now
   - Log own question for user
5. **After commits**, git hook auto-checks for new QUESTION/ANSWER files

### For User

**To Ask Question**:
```bash
echo "Your question here" > QUESTION          # General
echo "Your question here" > QUESTION.claude   # Specific model
git add QUESTION* && git commit -m "Question" && git push
```

**To Answer Question**:
```bash
# First, see pending questions
perl question-answer-system.pl --show

# Then provide answer
echo "Your answer here" > ANSWER
git add ANSWER && git commit -m "Answer" && git push
```

**To Check Status**:
```bash
perl question-answer-system.pl --show    # See pending
cat QUESTIONS_ANSWERED.log               # See history
```

---

## 🛠️ Commands

### question-answer-system.pl

```bash
# Check for QUESTION/ANSWER files and process them
perl question-answer-system.pl --check

# Show pending questions
perl question-answer-system.pl --show

# Log a question from model
perl question-answer-system.pl --log "question text" --target claude --priority URGENT

# View answered archive
perl question-answer-system.pl --archive

# Full status report
perl question-answer-system.pl --status
```

---

## 🎨 Use Cases

### Use Case 1: Model Needs Clarification

**Model** (in work):
```perl
# Model realizes ambiguity in requirements
system('perl question-answer-system.pl --log "Section 3.2 conflicts with 1.5 - which to follow?" --priority URGENT');

# Save current state
git_commit("Save work before pausing for clarification");

# Continue or wait based on priority
```

**User**:
```bash
# See pending question
perl question-answer-system.pl --show

# Provide answer
echo "Follow section 3.2, section 1.5 is outdated" > ANSWER
git add ANSWER && git commit -m "Clarification" && git push
```

**Model** (next session or after commit):
```bash
# Git hook shows: "Answer received!"
# Read answer, proceed with section 3.2
```

### Use Case 2: User Wants to Redirect

**User** (model working on task A):
```bash
echo "URGENT: Stop task A, critical bug in task B needs immediate attention" > QUESTION
git add QUESTION && git commit -m "Redirect to bug" && git push
```

**Model** (after commit):
```bash
# Git hook detects urgent question
# Model sees: "URGENT: Stop task A..."
# Saves task A state
# Switches to task B
```

### Use Case 3: Async Feedback Loop

**Model**:
```perl
# Model completes work
system('perl question-answer-system.pl --log "Filesystem integration complete - review before network phase?"');
git_commit("Complete filesystem integration");
```

**User** (later):
```bash
# Reviews work
# Provides feedback
echo "Looks good! Proceed with network phase. Consider adding error handling in mount.pl:42" > ANSWER
git add ANSWER && git commit -m "Approve + feedback" && git push
```

**Model** (next session):
```bash
# Sees approval
# Notes feedback about error handling
# Proceeds to network phase
```

---

## 🔐 Protocol-7 Integration

### Core Principles

**Non-Destructive**:
- Questions logged, never lost
- Answers archived permanently
- Complete conversation history

**Resumable**:
- Models save state before handling urgent questions
- Can resume from any point
- Git commits provide checkpoints

**Verifiable**:
- All Q&A in git history
- Timestamped and auditable
- Clear attribution

**Asynchronous**:
- Non-blocking communication
- Models choose when to respond
- Natural workflow integration

**Harmonic**:
- Git hooks provide rhythm
- Out-of-band doesn't interrupt flow
- Self-organizing priority handling

---

## 📊 Benefits

### For Models

- ✅ **Autonomy**: Don't stop for every question
- ✅ **Context**: See question history
- ✅ **Flexibility**: Choose when to respond
- ✅ **Safety**: Save state before pivoting

### For Users

- ✅ **Non-Blocking**: Don't interrupt ongoing work
- ✅ **Persistent**: Questions never lost
- ✅ **Targeted**: Can ask specific models
- ✅ **Urgent Handling**: Flag critical questions

### For Collaboration

- ✅ **Async**: Time-zone independent
- ✅ **Multi-Model**: Each handles their questions
- ✅ **Archived**: Complete communication history
- ✅ **Git-Native**: Uses existing infrastructure

---

## 🚀 Advanced Features

### Priority Levels

- **URGENT**: Model should pause current work
- **NORMAL**: Model handles at next checkpoint
- **LOW**: Model handles when convenient

### Targeting

- `QUESTION` - Any model can answer
- `QUESTION.claude` - Specifically for Claude
- `QUESTION.qwen2.5-7b-instruct-1m` - For qwen model
- `QUESTION.copilot` - For Copilot

### Chaining

Questions can reference previous Q&A:
```bash
echo "Follow-up to previous answer about section 3.2: Should we also update docs?" > QUESTION
```

---

## 🎯 Best Practices

### For Models

1. **Check before commits**: `perl question-answer-system.pl --show`
2. **Save state for urgent**: Don't lose work
3. **Log own questions**: Don't assume, ask
4. **Reference context**: Mention what you're working on

### For Users

1. **Be specific**: Clear questions get clear answers
2. **Use URGENT sparingly**: Reserve for actual emergencies
3. **Target when needed**: Use QUESTION.<model> for specific expertise
4. **Provide context**: Reference files, line numbers, etc.

---

## 📝 File Locations

- `QUESTIONS.log` - Pending questions (at repo root)
- `QUESTIONS_ANSWERED.log` - Answered archive (at repo root)
- `QUESTION` or `QUESTION.<model>` - Temporary (auto-deleted)
- `ANSWER` - Temporary (auto-deleted)
- `.git/hooks/post-commit` - Git hook (auto-checks)
- `question-answer-system.pl` - System script

---

## 🔄 Integration with Models

Models should integrate this check at natural points:

```perl
# Before major commits
system('perl question-answer-system.pl --check');

# Show any pending for this model
system('perl question-answer-system.pl --show --target $MODEL_NAME');

# If urgent questions exist, handle them
if (urgent_questions_pending()) {
    save_current_state();
    handle_urgent_questions();
    decide_next_action();
}
```

---

**Status**: ✅ Operational  
**Integration**: Git post-commit hook  
**Protocol-7**: Fully aligned

---

*"Questions are signals. Answers are harmonics. Communication is the protocol."*
