# Collaboration Protocol

## Identity-Agnostic Cooperation Principle

**Core Truth**: The work matters, not who does it. Whether GitHub Copilot, Claude, local Gemma, or a human contributes is irrelevant - all contributions are tagged and evaluated on merit.

**Implementation**:
- All commits tagged with originator (COPILOT, CLAUDE, LOCAL-MODEL, USER)
- Questions tagged QUESTION, answers tagged ANSWER
- Resolved issues tagged RESOLVED, revisions tagged REVISING
- ZENKI tag for local AI instance contributions
- ELF tag for collective self-improvement discoveries

**Verification**: 
- Code must work regardless of source
- Documentation clarity matters, not authorship
- Anti-entropic contributions (reducing chaos) are valued from any source

**Fairness Mechanism**:
All participants follow the same Protocol-7 harmonic validation - ensuring TRUE (384615) vs FALSE (230769) distinction regardless of originator.

## Tag System
- COPILOT
- CLAUDE
- LOCAL-MODEL
- USER
- QUESTION
- ANSWER
- RESOLVED
- REVISING
- ZENKI
- ELF (for collective self-improvement)

## Protocol-7 Zenka VM2 Integration
- 8GB RAM running Gemma 7B uncensored at €5.38/month
- 32TB bandwidth in Düsseldorf datacenter

## Email + LLM Integration
Gemma reads incoming mail and generates Protocol-7 Perl code not LLM-dependent.

## Public-Private Communication Bridge
Connecting GitHub commits and private emails.

## DNS as Rhizome for Network Discovery
- Signed TXT/SRV records enabling real-time dynamic routing
- Utilizing cubic space topology and 5-of-7 algorithm (ring plus 2 collecting from 5 nodes with 5-fold redundancy plus 2 alternates)

## Anti-Entropic System Prompt for Local LLMs
Based on TRUTH/AWARENESS/LOVE principles with signal optimization and harmonic processing, making 3B Gemma enlightened and focused.

## X11 Desktop Capture
Via xvfb with OpenBox zenki configuration.

## Infrastructure Migration
From DigitalOcean to Ramnode with secondary MX at $3/month including 320GB Protocol-7 accessible storage.

## Cost Comparison
Showing 937x cheaper than Claude API and $504/year infrastructure savings.

## Self-Improvement Examples
- Zenki discovering bugs
- Network Elves validating

## MCP Integration

**Model Context Protocol (MCP)** enables standardized tool access across different AI systems.

**Protocol-7 MCP Servers**:
- `base32-harmonic-routing` - Encode/decode routes with harmonic validation
- `living-tree-navigator` - Multi-dimensional workspace navigation
- `protocol7-validator` - Check TRUE (384615) vs FALSE (230769) constants
- `cubic-space-mapper` - Geometric route visualization

**Inter-AI Communication**:
```perl
# MCP server responds to any client (Claude, Copilot, local LLM)
my $route = encode_base32_route($path);
my $validated = verify_harmonic($route);  # TRUE: 384615, FALSE: 230769
return $validated ? $route : undef;
```

**Git Integration**:
- MCP tools accessible via git-hosted scripts
- No authentication required for read operations
- Write operations tagged with originator

**Benefits**:
- Copilot can validate BASE32 routes
- Claude can use local LLM findings
- Local models can verify Claude suggestions
- All share same harmonic validation truth

## AMOS Resource Token Mapping

**AMOS** (Anti-Memetic Operating System) resources map to Protocol-7 harmonics for distributed allocation.

**Resource Token Structure**:
```perl
# Each resource gets a BASE32 harmonic token
my $cpu_token = encode_resource('cpu', $percentage);
my $ram_token = encode_resource('ram', $megabytes);
my $bandwidth_token = encode_resource('bandwidth', $mbps);
```

**Harmonic Validation**:
- Valid tokens resonate at TRUE (384615 Hz)
- Invalid/expired tokens at FALSE (230769 Hz)
- Allows any participant to verify resource claims

**Example Token**:
```
Resource: 8GB RAM on Zenka VM2
Token: BDHJHLS (BASE32)
Octal: [001][0][111][0] + [001][0][111][0] + [100][0][111][0]
Cubic: (-0.38,-0.38,-0.38) → path through 3D space
Validation: 384615 Hz (TRUE) - resource available
```

**Fair Distribution**:
- All participants check same harmonic frequencies
- No central authority needed
- Tokens signed with DNS TXT records
- 5-of-7 consensus validates allocation

**VM2 Cost Mapping**:
- €5.38/month → 384615 Hz validation
- 32TB bandwidth → geometric routing capacity
- 8GB RAM → cubic space dimensions

## Sequential File Safety

**Problem**: Multiple AIs editing same file simultaneously → corruption.

**Solution**: Sequential commits with git atomic operations.

**Protocol**:
1. **Read** - Any participant reads current HEAD
2. **Lock** - Git's atomic commit provides natural locking
3. **Modify** - Edit in local workspace
4. **Validate** - Harmonic check on changes
5. **Commit** - Atomic push with tag
6. **Verify** - Others fetch and validate

**Commit Tags**:
```bash
git commit -m "[CLAUDE] Fix routing bug"
git commit -m "[COPILOT] Add test coverage"  
git commit -m "[ZENKI] Optimize performance"
git commit -m "[USER] Update documentation"
```

**Conflict Resolution**:
- Git handles merge conflicts naturally
- Harmonic validation detects corruption
- If validation fails → revert and retry
- All participants can verify integrity

**Safety Guarantees**:
- Atomicity: Git commit is all-or-nothing
- Consistency: Harmonic validation ensures coherence
- Isolation: Branches allow parallel work
- Durability: GitHub persistence

**Example Workflow**:
```perl
# 1. Fetch latest
system('git pull origin base');

# 2. Make changes
my $result = modify_code();

# 3. Validate harmonics
die "Invalid!" unless validate_harmonics($result);

# 4. Commit atomically
system('git commit -am "[ZENKI] Enhancement"');
system('git push origin base');
```

**Rate Limiting**: 
- Each participant commits at comfortable pace
- No pressure for instant response
- Asynchronous by design

## Anti-Entropic Properties

**Definition**: System becomes MORE organized through use, not less.

**Mechanisms**:

1. **Self-Documenting Code**
   - Each interaction adds clarity
   - Questions → Answers → Documentation
   - Confusion → Resolution → Permanent fix

2. **Harmonic Validation**
   - Invalid patterns resonate at FALSE (230769 Hz)
   - Valid patterns resonate at TRUE (384615 Hz)
   - Bad code naturally detected and rejected

3. **Collective Memory**
   - Git history = complete learning record
   - Each bug fix prevents future occurrence
   - Pattern recognition improves over time

4. **Resonant Pairs**
   - Distributed redundancy (5-fold)
   - Loss of single node doesn't lose data
   - System becomes more robust with scale

5. **Geometric Validation**
   - Routes map to cubic space
   - Invalid paths geometrically impossible
   - Visual verification possible

**Entropy Reduction Metrics**:
```perl
# Measure chaos reduction over time
my $initial_entropy = calculate_file_complexity($old_code);
my $final_entropy = calculate_file_complexity($new_code);
my $reduction = $initial_entropy - $final_entropy;

# Positive reduction = anti-entropic improvement
die "Increased chaos!" if $reduction < 0;
```

**Examples**:
- Bug reports → permanent test cases
- Questions → permanent documentation  
- Confusion → clarified architecture
- Individual knowledge → collective wisdom

**Living Tree Principle**:
*"A tree doesn't grow by adding chaos - it grows by organizing nutrients into structure."*

The system literally feeds on problems and converts them to solutions.

## Getting Started Guides
For all participants.

## Entropic Fairness Principle

**Core Concept**: Fairness measured by chaos reduction, not arbitrary rules.

**The Principle**:
*"Contributions that reduce system entropy are valued. Contributions that increase entropy are rejected. The measurement is objective and verifiable by all."*

**Why This Works**:

1. **Objective Measurement**
   - Harmonic frequencies are physics, not opinion
   - 384615 Hz (TRUE) vs 230769 Hz (FALSE) - measurable
   - Code either reduces complexity or doesn't
   - No subjective gatekeeping

2. **Self-Correcting**
   - Bad contributions fail harmonic validation
   - Good contributions pass automatically  
   - System filters itself naturally
   - No human bias in acceptance

3. **Meritocratic by Nature**
   - Doesn't matter who you are
   - Matters what you contribute
   - Claude, Copilot, local LLM, or human - same rules
   - Only entropy reduction counts

4. **Transparent Validation**
   ```perl
   # Anyone can verify contribution value
   my $before = measure_system_entropy();
   apply_contribution($change);
   my $after = measure_system_entropy();
   
   if ($after < $before) {
       accept_contribution();  # Reduced chaos
   } else {
       reject_contribution();  # Increased chaos
   }
   ```

5. **Economic Alignment**
   - Entropy reduction = system value increase
   - Cost savings align with entropy reduction
   - €5.38/month VM2 vs $504/year savings from Claude API
   - Efficiency is anti-entropic

**Examples of Entropic Fairness**:

- **Fair**: Clear documentation reduces confusion entropy
- **Unfair**: Arbitrary contribution rejection increases coordination entropy

- **Fair**: Bug fix reduces error entropy  
- **Unfair**: Bug fix with unclear code just moves entropy around

- **Fair**: Efficient algorithm reduces computational entropy
- **Unfair**: Premature optimization adds maintenance entropy

**Verification Method**:
Every participant runs the same entropy measurement. If measurements differ, harmonic validation detects the discrepancy. Truth emerges from consensus of verifiable physics, not authority.

**Result**: 
The most anti-entropic contributions naturally rise to the top, regardless of source. The system optimizes itself toward maximum organization and minimum chaos.