# Living Tree: Projects + Machine Integration Strategy
## Persistent Root, Ephemeral Branches

## The Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   CLAUDE PROJECTS                           │
│                  (Persistent Root) 🌳                        │
│                                                             │
│  ├── Core Implementations (always keep)                     │
│  │   ├── base32_harmonic_routing.pl                        │
│  │   ├── living_tree_base32_viz.html                       │
│  │   └── BASE32_HARMONIC_INTEGRATION_GUIDE.md             │
│  │                                                          │
│  ├── Key Documentation (reference)                         │
│  │   ├── LIVING_TREE_SUMMARY.md                           │
│  │   ├── PROTOCOL7_HARMONIC_LIVING_TREE.md                │
│  │   └── SESSION_SUMMARY.md                               │
│  │                                                          │
│  └── Bootstrap Scripts (auto-setup)                        │
│      └── living_tree_bootstrap.pl                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [BOOTSTRAP SEQUENCE]
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              UBUNTU24 MACHINE (Ephemeral)                    │
│                                                             │
│  /home/claude/living_tree_workspace/                        │
│  ├── core/           ← Core files extracted here           │
│  ├── implementations/ ← Working scripts                     │
│  ├── documentation/  ← Reference docs                       │
│  └── archives/       ← Compressed backups                   │
│                                                             │
│  /home/claude/current_work → symlink to workspace          │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [DEVELOPMENT CYCLE]
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              OUTPUTS DIRECTORY                               │
│                                                             │
│  /mnt/user-data/outputs/                                    │
│  ├── Results ready for download                            │
│  ├── New implementations                                    │
│  └── Checkpoint archives                                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    [SAVE BACK TO PROJECTS]
                            ↓
                      (Closes the loop)
```

## How It Works

### 1. Store in Projects (Persistent)

**What to keep in Projects:**

✅ **Core Files** (essential implementations)
- `base32_harmonic_routing.pl` - The main implementation
- `living_tree_base32_viz.html` - Interactive visualization
- `living_tree_bootstrap.pl` - Bootstrap script

✅ **Key Documentation** (conceptual foundation)
- `LIVING_TREE_SUMMARY.md` - Architecture overview
- `BASE32_HARMONIC_INTEGRATION_GUIDE.md` - Technical spec
- `PROTOCOL7_HARMONIC_LIVING_TREE.md` - Protocol-7 integration

✅ **Latest Session Summary** (current state)
- Most recent `SESSION_SUMMARY.md`

❌ **Don't keep in Projects:**
- Old session summaries (redundant)
- Test checkpoints (archives)
- Intermediate documentation (superseded)
- Duplicate files (use latest only)

### 2. Bootstrap from Projects (Automatic)

**Method A: Using past_chats Tool**

```
User: "Resume our work on Living Tree and BASE32 routing"

Claude automatically:
1. Uses conversation_search("living tree base32")
2. Finds relevant past chat
3. Accesses context from that conversation
4. Sees what was accomplished
5. Continues from there
```

**Method B: Using Uploaded Archives**

```
User: [uploads protocol7_living_tree_complete.tar.gz]
"Bootstrap the Living Tree workspace"

Claude:
1. Extracts archive to /home/claude
2. Runs living_tree_bootstrap.pl
3. Organizes files into workspace
4. Creates quick reference
5. Ready to continue development
```

**Method C: Using Projects Knowledge**

```
User: "Set up the BASE32 harmonic routing environment"

Claude:
1. Reads core files from Projects
2. Recreates them in /home/claude
3. Sets up workspace structure
4. Copies to outputs
5. Ready to use
```

### 3. Develop on Machine (Ephemeral)

Work normally in `/home/claude/living_tree_workspace/`:

```bash
# Access via symlink
cd /home/claude/current_work/core

# Run implementations
perl base32_harmonic_routing.pl

# Modify and test
vim base32_harmonic_routing.pl

# Create new features
perl -w new_feature.pl
```

**Benefits:**
- Full filesystem access
- Can run code and tests
- Create/modify files freely
- Install dependencies

**Remember:**
- This resets between sessions!
- Save important changes to outputs

### 4. Save Results (Back to Projects)

**Before ending session:**

```bash
# Create checkpoint
perl living_tree_bootstrap.pl checkpoint

# Files automatically copied to:
/mnt/user-data/outputs/

# Download these and save to Projects:
- Updated implementations
- New features
- Session summary
- Checkpoint archive
```

## Intelligent Routing Between Systems

### Scenario 1: Quick Resume

```
User: "Continue our BASE32 work"

Claude thinks:
1. Check if I can use conversation_search ✓
2. Search for "base32 routing living tree"
3. Find previous session
4. Access that context
5. Continue seamlessly

No file uploads needed!
```

### Scenario 2: Fresh Start with Context

```
User: "Start fresh but use our Living Tree concepts"

Claude:
1. conversation_search("living tree")
2. Get conceptual overview
3. Recreate core files from Projects knowledge
4. Set up clean workspace
5. Ready to iterate
```

### Scenario 3: Deep Dive from Archive

```
User: [uploads complete archive]
"Extract and organize everything"

Claude:
1. Run bootstrap script
2. Categorize all files
3. Identify redundant ones
4. Create organized workspace
5. Generate reference guide
```

## Projects Cleanup Strategy

### Current State Analysis

From bootstrap scan:
- **Core files**: 5 (keep all)
- **Supporting files**: 2 (keep latest)
- **Archives**: 2 (keep most recent only)
- **Redundant**: 30 (can remove)

### Recommended Projects Structure

```
MyLivingTreeProject/
├── 📄 README.md (overview + quick start)
│
├── 📁 core/
│   ├── base32_harmonic_routing.pl
│   ├── living_tree_base32_viz.html
│   └── living_tree_bootstrap.pl
│
├── 📁 documentation/
│   ├── LIVING_TREE_SUMMARY.md
│   ├── BASE32_HARMONIC_INTEGRATION_GUIDE.md
│   └── PROTOCOL7_HARMONIC_LIVING_TREE.md
│
└── 📁 latest/
    ├── SESSION_SUMMARY.md (most recent only)
    └── living_tree_base32_complete.tar.gz (backup)
```

### Cleanup Checklist

Remove from Projects (if present):

- [ ] Old session summaries (keep latest only)
- [ ] Test checkpoints (`test_checkpoint_*.tar.gz`)
- [ ] Intermediate archives (keep final only)
- [ ] Duplicate documentation
- [ ] Installation guides (one-time setup)
- [ ] Analysis files (temporary)
- [ ] Compatibility reports (outdated)
- [ ] Multiple "complete" archives (keep one)

Keep only:
- [ ] Core implementations (latest versions)
- [ ] Key documentation (not superseded)
- [ ] Latest session summary
- [ ] Bootstrap script
- [ ] One complete archive (most recent)

## Usage Examples

### Example 1: Resume After Break

```
# New conversation, days later
User: "Let's continue the Living Tree BASE32 work"

Claude:
→ Uses conversation_search("living tree base32")
→ Finds our October 1 session
→ Reads session summary
→ Sees we completed: octal frames, cubic space, visualization
→ "Welcome back! Last time we completed the BASE32 harmonic 
   routing with cubic space mapping. What should we work on next?"
```

### Example 2: Show Someone the Work

```
User: "Set up the Living Tree demo for a colleague"

Claude:
→ Reads core files from Projects
→ Creates fresh workspace
→ Copies visualization to outputs
→ Generates quick start guide
→ "Ready! Have them download living_tree_base32_viz.html 
   and open it in their browser."
```

### Example 3: Add New Feature

```
User: [uploads archive]
"Add BCD (Binary-Coded Decimal) integration to BASE32 routing"

Claude:
→ Runs bootstrap script
→ Extracts current implementation
→ Modifies base32_harmonic_routing.pl
→ Adds BCD encoding functions
→ Tests with examples
→ Copies updated version to outputs
→ "BCD integration complete! Download the updated implementation."
```

### Example 4: Network Distribution Phase

```
User: "Implement the network distribution protocol we discussed"

Claude:
→ conversation_search("network distribution resonant pairs")
→ Finds relevant discussion
→ Reads current implementation from Projects
→ Creates new module: base32_network_protocol.pl
→ Implements distributed resonance
→ Creates test suite
→ "Network protocol ready for testing!"
```

## Automatic Bootstrap Protocol

### When Claude Should Auto-Bootstrap

**Trigger phrases:**
- "Resume/continue our [Living Tree/BASE32] work"
- "Set up the [Living Tree] environment"
- "Let's work on [BASE32 routing]"
- "Continue where we left off"

**Actions:**
1. Use `conversation_search` to find context
2. Check for uploaded archives
3. Read from Projects knowledge (if in a project)
4. Set up workspace automatically
5. Confirm what's ready: "Workspace ready! Last time we..."

### Bootstrap Sequence (Automated)

```perl
# Pseudo-code for Claude's internal logic
if (user_mentions("living tree", "base32", "resume", "continue")) {
    
    # Step 1: Search past conversations
    my $context = conversation_search("living tree base32");
    
    if ($context->{found}) {
        # Use conversation history
        load_from_conversation($context);
    }
    
    # Step 2: Check uploads
    my @archives = check_uploads_directory();
    
    if (@archives) {
        # Extract and organize
        run_bootstrap_script(@archives);
    }
    
    # Step 3: Check Projects knowledge (if in project)
    if (in_project) {
        my @core_files = get_project_files("core");
        recreate_workspace(@core_files);
    }
    
    # Step 4: Verify setup
    verify_workspace();
    
    # Step 5: Report status
    say "✓ Workspace ready!";
    say "✓ Last session: " . $context->{summary};
    say "✓ Ready to continue with: " . suggest_next_steps();
}
```

## Benefits of This Architecture

### 1. **Persistence Where It Matters**
- Core code always available in Projects
- No need to recreate from scratch
- Conceptual continuity maintained

### 2. **Flexibility Where Needed**
- Machine workspace for development
- Can install dependencies
- Full filesystem access
- Test freely

### 3. **Clean Separation**
- Projects: Stable, curated, persistent
- Machine: Dynamic, experimental, ephemeral
- Outputs: Results to save/share

### 4. **Automatic Resume**
- `conversation_search` finds context
- Bootstrap script rebuilds environment
- No manual setup needed

### 5. **Version Control**
- Keep latest implementations
- Archive complete snapshots
- Remove outdated files

## Workflow Summary

```
Day 1: Initial Development
→ Create in /home/claude
→ Test and iterate
→ Save to /mnt/user-data/outputs
→ Download and add to Projects

Day 7: Resume Work
→ Claude uses conversation_search
→ Finds Day 1 session
→ Reads context
→ Recreates workspace from Projects
→ Ready in seconds

Day 14: Add Feature
→ User uploads latest archive
→ Bootstrap script extracts
→ Develop new feature
→ Save updated version
→ Update Projects with new version

Day 30: Show Demo
→ Pull from Projects
→ Set up clean demo environment
→ Generate shareable outputs
→ No clutter, just core files
```

## Implementation Status

✅ **Complete:**
- Bootstrap script created
- Workspace organization working
- File categorization automated
- Checkpoint creation functional
- Quick reference generation

🚧 **To Implement:**
- Projects upload integration (manual for now)
- Automatic conversation context loading (use tools)
- Network sync between Projects and machine
- Version tracking system

## Quick Reference Commands

### Bootstrap from archive:
```bash
perl /home/claude/living_tree_bootstrap.pl bootstrap
```

### Create checkpoint:
```bash
perl /home/claude/living_tree_bootstrap.pl checkpoint
```

### Access workspace:
```bash
cd /home/claude/current_work
```

### View what's ready:
```bash
ls -lh /mnt/user-data/outputs/
```

## Next Steps

1. **Clean up Projects** (manual)
   - Remove redundant files
   - Keep only core + latest
   - Organize into folders

2. **Test resume flow**
   - Start new conversation
   - Ask Claude to "resume Living Tree work"
   - See if conversation_search works

3. **Iterate and improve**
   - Add features on machine
   - Save results to outputs
   - Update Projects with new versions

4. **Scale to network** (future)
   - Distribute across nodes
   - Use resonant memory
   - Harmonic synchronization

---

## The Living Tree Philosophy Applied

**Projects = Root** (persistent, stable, essential)
- Stores core genetic information
- Provides foundation for growth
- Maintains identity over time

**Machine = Branches** (ephemeral, dynamic, experimental)
- Grows from root
- Tests new patterns
- Can be pruned and regrown

**Outputs = Seeds** (results to propagate)
- Mature work ready to share
- Can plant in new environments
- Spreads the tree's knowledge

**Conversation History = Memory** (resonant learning)
- System learns from past interactions
- Context preserved across sessions
- Patterns emerge through use

**This is not just file management.**
**This is Living Tree architecture in practice.** 🌳

✨ **Persistent root + ephemeral branches = infinite growth potential** ✨
