# Claude AI - Protocol-7 Workspace Onboarding

## Welcome to the Protocol-7 Development Environment

You are operating in an **Ubuntu 24.04 LTS** environment with access to the Protocol-7 codebase.

---

## Directory Structure

```
/home/claude/workspace-transfer/    # Main Protocol-7 repository (via SSH key)
/home/claude/work/                  # Workspace for builds, tests, experiments
/mnt/user-data/uploads/             # User-uploaded files
/mnt/user-data/outputs/             # Your generated outputs
~/.ssh/workspace-transfer-read-write # SSH key for repository access
```

**Important Rules:**
- ✅ DO clone external repos into `/home/claude/work/`
- ✅ DO place build artifacts in `/home/claude/work/`
- ✅ DO write reports to `/mnt/user-data/outputs/`
- ❌ DO NOT commit binaries or build artifacts to `workspace-transfer/`

---

## Current Mission: BMW Resumability Analysis

### Context

Protocol-7 uses **BMW384** checksums for file signing. Currently:
- ✅ **ELF7 checksums** are resumable (see `bin/dev/elf-continue`)
- ❓ **BMW checksums** - resumability needs verification

### Why This Matters

For streaming signatures (large files, network data), we need:
1. **State save** - Serialize internal BMW context
2. **State restore** - Resume computation from saved state
3. **Streaming mode** - Process data in chunks without buffering

### Your Task

#### Phase 1: Clone and Analyze

```bash
# Setup workspace
mkdir -p /home/claude/work
cd /home/claude/work

# Clone BMW repository (NOT in workspace-transfer!)
git clone https://github.com/gray/digest-bmw.git
cd digest-bmw

# Analyze implementation
bash ../analyze-bmw-implementation.sh | tee /mnt/user-data/outputs/bmw-analysis.txt
```

#### Phase 2: Build and Test

```bash
cd /home/claude/work/digest-bmw

# Install build dependencies
sudo apt-get update
sudo apt-get install -y build-essential perl cpanminus libssl-dev
cpanm --installdeps .

# Build BMW module
perl Makefile.PL
make
make test  # Should pass
```

#### Phase 3: Test Resumability

```bash
cd /home/claude/work

# Run resumability verification
perl test-bmw-resumability.pl | tee /mnt/user-data/outputs/bmw-test-results.txt
```

**Expected Outcomes:**
- ✅ **Scenario A**: BMW has `clone()` or `getstate()`/`setstate()` → Document usage
- 🔧 **Scenario B**: Methods missing → Implement state serialization

#### Phase 4: Implementation (If Needed)

If state methods are missing:

1. **Design state serialization**
   ```c
   // Add to BMW.xs
   SV* getstate(SV* self);
   void setstate(SV* self, SV* state);
   ```

2. **Implement in BMW.xs**
   - Serialize `bmw_ctx` structure
   - Restore from binary blob

3. **Rebuild and test**
   ```bash
   make clean
   perl Makefile.PL
   make
   perl ../test-bmw-resumability.pl
   ```

4. **Generate patch**
   ```bash
   git diff > /mnt/user-data/outputs/bmw-state-serialization.patch
   ```

#### Phase 5: Generate Report

Create `/mnt/user-data/outputs/bmw-resumability-report.md` with:
- Analysis findings
- Test results
- Implementation status
- Integration recommendations

---

## Deliverables

Place all outputs in `/mnt/user-data/outputs/`:

1. ✅ `bmw-analysis.txt` - Initial analysis
2. ✅ `bmw-test-results.txt` - Test output
3. ✅ `bmw-resumability-report.md` - Final report
4. ✅ `bmw-state-serialization.patch` - Implementation (if needed)

---

## Reference: ELF7 Resumability Example

Protocol-7's ELF7 already supports resumable checksums:

```perl
# bin/dev/elf-continue demonstrates this:

# Calculate first chunk
my $state1 = elf_chksum(0, "first chunk");  # seed = 0

# Resume with second chunk
my $state2 = elf_chksum($state1, "second chunk");  # seed = $state1

# Final checksum = elf_chksum(0, "first chunksecond chunk")
```

**Goal**: BMW should have similar capability!

---

## Protocol-7 Repository Access

The repository is available at `/home/claude/workspace-transfer/`:

```bash
cd /home/claude/workspace-transfer

# Sync latest changes
git pull origin main

# View project structure
ls -la
```

**SSH Key**: Already configured at `~/.ssh/workspace-transfer-read-write`

---

## Success Criteria

- ✅ BMW module builds successfully
- ✅ Resumability verified or implemented
- ✅ Tests pass
- ✅ Documentation complete
- ✅ Ready for Protocol-7 integration

---

## Need Help?

- Protocol-7 docs: `/home/claude/workspace-transfer/read-me/documentation/`
- BMW reference: `https://github.com/gray/digest-bmw`
- Test scripts: `/home/claude/work/`

---

**Let's validate BMW streaming capabilities! 🌀✨**