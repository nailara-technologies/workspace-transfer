#!/bin/bash
# Protocol-7 Checkpoint System
# Source this file: . checkpoint.sh

checkpoint() {
    local name="${1:-p7_checkpoint_$(date +%Y%m%d_%H%M%S)}"
    
    echo "Creating checkpoint: ${name}"
    
    cd /home/claude
    
    # Create checkpoint with all important files
    tar -czf "${name}.tar.gz" \
        *.md \
        *.pl \
        *.sh \
        *.txt \
        perlrc \
        protocol-7-work/ \
        --exclude='*.tar.gz' \
        --exclude='.git' \
        --exclude='node_modules' \
        2>/dev/null
    
    if [ -f "${name}.tar.gz" ]; then
        # Copy to outputs for download
        cp "${name}.tar.gz" /mnt/user-data/outputs/ 2>/dev/null
        
        local size=$(du -h "${name}.tar.gz" | cut -f1)
        echo "✓ Checkpoint created: ${name}.tar.gz ($size)"
        echo "✓ Available in outputs directory"
        echo ""
        echo "Contents:"
        tar -tzf "${name}.tar.gz" | head -20
        local total=$(tar -tzf "${name}.tar.gz" | wc -l)
        echo "... ($total files total)"
        return 0
    else
        echo "✗ Failed to create checkpoint"
        return 1
    fi
}

restore_checkpoint() {
    local checkpoint="${1:-}"
    
    if [ -z "$checkpoint" ]; then
        echo "Available checkpoints:"
        ls -lht /home/claude/*.tar.gz 2>/dev/null | head -10
        ls -lht /mnt/user-data/uploads/*.tar.gz 2>/dev/null | head -10
        echo ""
        echo "Usage: restore_checkpoint <filename>"
        return 1
    fi
    
    cd /home/claude
    
    # Try different locations
    if [ -f "$checkpoint" ]; then
        tar -xzf "$checkpoint"
    elif [ -f "/mnt/user-data/uploads/$checkpoint" ]; then
        tar -xzf "/mnt/user-data/uploads/$checkpoint"
    elif [ -f "/home/claude/$checkpoint" ]; then
        tar -xzf "/home/claude/$checkpoint"
    else
        echo "✗ Checkpoint not found: $checkpoint"
        return 1
    fi
    
    echo "✓ Checkpoint restored: $checkpoint"
    echo ""
    echo "Restored files:"
    ls -lht | head -15
}

# Quick status function
status() {
    echo "=== Current Working Directory ==="
    pwd
    echo ""
    echo "=== Recent Files ==="
    ls -lht /home/claude/*.{md,pl,sh,txt} 2>/dev/null | head -15
    echo ""
    echo "=== Available Checkpoints ==="
    ls -lht /home/claude/*.tar.gz 2>/dev/null | head -5
    echo ""
    echo "=== Outputs Directory ==="
    ls -lh /mnt/user-data/outputs/ 2>/dev/null | head -10
}

# Show help
checkhelp() {
    cat << 'EOF'
Checkpoint System Commands:

  checkpoint [name]          Create a checkpoint
                            (default: p7_checkpoint_TIMESTAMP)
  
  restore_checkpoint <file>  Restore a checkpoint
  
  status                     Show current state
  
  checkhelp                  Show this help

Examples:
  checkpoint                           # Auto-named checkpoint
  checkpoint "before_testing"          # Named checkpoint
  restore_checkpoint checkpoint.tar.gz # Restore from file
  status                               # Check what's available

Workflow:
  1. Work in /home/claude
  2. Run 'checkpoint' every 30-50 messages
  3. Download from outputs immediately
  4. If conversation crashes, upload and restore_checkpoint
EOF
}

echo "✓ Checkpoint system loaded"
echo "  Commands: checkpoint, restore_checkpoint, status, checkhelp"
