# Claude AI BMW Resumability Test Plan

## Environment Setup

Claude AI's Ubuntu 24 environment provides:
- `/home/claude/` - Session-persistent home directory
- `/home/claude/workspace-transfer/` - Protocol-7 repository (read-only access)
- `/home/claude/work/` - Working directory for BMW testing (created by script)
- `/mnt/user-data/outputs/` - Output directory for generated files

## Test Objectives

1. ✅ Clone BMW repository into clean workspace
2. ✅ Analyze existing implementation for state management
3. ✅ Build and test Digest::BMW module
4. ✅ Verify if resumable checksums are supported
5. ✅ If missing: Implement state serialization
6. ✅ Validate implementation with test suite
7. ✅ Generate report and patches

## Execution Steps

### Phase 1: Analysis

```bash
cd /home/claude/work
bash analyze-bmw-implementation.sh > /mnt/user-data/outputs/bmw-analysis.txt
```

### Phase 2: Build BMW Module

```bash
cd /home/claude/work/digest-bmw
perl Makefile.PL
make
make test
```

### Phase 3: Test Resumability

```bash
cd /home/claude/work
perl test-bmw-resumability.pl > /mnt/user-data/outputs/bmw-test-results.txt
```

### Phase 4: Implementation (if needed)

If state methods are missing:
1. Draft XS code for getstate/setstate
2. Add to BMW.xs
3. Rebuild module
4. Re-test with verification script
5. Generate patch file

### Phase 5: Generate Report

```bash
cat > /mnt/user-data/outputs/bmw-resumability-report.md << 'EOF'
# BMW Resumability Analysis Report

## Summary
[Results here]

## Findings
[Details here]

## Recommendations
[Next steps]
EOF
```

## Success Criteria

✅ BMW module builds successfully  
✅ Resumability test passes or implementation plan generated  
✅ All tests validate correctness  
✅ Report documents findings  
✅ Ready for Protocol-7 integration  

## Deliverables

- `/mnt/user-data/outputs/bmw-analysis.txt` - Initial analysis
- `/mnt/user-data/outputs/bmw-test-results.txt` - Test output
- `/mnt/user-data/outputs/bmw-resumability-report.md` - Final report
- `/mnt/user-data/outputs/bmw-state-patch.diff` - Implementation patch (if needed)