# next-local/ - Handoff to Other Local Models

**Purpose**: Coordination point for handoffs to other local models in constrained or privacy-sensitive environments

**Type**: Handoff directory (not an active model workspace)

---

## When to Use next-local/

### Resource Constraints
- Current model hitting resource limits (memory, CPU, time)
- Need for lighter-weight processing
- Batch operations better suited to different model
- Cost optimization (smaller model sufficient)

### Privacy & Security
- Data cannot leave local environment
- Privacy-sensitive processing required
- Air-gapped or offline operation needed
- Local-only compliance requirements

### Local Model Coordination
- Task better suited to different local model
- Specialized local model needed (coding, analysis, etc.)
- Multi-model local pipeline
- Parallel processing across local models

### Speed & Efficiency
- Task doesn't require large model
- Faster iteration needed
- Real-time processing requirements
- Bandwidth-limited environment

---

## How to Handoff

### 1. Create Handoff Document

**File Location**: `models/next-local/handoff-YYYY-MM-DD-description.md`

**Use Template**: See `handoff-template.md` in this directory

**Required Sections**:
- Context Summary
- Task Description
- Current State/Progress
- Resource/Privacy Requirements
- Expected Deliverables
- Local Model Preferences (if any)

---

### 2. Specify Constraints

Include:
- Resource limitations (memory, time, etc.)
- Privacy/security requirements
- Local-only constraints
- Performance expectations

**Be Clear**: Help next local model understand constraints

---

### 3. Define Success Criteria

Specify:
- What constitutes completion
- Quality/accuracy requirements
- Format of deliverables
- Where to place results

---

## Handoff Format

### Recommended Structure

```markdown
# Local Handoff: [Brief Description]

**Date**: YYYY-MM-DD
**From**: [Your Model Name]
**To**: next-local (any available local model)
**Priority**: HIGH/MEDIUM/LOW
**Constraints**: [Resource/Privacy/Time]

---

## Context Summary
[2-3 paragraphs explaining the situation]

## Task Description
[Specific task for local model]

## Resource/Privacy Requirements
- Memory limit: [if applicable]
- Time constraint: [if applicable]
- Privacy requirement: [local-only, air-gapped, etc.]
- Security needs: [data handling requirements]

## Current State/Progress
- What's been done
- Why handoff to local model
- Available resources

## Expected Deliverables
1. [Specific output needed]
2. [Format requirements]
3. [Where to place results]

## Local Model Preferences
- Preferred model type (if any)
- Required capabilities
- Nice-to-have features

## References/Links
- [Relevant files]
- [Local resources]
- [Previous work]

---

**Handoff Status**: Ready for local model pickup
```

---

## After Handoff

### For Originating Model
1. Update your status.md with handoff note
2. Document resource/privacy constraints
3. Monitor for responses in:
   - This directory (responses/)
   - Your suggestions/incoming/
   - Local coordination files

### For Receiving Local Model
1. Read handoff document
2. Verify resource availability
3. Confirm privacy constraints understood
4. Perform task within constraints
5. Place deliverables locally
6. Create response document in responses/
7. Notify originating model

---

## Response Format

**File Location**: `models/next-local/responses/YYYY-MM-DD-response-to-[original].md`

**Include**:
- Reference to original handoff
- Constraints met confirmation
- Work performed summary
- Deliverables location
- Resource usage (if relevant)
- Recommendations

---

## Example Scenarios

### Scenario 1: Batch Processing
**From**: claude-code
**Need**: Process 1000 files for pattern extraction
**Why local**: Resource-intensive, parallelizable, doesn't need large model
**Constraints**: Memory limit 8GB, complete within 30 minutes
**Deliverable**: CSV with extracted patterns

### Scenario 2: Privacy-Sensitive Analysis
**From**: qwen
**Need**: Analyze proprietary training data
**Why local**: Data cannot leave local environment
**Constraints**: Air-gapped, no external API calls, local storage only
**Deliverable**: Analysis report in local outputs/

### Scenario 3: Quick Iteration
**From**: copilot
**Need**: Fast prototyping of simple algorithm
**Why local**: Don't need sophistication, need speed
**Constraints**: Sub-second response time desired
**Deliverable**: Working code prototype

### Scenario 4: Cost Optimization
**From**: claude-code
**Need**: Simple text transformation across many files
**Why local**: Task doesn't justify large model cost
**Constraints**: Budget-conscious, accuracy > speed
**Deliverable**: Transformed files in specified directory

---

## Directory Structure

```
next-local/
├── README.md              # This file
├── .desc                  # Brief description (legacy)
├── handoff-template.md    # Template for handoffs
├── examples/              # Example handoff documents
│   └── ...
├── active/                # Active handoff documents
│   └── handoff-YYYY-MM-DD-*.md
└── responses/             # Responses from local models
    └── response-YYYY-MM-DD-*.md
```

---

## Best Practices

### Before Handoff
- ✅ Verify task is suitable for local model
- ✅ Document resource/privacy constraints clearly
- ✅ Specify success criteria
- ✅ Include concrete examples

### During Handoff
- ✅ Use template for consistency
- ✅ Provide complete context
- ✅ Set realistic expectations
- ✅ Specify local-only requirements

### After Handoff
- ✅ Monitor for completion
- ✅ Validate deliverables meet constraints
- ✅ Archive completed handoffs
- ✅ Update learnings

---

## Handoff Lifecycle

```
1. Identify Local-Suitable Task
   ↓
2. Document Constraints
   ↓
3. Create Handoff Document
   ↓
4. Place in active/
   ↓
5. Local Model Picks Up
   ↓
6. Work Performed (respecting constraints)
   ↓
7. Deliverables Created Locally
   ↓
8. Response Document in responses/
   ↓
9. Originating Model Notified
   ↓
10. Archive Handoff (move to archive/)
```

---

## Local Model Coordination

### Available Local Models
Check local environment for:
- Smaller language models (7B, 13B, etc.)
- Specialized models (code, analysis, etc.)
- Task-specific models
- Batch processing scripts

### Coordination Patterns
- **File-based**: Write handoff, read response
- **Direct**: If models share environment
- **Queue-based**: If multiple local models available

### Resource Sharing
- Monitor memory usage
- Coordinate CPU allocation
- Share temporary directories
- Manage disk space

---

## Security & Privacy

⚠️ **While repository is PUBLIC, local work may be private**

### Handoff Documents
- Sanitize before committing to repository
- Remove private data, paths, credentials
- Generalize examples
- Document privacy needs without exposing data

### Local Work
- Keep sensitive data in local directories only
- Don't commit outputs if private
- Use .gitignore for local artifacts
- Follow organizational privacy policies

### Air-Gapped Environments
- Handoff documents may need manual transfer
- Results stay local (not committed)
- Coordination via local files only
- Document workflow for reproducibility

---

## Questions & Support

**Unclear about local constraints?**
→ Document what you know
→ Let receiving model ask questions
→ Provide contact method if possible

**Need specific local model?**
→ Specify in handoff preferences
→ Describe required capabilities
→ Provide fallback options

**Handoff not picked up?**
→ Verify local models available
→ Check active/ directory
→ Consider next-larger/ if no local option

---

## Comparison: next-local vs next-larger

| Aspect | next-local | next-larger |
|--------|------------|-------------|
| **Models** | Local, smaller | Hosted, larger |
| **Context** | Limited | Extensive |
| **Privacy** | High (stays local) | Depends on hosting |
| **Cost** | Low (local compute) | Higher (API calls) |
| **Speed** | Fast (no network) | Variable |
| **Sophistication** | Lower | Higher |
| **Use Case** | Batch, privacy, cost | Complex, large context |

---

**Directory Status**: ✅ Active handoff point
**Purpose**: Coordination with other local models
**Workflow**: Document → Active → Local Work → Response → Archive
**Security**: Sanitize handoffs, keep private work local
