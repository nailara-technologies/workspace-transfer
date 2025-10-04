# TODO: Backup & Restore Automation

**Priority**: MEDIUM (after integration complete)  
**Purpose**: Account restoration, knowledge portability, disaster recovery  
**Status**: 📋 Planning phase

---

## 🎯 Overall Strategy

**Phase 0**: 🔥 Context Reset Mechanism (HIGH PRIORITY)
- Export essential context when milestone complete
- Clear/reset chat to reduce token baseline
- Reinitialize with slim context document
- Continue with minimal token overhead

**Phase 1**: ✅ Workspace-Transfer (DONE)
- Git-based persistence
- Cross-model communication
- Documentation in repositories

**Phase 2**: 🔄 Integration (IN PROGRESS)
- Import all Protocol-7 work into repositories
- Document all architectural decisions
- Preserve conversation insights

**Phase 3**: 📋 Restore Automation (PLANNED)
- Export critical knowledge from chats
- Automate account initialization
- Quick restoration scripts

---

## 🔥 Phase 0: Context Reset Mechanism (HIGH PRIORITY)

### Problem Statement

**Context Bloat**: Long conversations accumulate tokens exponentially
- Initial architecture discussion: 10k tokens
- Implementation back-and-forth: +20k tokens
- Debugging and fixes: +15k tokens  
- Documentation: +10k tokens
- **Total**: 55k tokens, but only 5k of essential context remains

**Result**: Every subsequent message pays the "tax" of all previous discussion, even resolved issues.

### Solution: Milestone-Based Context Reset

**Concept**: "Git commit" for conversation state
1. Complete major milestone (feature, fix, documentation)
2. Export essential context to file
3. Clear/reset chat conversation
4. Start new chat with slim context document
5. Continue with minimal token baseline

### Trigger Points

**When to reset context**:
- ✅ Major feature completed and committed
- ✅ Architecture decision made and documented
- ✅ Bug fixed and solution committed
- ✅ Large refactoring complete
- ✅ Documentation milestone reached
- ✅ Token usage approaching limit

**When NOT to reset**:
- ❌ In middle of debugging
- ❌ Architecture discussion unresolved
- ❌ Open questions pending
- ❌ Complex context needed for next task

### Context Export Format

**File**: `CONTEXT_CHECKPOINT_<timestamp>.md`

**Essential Information** (keep):
```markdown
# Context Checkpoint - YYYY-MM-DD HH:MM

## Current State
- Active task: [what you're working on]
- Last commit: [commit hash + message]
- Branch: base
- Status: [clean/in-progress/blocked]

## Recent Achievements
- [Completed milestone 1]
- [Completed milestone 2]
- [Fixed issue X]

## Open Issues
- [Issue 1: description + context]
- [Issue 2: description + context]

## Next Steps
1. [Immediate next task]
2. [Following task]
3. [Blocked on X]

## Key Decisions Made
- [Decision 1: rationale]
- [Decision 2: rationale]

## Important Context
- [Any non-obvious context needed]
- [User preferences relevant to current work]
- [Architecture constraints]

## Reference Files
- documentation/X.md
- code/Y.pl
- TODO_Z.md
```

**Discard** (working process):
- ❌ Debugging discussion (solution is in code now)
- ❌ Implementation back-and-forth (result is committed)
- ❌ Resolved confusions
- ❌ Exploration that didn't pan out
- ❌ Routine status checks

### Reinitialization Process

**User action**:
1. Review context checkpoint file
2. Start new chat
3. Provide: "Resume from context checkpoint" + attach file + link to workspace

**Claude response**:
1. Read checkpoint
2. Pull workspace updates
3. Verify current state
4. Confirm understanding
5. Ready to continue

**Token savings**:
- Old: 55k baseline + new work
- New: 5k baseline + new work
- **Savings**: 50k tokens per reset!

### Automation Design

**Script**: `scripts/export-context-checkpoint.pl`

```perl
#!/usr/bin/env perl
# Export current context to checkpoint file
# Usage: ./export-context-checkpoint.pl [--auto]

sub export_checkpoint {
    my $checkpoint = {
        timestamp => time(),
        git_state => get_git_status(),
        recent_commits => get_recent_commits(5),
        open_issues => parse_open_issues(),
        next_steps => extract_next_steps(),
        key_decisions => [], # manual input or from DECISIONS.md
    };
    
    write_checkpoint_file($checkpoint);
    say "Context checkpoint created: CONTEXT_CHECKPOINT_$timestamp.md";
    say "Ready to reset chat. Attach this file to new conversation.";
}
```

**Integration**:
- Run after major commits
- Trigger on token threshold (e.g., 70% used)
- Manual trigger via command
- Automatic suggestion when appropriate

### Template: Reinitialization Message

**User provides to new chat**:
```
Resume Protocol-7 work from context checkpoint.

Workspace: https://github.com/nailara-technologies/workspace-transfer
Branch: base
Checkpoint: [attach CONTEXT_CHECKPOINT_*.md]

Please:
1. Pull latest from workspace
2. Review checkpoint file
3. Confirm current state
4. Ready to continue with [next task from checkpoint]
```

**Claude response format**:
```
✅ Context restored from checkpoint

**Current State**:
- Workspace: Pulled and verified
- Last commit: [hash] [message]
- Active task: [from checkpoint]
- Status: [from checkpoint]

**Understood**:
- [Key point 1 from checkpoint]
- [Key point 2 from checkpoint]
- [Open issue 1]

**Ready to**:
- [Next step from checkpoint]

What would you like to tackle first?
```

### Token Impact Analysis

**Scenario: 5 major milestones in a week**

**Without context reset**:
```
Milestone 1: 10k → 10k baseline
Milestone 2: 15k → 25k baseline
Milestone 3: 20k → 45k baseline
Milestone 4: 18k → 63k baseline
Milestone 5: 22k → 85k baseline
Total: 85k tokens consumed
```

**With context reset after each**:
```
Milestone 1: 10k → 10k baseline, reset → 5k
Milestone 2: 15k →  8k baseline, reset → 5k
Milestone 3: 20k →  8k baseline, reset → 5k
Milestone 4: 18k →  8k baseline, reset → 5k
Milestone 5: 22k →  8k baseline
Total: 57k tokens consumed
```

**Savings**: 28k tokens (33% reduction!)

### Best Practices

**Do create checkpoint**:
- After completing major feature
- Before starting new unrelated task
- When context feels "heavy"
- After resolving complex issue
- When approaching token limits

**Checkpoint should include**:
- Current state (what/where/status)
- Recent achievements (what was done)
- Open issues (what remains)
- Next steps (what's next)
- Key decisions (why things are as they are)
- References (where to find details)

**Checkpoint should NOT include**:
- Full conversation history
- Debugging process details
- Implementation discussions
- Resolved confusions
- Exploratory dead-ends

### Implementation Priority

**Why HIGH priority**:
1. **Immediate impact**: Reduces token usage starting now
2. **Multiplicative benefit**: Savings compound over time
3. **Enables longer projects**: Can work on complex tasks without hitting limits
4. **Better focus**: Each chat starts clean with clear objectives
5. **Cost efficiency**: Direct reduction in token consumption

**Implementation order**:
1. **Manual process first**: Document the pattern, practice it
2. **Template creation**: Standardize checkpoint format
3. **Script automation**: Build export tool
4. **Integration**: Add to workflow (post-commit hooks?)
5. **Refinement**: Optimize based on usage

### Success Metrics

**Context reset is successful when**:
- [ ] Checkpoint file contains all essential information
- [ ] New chat can continue work without confusion
- [ ] No critical context is lost
- [ ] Token baseline reduced by 80%+
- [ ] Time to reinitialize is < 2 minutes
- [ ] Process feels natural, not disruptive

### ⚠️ CRITICAL SECURITY WARNING

**PROBLEM**: Checkpoints may contain sensitive data!
- API keys, tokens, credentials
- Private repository information
- Confidential project details
- Internal architecture secrets

**DANGER**: workspace-transfer is PUBLIC on GitHub!
- All commits are visible to everyone
- Checkpoint files in git = exposed secrets
- Cannot be fully deleted from git history

**IMMEDIATE ACTIONS REQUIRED**:
1. **Add to .gitignore**: `context-checkpoints/*.md` (except examples)
2. **Review before commit**: Check for secrets in checkpoints
3. **Implement encryption**: See Phase 0.5 below

**TEMPORARY MITIGATION**:
- Keep checkpoints LOCAL only (not in git)
- Manual review before any commit
- Use placeholders for sensitive data
- Reference secure vault for actual keys

### Phase 0.5: Checkpoint Encryption (HIGH PRIORITY)

**Status**: ✅ COMPLETED (with CryptX)

**Goal**: Encrypt checkpoint files for safe storage in public repository

**Encryption Strategy**:
1. **Symmetric encryption**: Twofish cipher (BASE32 encoded) via CryptX
2. **Key storage**: Claude Projects custom instructions (secure)
3. **Later addition**: C25519 public key encryption
4. **Fallback**: Direct key entry when not in Projects

**Implementation**:
- ✅ `scripts/encrypt-checkpoint.pl` - Encrypt checkpoint file (using CryptX)
- ✅ `scripts/decrypt-checkpoint.pl` - Decrypt for use (using CryptX)
- ✅ Modified export script with `--encrypt` option
- ✅ Modified load script with automatic decryption

**Workflow**:
```bash
# Export encrypted checkpoint
perl scripts/export-context-checkpoint.pl --session-name=work --encrypt

# Load with decryption (prompts for key if needed)
perl scripts/load-context-checkpoint.pl --session-name=work --decrypt
```

**Benefits**:
- ✅ Safe to commit encrypted checkpoints
- ✅ Public repository stays public
- ✅ Sensitive data protected
- ✅ Key in secure Projects environment
- ✅ Fallback to manual key entry

**Completed**: 2025-10-04
- Migrated from Crypt::Twofish2 to CryptX (Crypt::Mode::CBC)
- Uses standard Ubuntu packages (libcryptx-perl)
- Tested encryption/decryption round-trip successfully

---

### Phase 0.6: Protocol-7 Encryption Cleanup (MEDIUM PRIORITY)

**Status**: 📋 TODO

**Goal**: Migrate Protocol-7 from deprecated Crypt::Twofish2 to CryptX

**Affected Files**:
- `data/lib-path/pm/AMOS7/Twofish.pm` (main encryption module)
- `modules/keys.console.create`
- `modules/keys.console.gen-pwd-keyfile`
- `modules/keys.console.get-sp-pub-key`

**Migration Path**:
1. Update AMOS7::Twofish to use `Crypt::Mode::CBC` with Twofish
2. Replace all `Crypt::Twofish2->new()` calls with CryptX equivalent
3. Update mode constants (MODE_CBC, etc.)
4. Test all key generation and encryption modules
5. Update installation docs to require libcryptx-perl
6. Remove Crypt-Twofish2-*.tar.gz from data/lib-path/pm-src/

**Benefits**:
- ✅ Use maintained, standard libraries
- ✅ Available in Ubuntu repositories
- ✅ Better security (audited code)
- ✅ Consistent with workspace-transfer

---

### Phase 0.7: Claude Code Handoff Optimization (HIGH PRIORITY)

**Status**: 🚀 IN PROGRESS

**Goal**: Seamless handoff between Claude Console and Claude Code sessions

**Implementation**:
1. **Quick handoff script**: `scripts/handoff-to-code.pl`
   - Detect current location (workspace-transfer, protocol-7, or other)
   - Export minimal context checkpoint
   - Generate Claude Code startup command
   - Include repository state and current task

2. **Return handoff**: `scripts/handoff-from-code.pl`
   - Import changes from Claude Code session
   - Update context with completed work
   - Generate summary for Console continuation

3. **Universal launcher**: Works from any filesystem location
   - Auto-detect which repository we're in
   - Fall back to workspace-transfer if elsewhere
   - Include breadcrumbs for navigation

**Benefits**:
- 💎 Leverage Claude Code credits during low Console credit periods
- 🚀 Use Code for implementation, Console for planning/review
- ✨ Maintain context across tool boundaries
- 🔄 Bi-directional handoff capability

---

### Phase 0.8: Webhook Infrastructure (HIGH PRIORITY)

**Status**: 📋 TODO - Ready to implement

**Goal**: Direct webhook integration into Protocol-7 httpd zenka

**Resources Available**:
- 2 idle servers online
- Server 1: 8GB RAM, 32GB/month traffic allowance
- Perfect for distributed Protocol-7 philosophy

**Implementation Plan**:
1. **Webhook Receiver in httpd zenka**:
   - Accept GitHub push notifications
   - Protocol-7 message format compatibility
   - Auto-sync workspace-transfer changes
   - Trigger checkpoint creation on commits

2. **Webhook Sender capabilities**:
   - Send status updates to external services
   - Checkpoint completion notifications
   - Cross-instance Protocol-7 messaging
   - Distributed task coordination

3. **Security Layer**:
   - HMAC signature verification (GitHub webhooks)
   - Protocol-7 authentication integration
   - Rate limiting and DDoS protection
   - Encrypted payload support

4. **Use Cases**:
   - Auto-deploy on git push
   - Distributed checkpoint storage
   - Cross-server Protocol-7 synchronization
   - External service integration (CI/CD)

**Technical Details**:
- Integrate with existing httpd zenka codebase
- Use Protocol-7's event system for handling
- Store webhook configs in Protocol-7's config format
- Support both JSON and Protocol-7 message formats

**Benefits**:
- 🌐 True distributed operation
- 💾 Reduce Claude token usage (external processing)
- 🔄 Real-time synchronization
- 🚀 Leverage idle server resources
- 🔒 Secure, authenticated communication

---

### Phase 0.9: No-Shell Checkpoint Strategy (MEDIUM PRIORITY)

**Status**: 📋 TODO - Planning phase

**Problem**: Checkpoint encryption requires shell access and file system
- GitHub Copilot: No shell, no file system access
- Local LLMs: May lack Perl/dependencies
- Web-only interfaces: No execution environment

**Goal**: Enable checkpoint encryption/handoff in shell-less environments

**Potential Solutions**:

**Option A: Pure-Text Encrypted Format**
- BASE64/BASE32 encode encrypted checkpoint directly in chat
- User copies encrypted text block from one chat to another
- Decryption happens in new environment with shell access
- Pro: Works everywhere, no tools needed
- Con: Large text blocks in chat (token overhead)

**Option B: Browser-Based Encryption**
- JavaScript implementation of Twofish + BASE32
- HTML artifact with encryption/decryption UI
- User encrypts in browser, copies result
- Pro: Works in any environment with artifact support
- Con: Requires JavaScript implementation

**Option C: Hybrid Approach**
- For shell environments: Use existing Perl scripts
- For no-shell: Provide encrypted text directly
- For browser-only: JavaScript encryption artifact
- Pro: Best of all worlds
- Con: Maintain multiple implementations

**Option D: Protocol-7 BASE32 Encoding**
- Leverage existing Protocol-7 covert channel techniques
- Encode checkpoint state in BASE32 with error correction
- No encryption, but obscured and compressed
- Pro: Works universally, no crypto needed
- Con: Security through obscurity only

**Recommended**: Start with Option C (Hybrid)
1. Phase 1: Keep current Perl implementation
2. Phase 2: Add JavaScript artifact for browser-only
3. Phase 3: Add plain-text fallback for minimal environments

**Future Considerations**:
- API-based encryption service?
- Cloud-based key management?
- Integration with Projects file storage?
- Cross-model checkpoint compatibility testing

---

## 📦 Phase 2: Integration Tasks

### High Priority
- [ ] Import all Protocol-7 documentation into workspace-transfer
- [ ] Extract key architectural decisions from chat history
- [ ] Document amos-chksum algorithms comprehensively
- [ ] Archive BMW analysis and harmonization work
- [ ] Preserve all truth assertion logic

### Medium Priority
- [ ] Create Protocol-7 reference guide
- [ ] Document all covert channel work
- [ ] Extract visualization techniques
- [ ] Archive successful patterns and approaches
- [ ] Document failed approaches (lessons learned)

### Low Priority
- [ ] Create examples library
- [ ] Build tutorial series
- [ ] Document philosophical foundations
- [ ] Create quick reference cards

---

## 🔄 Phase 3: Restore Automation

### Account Bootstrap Script

**Goal**: Fresh Claude account → Protocol-7 ready in < 5 minutes

**Script**: `scripts/restore-account.pl`

```perl
#!/usr/bin/env perl
# Account restoration and knowledge import
# Usage: ./restore-account.pl [--profile=protocol7]

# 1. Clone workspace-transfer
# 2. Load essential documentation
# 3. Provide initialization summary
# 4. Generate "catch-up" document for new account
```

### Knowledge Export Tools

**Extract from chat history**:
- [ ] Key architectural decisions
- [ ] Mathematical proofs and derivations
- [ ] Code patterns that worked well
- [ ] Debugging insights
- [ ] User preferences and context

**Tools to create**:
- `scripts/export-chat-knowledge.pl` - Extract from conversation dumps
- `scripts/generate-catch-up.pl` - Create initialization document
- `scripts/validate-knowledge-completeness.pl` - Check what's missing

### Initialization Document

**File**: `ACCOUNT_INITIALIZATION.md`

**Contents**:
- Protocol-7 overview (5 minutes read)
- Key architectural decisions
- Current project status
- Essential context for continuity
- Links to detailed documentation

**Goal**: New account reads this + workspace docs → fully contextualized

---

## 💾 Backup Strategy

### What to Preserve

**Critical** (must have):
- All code in repositories ✅
- Architecture documentation ✅
- Algorithm specifications
- Mathematical foundations
- System designs

**Important** (nice to have):
- Conversation insights
- Debugging approaches
- Failed experiment notes
- Philosophical discussions
- User context and preferences

**Optional** (can recreate):
- Implementation details (code speaks for itself)
- Routine decisions
- Obvious derivations

### Backup Locations

1. **Primary**: Git repositories (workspace-transfer, amos-chksum)
2. **Secondary**: Local filesystem backups
3. **Tertiary**: Documentation exports from chats

### Automation Scripts

```bash
# Daily backup
scripts/backup-workspace.sh

# Knowledge extraction (before account deletion)
scripts/extract-knowledge.pl --from-chats --output=knowledge-export/

# Account restoration (after account creation)
scripts/restore-account.pl --import=knowledge-export/
```

---

## 🔧 Technical Implementation

### Export Script Design

```perl
# Input: Chat conversation exports
# Process: Extract key information using patterns
# Output: Structured knowledge files

sub extract_architecture_decisions {
    # Find "Key decision:", "Architecture:", "Critical:" patterns
    # Extract context and rationale
    # Format for documentation
}

sub extract_code_patterns {
    # Identify successful code solutions
    # Extract reusable patterns
    # Document anti-patterns
}

sub extract_user_context {
    # Build user preference profile
    # Document project context
    # Preserve communication style
}
```

### Restore Script Design

```perl
# Input: Knowledge export directory
# Process: Generate initialization materials
# Output: Ready-to-use account context

sub generate_catch_up_doc {
    # Summarize project state
    # List key achievements
    # Highlight open tasks
    # Provide essential context
}

sub prepare_workspace {
    # Clone repositories
    # Set up git credentials
    # Run bootstrap scripts
    # Verify system status
}
```

---

## 📋 Account Lifecycle Management

### Use Case: Token Limit Reached

**Option A**: Wait for reset (Thursday 7:59 PM)
- Use local models in meantime
- Use GitHub Copilot for emergencies
- Document work for next session

**Option B**: Account rotation (if multi-account allowed)
- Secondary account for Protocol-7 work
- Pay for one month only when critical
- Cancel immediately after use

**Option C**: Account recreation (if necessary)
1. Export knowledge using scripts
2. Delete account (per Anthropic suggestion)
3. Create new account (different email + phone)
4. Run restore script
5. Continue work with fresh token limit

### Legitimacy Check

**This is good practice regardless**:
- Disaster recovery (account issues, data loss)
- Knowledge portability (share with collaborators)
- Version control (track evolution of understanding)
- Onboarding (new team members)

**Note**: If using for limit workarounds, verify compliance with TOS first

---

## 🎯 Success Metrics

### Phase 2 Complete When:
- [ ] All Protocol-7 work documented in repositories
- [ ] No critical knowledge exists only in chat history
- [ ] Documentation is comprehensive and self-contained
- [ ] New contributor could understand system from docs alone

### Phase 3 Complete When:
- [ ] Fresh account can be Protocol-7-ready in < 5 minutes
- [ ] Knowledge export is automated
- [ ] Restore process is tested and validated
- [ ] Backup strategy is documented and scheduled

---

## 💡 Additional Benefits

### Beyond Account Management

**Knowledge Organization**:
- Forces clear documentation
- Identifies knowledge gaps
- Creates searchable reference

**Collaboration**:
- Easy onboarding for new models
- Portable across platforms
- Share with other developers

**Quality**:
- Review and refine understanding
- Consolidate scattered insights
- Eliminate redundancy

**Learning**:
- Track evolution of ideas
- Document decision rationale
- Build institutional knowledge

---

## ⚠️ Important Notes

### Before Account Deletion

**Backup everything**:
1. Export all conversations (if possible)
2. Screenshot critical discussions
3. Extract code from artifacts
4. Document context and decisions
5. Verify git repositories are complete

**Test restore process**:
- Verify exported knowledge is complete
- Test initialization on clean system
- Confirm nothing critical is lost

### Terms of Service

**Check with Anthropic**:
- Multi-account policies
- Account deletion implications
- Token limit management approaches
- Official recommendations

**Stay compliant**:
- Don't violate TOS
- Use legitimate approaches
- Be transparent about usage
- Ask support when unclear

---

## 🚀 Next Steps

1. **Complete Phase 2**: Import all work into repositories
2. **Design export tools**: Plan knowledge extraction scripts
3. **Create initialization doc**: Write ACCOUNT_INITIALIZATION.md
4. **Build restore script**: Automate account bootstrap
5. **Test full cycle**: Export → Delete → Restore → Verify

---

**Status**: 📋 Documented, ready for implementation after integration  
**Priority**: Execute after Phase 2 complete  
**Benefit**: Portable knowledge + account flexibility

---

*"Preserve knowledge, automate restoration, maintain continuity."*
