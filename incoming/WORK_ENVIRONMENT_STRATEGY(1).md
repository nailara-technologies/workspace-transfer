# Claude Work Environment - Survival Strategy

## Understanding the Environment

### What Persists Between Messages (Same Session)
- `/home/claude` - Your main workspace ✓
- `/mnt/user-data/uploads` - Uploaded files (read-only) ✓
- Installed packages (apt, pip, npm) ✓

### What RESETS Between Container Restarts
- `/mnt/user-data/outputs` - Gets wiped! ⚠️
- All files you created
- Environment state
- Running processes

### What NEVER Persists
- Conversation history beyond ~8-10 hours or length limit
- Long-running computations

## Core Strategy: Checkpoint System

### Phase 1: Active Work
**Use `/home/claude` for everything:**
```bash
cd /home/claude
mkdir -p protocol-7-work/{scripts,docs,tests}

# Work here, iterate freely
# Create, edit, test without worrying about resets
```

### Phase 2: Save Checkpoints
**When you reach a good stopping point:**

```bash
# Create a dated checkpoint
DATE=$(date +%Y%m%d_%H%M%S)
CHECKPOINT="protocol7_checkpoint_${DATE}"

# Bundle everything important
cd /home/claude
tar -czf "${CHECKPOINT}.tar.gz" \
    *.md \
    *.pl \
    *.sh \
    perlrc \
    protocol-7-work/

# THEN copy to outputs
cp "${CHECKPOINT}.tar.gz" /mnt/user-data/outputs/
```

**Result:** You get a downloadable checkpoint you can re-upload later.

### Phase 3: Only Final Deliverables to Outputs
**When work is complete:**
```bash
# Copy only the finished files
cp install_minimal_dependencies.ubuntu24.sh /mnt/user-data/outputs/
cp QUICK_REFERENCE.md /mnt/user-data/outputs/
# etc.
```

## Workflow Pattern

### Starting Fresh
```bash
# If you uploaded a checkpoint
cd /home/claude
tar -xzf /mnt/user-data/uploads/protocol7_checkpoint_*.tar.gz

# Or if starting new
mkdir -p /home/claude/project-name
cd /home/claude/project-name
```

### During Work
```bash
# Stay in /home/claude
# Test, iterate, experiment
# Don't touch /mnt/user-data/outputs yet
```

### Before Conversation Limit
```bash
# Save checkpoint (every ~30-50 messages)
cd /home/claude
tar -czf checkpoint_$(date +%H%M).tar.gz \
    important-file1.* important-file2.* important-dir/
cp checkpoint_*.tar.gz /mnt/user-data/outputs/

# Download it immediately!
```

### Resuming After Crash
```
1. Upload your last checkpoint.tar.gz
2. Extract to /home/claude
3. Continue working
```

## Protocol-7 Specific Strategy

### Project Structure
```
/home/claude/
├── protocol-7-work/          # Main workspace
│   ├── scripts/              # Installation scripts
│   ├── docs/                 # Documentation
│   ├── tests/                # Test files
│   └── analysis/             # Analysis reports
├── checkpoints/              # Periodic saves
└── final-deliverables/       # Ready-to-ship files
```

### Checkpoint Contents (What to Save)
**Essential:**
- Installation scripts (*.sh)
- Test scripts (*.pl)
- Configuration files (perlrc, etc.)
- Documentation (*.md)
- Analysis results

**Skip:**
- Large repos (re-clone if needed)
- Build artifacts
- Downloaded dependencies

### Quick Checkpoint Command
```bash
# Add this to your workflow
checkpoint() {
    cd /home/claude
    local name="p7_checkpoint_$(date +%Y%m%d_%H%M%S)"
    tar -czf "${name}.tar.gz" \
        *.md *.pl *.sh perlrc \
        protocol-7-work/ \
        --exclude='*.tar.gz' \
        --exclude='.git' 2>/dev/null
    cp "${name}.tar.gz" /mnt/user-data/outputs/
    echo "✓ Checkpoint saved: ${name}.tar.gz"
    ls -lh /mnt/user-data/outputs/"${name}.tar.gz"
}
```

## Managing Long Conversations

### Signs You're Approaching Limit
- ~8-10 hours of conversation
- 100-150+ messages exchanged
- Slow response times
- Token budget warnings

### Action Plan When Near Limit
1. **Create final checkpoint:**
   ```bash
   checkpoint  # Use function above
   ```

2. **Download immediately** from outputs

3. **Create summary document:**
   ```bash
   cat > SESSION_SUMMARY.md << 'EOF'
   # Session Summary - [Date]
   
   ## What Was Accomplished
   - ...
   
   ## Current State
   - ...
   
   ## Next Steps
   - ...
   
   ## Files to Restore
   - checkpoint_XXXXXX.tar.gz
   EOF
   
   cp SESSION_SUMMARY.md /mnt/user-data/outputs/
   ```

4. **Start fresh conversation** and upload checkpoint

## Advanced: Git-Style Workflow

For complex projects:

```bash
# Initialize pseudo-git
cd /home/claude/protocol-7-work
mkdir -p .snapshots

# Take snapshot
snapshot() {
    local snap=".snapshots/snap_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$snap"
    cp -r ../!(*.tar.gz|.snapshots) "$snap/"
    echo "Snapshot: $snap"
}

# Restore snapshot
restore_snapshot() {
    local latest=$(ls -td .snapshots/snap_* | head -1)
    echo "Restoring: $latest"
    cp -r "$latest"/* ../
}
```

## Best Practices

### DO:
✓ Work in `/home/claude` exclusively
✓ Create checkpoints every 30-50 messages
✓ Download checkpoints immediately
✓ Use descriptive checkpoint names with timestamps
✓ Keep a SESSION_SUMMARY.md updated
✓ Copy to outputs only when sharing with user

### DON'T:
✗ Work directly in `/mnt/user-data/outputs`
✗ Assume outputs will persist
✗ Wait until last minute to checkpoint
✗ Create huge checkpoints (>100MB)
✗ Include compiled binaries in checkpoints
✗ Rely on conversation history alone

## Recovery Scenarios

### Scenario 1: Conversation Hit Limit
```
1. You have checkpoint from 20 minutes ago
2. Start new conversation
3. Upload checkpoint
4. Say: "Restore from checkpoint, we were working on X"
5. Continue immediately
```

### Scenario 2: Environment Crashed
```
1. You have checkpoint from 1 hour ago
2. Lost last hour of work
3. Re-upload checkpoint
4. Redo last changes (should be quick)
```

### Scenario 3: No Recent Checkpoint
```
1. Lost all work since last checkpoint
2. Lesson learned: checkpoint more often!
3. Use the checkpoint() function
```

## Protocol-7 Current Status

Based on your recovered files:

✓ Ubuntu 24 compatibility validated
✓ Installation scripts created
✓ Test framework working
✓ Documentation complete

**Suggested Next Checkpoint:**
```bash
cd /home/claude
tar -czf protocol7_ubuntu24_validated.tar.gz \
    ANALYSIS_SUMMARY.md \
    QUICK_REFERENCE.md \
    UBUNTU24_COMPATIBILITY_REPORT.md \
    INSTALLATION_TEST_RESULTS.md \
    PERL_PERSISTENT_SETUP.md \
    CLONED_REPO_ANALYSIS.md \
    install_minimal_dependencies.ubuntu24.sh \
    protocol-7-minimal-test.pl \
    check_available.pl \
    install-persistent-module.pl \
    perlrc \
    protocol-7-clone-summary.txt

cp protocol7_ubuntu24_validated.tar.gz /mnt/user-data/outputs/
```

## Quick Commands Reference

```bash
# Create checkpoint
cd /home/claude && tar -czf checkpoint_$(date +%H%M).tar.gz *.md *.pl *.sh perlrc

# Copy to outputs
cp checkpoint_*.tar.gz /mnt/user-data/outputs/

# Restore checkpoint
cd /home/claude && tar -xzf /mnt/user-data/uploads/checkpoint_*.tar.gz

# List what's in checkpoint
tar -tzf checkpoint_*.tar.gz

# Quick status
ls -lhrt /home/claude/*.{md,pl,sh} 2>/dev/null
```

## Summary

**The Golden Rule:** 
> Work in `/home/claude`, checkpoint often, copy to outputs only for delivery.

**Recovery Time:** 
- With checkpoints: ~2 minutes
- Without: Start over from scratch

**Optimal Checkpoint Frequency:**
- After significant milestones
- Every 30-50 messages
- Before testing risky changes
- When approaching conversation limits

Your Protocol-7 work is safe now! 🎉
