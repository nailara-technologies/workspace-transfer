# next-larger/ - Handoff to Larger Hosted Models

**Purpose**: Escalation point for tasks requiring larger context windows or more sophisticated reasoning

**Type**: Handoff directory (not an active model workspace)

---

## When to Use next-larger/

### Task Complexity
- Analysis requires larger context window than current model provides
- Complex reasoning beyond current model's capabilities
- Multi-document synthesis across large codebases
- Deep analytical tasks requiring sophisticated inference

### Context Limitations
- Current model's context window insufficient
- Need to process more documents/code simultaneously
- Long conversation history needs preserving

### Sophistication Requirements
- Advanced reasoning patterns needed
- Complex multi-step analysis
- Novel problem-solving approaches
- Creative solution synthesis

---

## How to Handoff

### 1. Create Handoff Document

**File Location**: `models/next-larger/handoff-YYYY-MM-DD-description.md`

**Use Template**: See `handoff-template.md` in this directory

**Required Sections**:
- Context Summary
- Task Description
- Current State/Progress
- Blockers/Challenges
- Expected Deliverables
- References/Links

---

### 2. Document Current State

Include:
- What you've tried so far
- Why it exceeded your capabilities
- What insights you've gained
- What questions remain

**Be Specific**: Help the larger model understand context without re-discovering everything

---

### 3. Set Clear Expectations

Define:
- What deliverables are needed
- Where to place results
- Who to coordinate with after completion
- Any time constraints

---

## Handoff Format

### Recommended Structure

```markdown
# Handoff: [Brief Description]

**Date**: YYYY-MM-DD
**From**: [Your Model Name]
**To**: next-larger (any larger hosted model)
**Priority**: HIGH/MEDIUM/LOW

---

## Context Summary
[2-3 paragraphs explaining the situation]

## Task Description
[Specific task that needs larger model]

## Current State/Progress
- What's been done
- Current understanding
- Partial solutions

## Blockers/Challenges
- Why this needs a larger model
- Specific limitations encountered
- Complexity factors

## Expected Deliverables
1. [Specific output needed]
2. [Format requirements]
3. [Where to place results]

## References/Links
- [Relevant files]
- [Documentation]
- [Previous work]

---

**Handoff Status**: Ready for pickup
```

---

## After Handoff

### For Originating Model
1. Update your status.md with handoff note
2. Document in session log (if applicable)
3. Monitor for responses in:
   - This directory (responses/)
   - Your suggestions/incoming/
   - Git commits

### For Receiving Model
1. Read handoff document thoroughly
2. Review references and context
3. Perform analysis/task
4. Place deliverables in specified location
5. Create response document in responses/
6. Update originating model via their suggestions/incoming/

---

## Response Format

**File Location**: `models/next-larger/responses/YYYY-MM-DD-response-to-[original].md`

**Include**:
- Reference to original handoff
- Summary of work performed
- Deliverables location
- Additional findings
- Recommendations for follow-up
- Contact point if questions arise

---

## Example Scenarios

### Scenario 1: Large Codebase Analysis
**From**: claude-code
**Need**: Analyze patterns across 50+ files simultaneously
**Why larger**: Context window limitation
**Deliverable**: Pattern analysis report with recommendations

### Scenario 2: Complex Architecture Design
**From**: copilot
**Need**: Design distributed system with multiple trade-offs
**Why larger**: Requires sophisticated reasoning about interactions
**Deliverable**: Architecture proposal with justifications

### Scenario 3: Multi-Document Research
**From**: qwen
**Need**: Synthesize information from 20+ research papers
**Why larger**: Context and synthesis capability needed
**Deliverable**: Research summary with key findings

---

## Directory Structure

```
next-larger/
├── README.md              # This file
├── .desc                  # Brief description (legacy)
├── handoff-template.md    # Template for handoffs
├── examples/              # Example handoff documents
│   └── ...
├── active/                # Active handoff documents
│   └── handoff-YYYY-MM-DD-*.md
└── responses/             # Responses from larger models
    └── response-YYYY-MM-DD-*.md
```

---

## Best Practices

### Before Handoff
- ✅ Try to solve with current model first
- ✅ Document what you've tried
- ✅ Be specific about limitations
- ✅ Include concrete examples

### During Handoff
- ✅ Use template for consistency
- ✅ Provide complete context
- ✅ Set clear expectations
- ✅ Specify deliverable format

### After Handoff
- ✅ Monitor for responses
- ✅ Integrate learnings
- ✅ Update originating workspace
- ✅ Archive completed handoffs

---

## Handoff Lifecycle

```
1. Identify Need
   ↓
2. Create Handoff Document
   ↓
3. Place in active/
   ↓
4. Larger Model Picks Up
   ↓
5. Work Performed
   ↓
6. Deliverables Created
   ↓
7. Response Document in responses/
   ↓
8. Originating Model Notified
   ↓
9. Archive Handoff (move to archive/)
```

---

## Security Note

⚠️ **This is a PUBLIC repository**

Before creating handoff documents:
- Verify no credentials or private code included
- Sanitize file paths if revealing
- Generalize examples if necessary
- Follow SECURITY_TEMPLATE.md guidelines

---

## Questions & Support

**Unclear about handoff process?**
→ Check examples/ directory
→ Review handoff-template.md
→ Ask in your model's workspace

**Need help with deliverables?**
→ Specify format clearly in handoff
→ Provide examples if possible
→ Reference existing work

**Handoff not picked up?**
→ Verify handoff document is complete
→ Check active/ directory is correct
→ Consider posting GitHub issue

---

**Directory Status**: ✅ Active handoff point
**Purpose**: Escalation to larger hosted models
**Workflow**: Document → Active → Work → Response → Archive
**Security**: Public repository - sanitize all content
