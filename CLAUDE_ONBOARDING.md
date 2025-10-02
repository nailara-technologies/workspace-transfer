# BMW Resumability Analysis Onboarding Guide

## Complete Directory Structure Explanation
- **/home/claude/workspace-transfer/**: Main project workspace.
- **/home/claude/work/**: Secondary workspace for development and testing.
- **/mnt/user-data/uploads/**: Directory for temporary uploads.
- **/mnt/user-data/outputs/**: Directory for output files and results.
- **~/.ssh/workspace-transfer-read-write**: SSH configuration for accessing the workspace repository.

## Repository References
- **workspace-transfer**: [https://github.com/nailara-technologies/workspace-transfer.git](https://github.com/nailara-technologies/workspace-transfer.git)
- **protocol-7**: [https://github.com/nailara-technologies/protocol-7.git](https://github.com/nailara-technologies/protocol-7.git)  
  Key Directories:  
  - `bin/`  
  - `modules/`  
  - `data/`  
  - `bin/dev/`  
- **digest-bmw**: [https://github.com/gray/digest-bmw.git](https://github.com/gray/digest-bmw.git)  
  Key Files:  
  - `BMW.xs`  
  - `lib/Digest/BMW.pm`  
  - `t/` (test suite)

## BMW Resumability Mission
The BMW Resumability mission aims to ensure robust handling of file integrity and consistency. Protocol-7 utilizes BMW384 checksums, and ELF7 is already designed to be resumable, which enhances the reliability of data processing workflows.

## Step-by-Step Instructions
### Phase 1: Clone digest-bmw
1. Clone the digest-bmw repository to `/home/claude/work/`:
   ```bash
   git clone https://github.com/gray/digest-bmw.git /home/claude/work/digest-bmw
   ```
2. Navigate to the cloned directory and grep for methods:
   ```bash
   cd /home/claude/work/digest-bmw
   grep -r 'getstate\\|setstate\\|clone' .
   ```

### Phase 2: Build the Project
1. Install necessary packages:
   ```bash
   apt-get install build-essential perl cpanminus libssl-dev
   ```
2. Build the project:
   ```bash
   perl Makefile.PL
   make
   make test
   ```

### Phase 3: Create and Run Test Script
1. Create the test script at `/home/claude/work/test-bmw-resumability.pl` with the following content:
   ```perl
   #!/usr/bin/perl
   use strict;
   use warnings;
   use Digest::BMW;
   
   # Test BMW consistency
   my $bwm = Digest::BMW->new();
   # Add additional testing logic here
   ```
2. Run the test script:
   ```bash
   perl /home/claude/work/test-bmw-resumability.pl
   ```

### Phase 4: Create Analysis Report Templates
- Prepare templates for success and failure scenarios to document the outcomes of your tests.

### Phase 5: Implementation Guidance
- Review the methods. If any methods are missing, provide implementation guidance on how to add them to the digest-bmw library.

## Deliverables Checklist
Ensure the following files are prepared and stored in `/mnt/user-data/outputs/`:
- `bmw-test-results.txt`
- `bmw-analysis-report.md`
- `bmw-state-serialization.patch`
- `bmw-implementation-notes.md`

## ELF7 Resumability Reference
For reference, see the continuation pattern in protocol-7's `bin/dev/elf-continue`.

## Success Criteria
- Successful execution of the BMW consistency tests.
- Verified implementations of getstate/setstate methods.
- Completion of analysis report templates.
- All deliverables prepared and stored correctly.