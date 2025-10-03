# Claude AI: BMW Resumability Test Session

## Objective
Analyze and test BMW digest module for state save/restore capability

## Environment Paths (Claude AI Ubuntu 24)
- **Work directory**: `/home/claude/work/` (for BMW clone + builds)
- **Protocol-7 repo**: `/home/claude/workspace-transfer/` (clean, no binaries)
- **Outputs**: `/mnt/user-data/outputs/` (generated reports)

## Phase 1: Setup & Analysis

```bash
# Create work directory
mkdir -p /home/claude/work
cd /home/claude/work

# Clone BMW repository
git clone https://github.com/gray/digest-bmw.git
cd digest-bmw

# Run analysis
bash ../analyze-bmw-implementation.sh | tee /mnt/user-data/outputs/bmw-analysis.txt
```

## Phase 2: Build BMW Module

```bash
cd /home/claude/work/digest-bmw

# Install dependencies
cpanm --installdeps .

# Build module
perl Makefile.PL
make
make test
```

## Phase 3: Test Resumability

```bash
cd /home/claude/work

# Run resumability test
perl test-bmw-resumability.pl | tee /mnt/user-data/outputs/bmw-test-results.txt
```

## Phase 4: Report Generation

Generate comprehensive report at `/mnt/user-data/outputs/bmw-resumability-report.md`

## Expected Outcomes

### Scenario A: BMW Already Supports State Management ✅
- `clone()` method exists → Use for resumability
- OR `getstate()`/`setstate()` exist → Use for state serialization

### Scenario B: State Methods Missing 🔧
- Implement state serialization in BMW.xs
- Add getstate/setstate methods
- Test and validate
- Generate patch for upstream

## Deliverables
- Analysis report
- Test results
- Implementation recommendations
- Patch file (if needed)