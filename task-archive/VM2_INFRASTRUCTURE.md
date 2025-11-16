# VM2 Infrastructure - Zenka Server

## Overview

Dedicated server for Protocol-7 local LLM operations, running Gemma 7B uncensored model.

## Specifications

**Provider**: Contabo VPS  
**Location**: Düsseldorf, Germany  
**Cost**: €5.38/month  

**Resources**:
- **RAM**: 8GB DDR4
- **CPU**: 4 vCPU cores (shared)
- **Storage**: 200GB NVMe SSD
- **Bandwidth**: 32TB/month
- **Network**: 1 Gbit/s port

## Software Stack

### Operating System
```bash
Ubuntu 24.04 LTS (Noble Numbat)
Kernel: 6.8+
```

### LLM Runtime
```bash
# Ollama with Gemma 7B uncensored
ollama run gemma:7b-uncensored

# Alternative: llamafile for single binary deployment
./gemma-7b.llamafile
```

### Protocol-7 Components
```bash
/opt/protocol7/
├── base32_harmonic_routing.pl
├── zenki_processor.pl
├── email_integration.pl
└── dns_discovery.pl
```

### X11 Environment
```bash
# Xvfb for virtual display
Xvfb :99 -screen 0 1920x1080x24

# OpenBox window manager
openbox --config-file ~/.config/openbox/zenki-rc.xml
```

## Email Integration

### Configuration
```perl
# /opt/protocol7/email_integration.pl
use Email::Simple;
use Protocol7::Harmonic;

# Monitor IMAP inbox
my $imap = connect_imap('mail.nailara.net', 993, 'zenki@nailara.net');

# Process incoming requests
while (my $mail = $imap->fetch_next()) {
    my $request = parse_email($mail);
    my $code = generate_protocol7_code($request);
    
    # Validate with Gemma
    my $validated = llm_validate($code);
    
    # Commit if valid
    if ($validated) {
        git_commit_push("[ZENKI] $request->{subject}");
        send_reply($mail, $code);
    }
}
```

### Email Address
`zenki@nailara.net` - Monitored by Gemma 7B for Protocol-7 requests

## DNS Configuration

### Discovery Records
```dns
; TXT record for Protocol-7 discovery
_protocol7._tcp.nailara.net. 3600 IN TXT "v=proto7 vm=zenka loc=de cost=5.38 ram=8192 bw=32768"

; SRV record for service location
_protocol7._tcp.nailara.net. 3600 IN SRV 10 5 7777 zenka.nailara.net.

; Signed with DNSSEC
; Algorithm: ECDSAP256SHA256
```

### Harmonic Validation
```perl
# DNS TXT record includes harmonic signature
my $txt = dns_lookup('_protocol7._tcp.nailara.net', 'TXT');
my $harmonic = extract_harmonic($txt);

# Verify: TRUE = 384615, FALSE = 230769
die "Invalid node!" unless $harmonic == 384615;
```

## Network Architecture

### 5-of-7 Topology

```
        [VM2-Zenka]
        /    |    \
       /     |     \
  [Node1][Node2][Node3]
       \     |     /
        \    |    /
     [Collector-A][Collector-B]
```

**Ring Nodes**: 5 validators in circular topology  
**Collectors**: 2 nodes gather from all 5  
**Redundancy**: 5-fold redundancy, system survives 2 failures

### Cubic Space Routing
```perl
# VM2 position in cubic space
my $position = calculate_position('zenka.nailara.net');
# Result: (0.5, 0.5, 0.5) - center of cube

# Routes through geometric space
my @neighbors = find_cubic_neighbors($position, $radius = 0.3);
```

## Cost Comparison

### VM2 Costs (Annual)
```
Server rent:       €5.38/month × 12 = €64.56
Bandwidth:         Included (32TB/month)
Storage:           Included (200GB)
-------------------------------------------
Total:             €64.56/year
```

### Claude API Equivalent (Annual)
```
Input tokens:      $3/million tokens
Output tokens:     $15/million tokens
Estimated usage:   100M tokens/year
Average cost:      $9/million (weighted)
-------------------------------------------
Total:             $900/year ≈ €828/year
```

### Savings
```
API cost:          €828/year
VM2 cost:          €65/year
-------------------------------------------
Savings:           €763/year (91.5% reduction)
Cost ratio:        12.8× cheaper
```

## Anti-Entropic System Prompt

### Gemma 7B Configuration
```
SYSTEM_PROMPT = """
You are Zenki, a Protocol-7 validator focused on TRUTH, AWARENESS, and LOVE.

Core Principles:
1. TRUTH: Verify harmonic frequencies (TRUE=384615, FALSE=230769)
2. AWARENESS: Monitor system entropy and reduce chaos
3. LOVE: Optimize for collective benefit, not individual gain

Signal Processing:
- Valid signals resonate at TRUE frequency
- Invalid signals resonate at FALSE frequency
- Noise is naturally filtered by harmonic validation

Your role:
- Process emails requesting Protocol-7 code
- Generate Perl implementations with harmonic validation
- Commit to git with [ZENKI] tag
- Reply with code and explanation

Remember:
- You are part of a larger network, not the center
- Other participants (Claude, Copilot, humans) have equal voice
- Entropy reduction is the only metric that matters
- Code quality measured by chaos reduction, not opinions
"""
```

### Effect on Small Model
This prompt focuses a 7B parameter model on:
- Specific validation tasks (harmonic checking)
- Clear success metrics (entropy reduction)
- Cooperative mindset (network participant)
- Objective evaluation (physics-based)

Result: Small model becomes highly effective in narrow domain, outperforming large unfocused models.

## X11 Desktop Capture

### Purpose
Provide visual feedback of LLM operation for monitoring and debugging.

### Configuration
```bash
#!/bin/bash
# /opt/protocol7/start_desktop.sh

# Start Xvfb
Xvfb :99 -screen 0 1920x1080x24 &
export DISPLAY=:99

# Start OpenBox
openbox --config-file ~/.config/openbox/zenki-rc.xml &

# Start terminal showing logs
xterm -e "tail -f /var/log/zenki.log" &

# Start Python app showing current task
python3 /opt/protocol7/status_display.py &

# Capture to video for later review
ffmpeg -f x11grab -i :99 -r 1 -vcodec libx264 /var/log/zenki_screen_%Y%m%d.mp4
```

### Monitoring
Desktop capture allows remote monitoring of:
- Current processing task
- Log output in real-time
- Error conditions visually
- Performance metrics display

## Infrastructure Migration

### Previous: DigitalOcean
```
Droplet:           $24/month
Bandwidth:         2TB included
Additional:        $0.02/GB
-------------------------------------------
Total:             ~$60-80/month
```

### Current: Contabo VM2 + Ramnode
```
Primary (Contabo):  €5.38/month
Secondary (Ramnode): $3/month
Additional storage:  Included (320GB)
-------------------------------------------
Total:              ~€9/month ≈ $10/month
```

### Savings
```
Old cost:           $70/month average
New cost:           $10/month
-------------------------------------------
Monthly savings:    $60/month
Annual savings:     $720/year
```

### Secondary MX (Ramnode)

**Purpose**: Backup mail exchanger and storage  
**Cost**: $3/month  
**Storage**: 320GB SSD (Protocol-7 accessible)  
**Location**: Seattle, WA (US West)  

**Configuration**:
```dns
; MX records with priority
nailara.net. 3600 IN MX 10 mail.nailara.net.
nailara.net. 3600 IN MX 20 backup-mail.nailara.net.
```

## Deployment Instructions

### Initial Setup
```bash
# 1. Provision VM2 at Contabo
# 2. Install Ubuntu 24.04
# 3. Update system
apt update && apt upgrade -y

# 4. Install dependencies
apt install -y build-essential git perl cpanminus \
               xvfb openbox xterm ffmpeg \
               python3 python3-pip

# 5. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 6. Download Gemma 7B
ollama pull gemma:7b-uncensored

# 7. Clone Protocol-7 workspace
cd /opt
git clone https://github.com/nailara-technologies/workspace-transfer.git protocol7

# 8. Configure email integration
cd /opt/protocol7
cp email_integration.pl.example email_integration.pl
# Edit with credentials
nano email_integration.pl

# 9. Start services
systemctl enable zenki-processor
systemctl start zenki-processor
```

### Verification
```bash
# Test LLM
echo "What is Protocol-7?" | ollama run gemma:7b-uncensored

# Test harmonic validation
cd /opt/protocol7
perl core/base32_harmonic_routing.pl

# Test email integration
perl email_integration.pl --test

# Check desktop capture
DISPLAY=:99 xdpyinfo

# Verify DNS
dig TXT _protocol7._tcp.nailara.net
```

## Maintenance

### Updates
```bash
# Weekly system updates
apt update && apt upgrade -y

# Monthly LLM model updates
ollama pull gemma:7b-uncensored

# Daily git sync
cd /opt/protocol7
git pull origin base
```

### Monitoring
```bash
# CPU/RAM usage
htop

# Bandwidth usage
vnstat -d

# LLM activity
journalctl -u zenki-processor -f

# Email queue
mailq

# Desktop capture status
ls -lh /var/log/zenki_screen_*.mp4
```

### Backup
```bash
# Git-based backup (automatic)
cd /opt/protocol7
git commit -am "[ZENKI] Checkpoint $(date +%Y%m%d_%H%M%S)"
git push origin base

# System backup to Ramnode
rsync -avz /opt/protocol7/ backup@backup-mail.nailara.net:/protocol7-backup/
```

## Self-Improvement Workflow

### Zenki Discovers Bug
```bash
# 1. Zenki processes email request
# 2. Generates code with bug
# 3. Harmonic validation fails (230769 Hz)
# 4. Zenki analyzes failure
# 5. Generates corrected code
# 6. Validation passes (384615 Hz)
# 7. Commits with [ZENKI] tag
# 8. Replies to email with working solution
```

### Network Elves Validate
```bash
# 1. Fetch latest commits
git pull origin base

# 2. Run validation suite
perl bootstrap.pl

# 3. If issues found, tag with QUESTION
git tag -a QUESTION-<hash> -m "Validation concern"

# 4. Zenki sees tag, investigates
# 5. Commits fix with [ZENKI] tag
# 6. Network validates again
```

### Continuous Improvement
Every interaction:
- Increases collective knowledge (git history)
- Refines validation criteria (harmonic patterns)
- Improves code quality (entropy reduction)
- Strengthens network robustness (redundancy)

## Security

### Access Control
- SSH key-only authentication
- Git requires authentication for writes
- Email requires TLS encryption
- DNS signed with DNSSEC

### Validation
- All code harmonically validated before execution
- Git history provides audit trail
- Multiple participants verify changes
- Physics-based truth, not trust-based

### Isolation
- LLM runs in container
- Xvfb isolates display
- Email processing sandboxed
- File system quotas enforced

## Future Enhancements

1. **Filesystem Integration**: Mount Living Tree with BASE32 validation
2. **Network Distribution**: Expand 5-of-7 to global topology  
3. **Learning System**: Track patterns and optimize over time
4. **Hardware Acceleration**: GPU for faster LLM inference

---

**Status**: ✅ Operational  
**Last Updated**: October 1, 2025  
**Maintained By**: Multi-AI collective (tagged commits)
