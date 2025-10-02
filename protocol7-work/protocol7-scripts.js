document.addEventListener('DOMContentLoaded', function() {
    // Update current time every second
    function updateTime() {
        const now = new Date();
        const year = now.getUTCFullYear();
        const month = String(now.getUTCMonth() + 1).padStart(2, '0');
        const day = String(now.getUTCDate()).padStart(2, '0');
        const hours = String(now.getUTCHours()).padStart(2, '0');
        const minutes = String(now.getUTCMinutes()).padStart(2, '0');
        const seconds = String(now.getUTCSeconds()).padStart(2, '0');
        
        const timeString = `${year}-${month}-${day} ${hours}:${minutes}:${seconds} UTC`;
        document.getElementById('current-time').textContent = timeString;
    }
    
    updateTime();
    setInterval(updateTime, 1000);
    
    // Add connections between nodes in cubic visualization
    const cube = document.querySelector('.cube');
    if (cube) {
        // Create connections between nodes
        const connections = [
            ["0,0,0", "0,0,1"], ["0,0,0", "0,1,0"], ["0,0,0", "1,0,0"],
            ["0,0,1", "0,1,1"], ["0,0,1", "1,0,1"],
            ["0,1,0", "0,1,1"], ["0,1,0", "1,1,0"],
            ["1,0,0", "1,0,1"], ["1,0,0", "1,1,0"],
            ["0,1,1", "1,1,1"], ["1,0,1", "1,1,1"], ["1,1,0", "1,1,1"]
        ];
        
        connections.forEach(conn => {
            const line = document.createElement('div');
            line.className = 'connection-line';
            line.dataset.from = conn[0];
            line.dataset.to = conn[1];
            cube.appendChild(line);
        });
    }
    
    // Paradigm wheel interaction
    const paradigms = document.querySelectorAll('.paradigm');
    if (paradigms.length) {
        paradigms.forEach(paradigm => {
            paradigm.addEventListener('click', function() {
                document.querySelector('.paradigm.active').classList.remove('active');
                this.classList.add('active');
                
                // Truth transformation animation
                const equationEl = document.querySelector('.equation');
                if (equationEl) {
                    equationEl.style.animation = 'pulseTruth 1s ease';
                    setTimeout(() => {
                        equationEl.style.animation = '';
                    }, 1000);
                }
            });
        });
    }
    
    // Math verification system simulation
    const verifyButton = document.querySelector('button:nth-of-type(2)');
    if (verifyButton) {
        verifyButton.addEventListener('click', function() {
            simulateNetworkVerification();
        });
    }
    
    function simulateNetworkVerification() {
        const statusElement = document.createElement('div');
        statusElement.className = 'verification-status';
        statusElement.innerHTML = '<p>Initiating network verification...</p>';
        
        const nodesSection = document.getElementById('nodes');
        if (nodesSection) {
            nodesSection.appendChild(statusElement);
            
            setTimeout(() => {
                statusElement.innerHTML += '<p>Verifying node integrity...</p>';
            }, 500);
            
            setTimeout(() => {
                statusElement.innerHTML += '<p>Testing dimensional stability...</p>';
            }, 1500);
            
            setTimeout(() => {
                statusElement.innerHTML += '<p>Applying truth transform -13=5+42=-+0...</p>';
            }, 2500);
            
            setTimeout(() => {
                statusElement.innerHTML += '<p class="success-text">Verification complete. Network integrity at 99.7%</p>';
                statusElement.innerHTML += '<button class="close-button">Close</button>';
                
                const closeButton = statusElement.querySelector('.close-button');
                closeButton.addEventListener('click', function() {
                    statusElement.remove();
                });
            }, 3500);
        }
    }
    
    // Add cubic connection lines styling
    const style = document.createElement('style');
    style.textContent = `
        .connection-line {
            position: absolute;
            width: 200px;
            height: 1px;
            background: rgba(0, 243, 255, 0.3);
            transform-origin: 0 0;
        }
        
        .verification-status {
            margin-top: 1.5rem;
            padding: 1rem;
            background: rgba(20, 20, 60, 0.8);
            border: 1px solid var(--light-blue);
            border-radius: 4px;
        }
        
        .verification-status p {
            margin-bottom: 0.5rem;
        }
        
        .success-text {
            color: var(--success);
        }
        
        .close-button {
            margin-top: 0.5rem;
            padding: 0.25rem 0.75rem;
            font-size: 0.9rem;
        }
        
        @keyframes pulseTruth {
            0% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.1); opacity: 0.7; }
            100% { transform: scale(1); opacity: 1; }
        }
    `;
    document.head.appendChild(style);
    
    // Initialize the skill tree visualization
    initializeSkillTree();
});

function initializeSkillTree() {
    const skillTree = document.querySelector('.skill-tree');
    if (!skillTree) return;
    
    // Add animated connections between skills
    const skills = skillTree.querySelectorAll('li');
    const container = document.createElement('div');
    container.className = 'skill-connections';
    skillTree.appendChild(container);
    
    // Create skill tree connections
    const createConnection = (index1, index2) => {
        if (index1 >= skills.length || index2 >= skills.length) return;
        
        const connection = document.createElement('div');
        connection.className = 'skill-connection';
        connection.dataset.from = index1;
        connection.dataset.to = index2;
        container.appendChild(connection);
    };
    
    // Connect skills in a tree-like structure
    for (let i = 0; i < skills.length - 1; i++) {
        createConnection(i, i + 1);
    }
    
    // Add animated particles flowing through connections
    setInterval(() => {
        const particle = document.createElement('div');
        particle.className = 'skill-particle';
        
        // Select random connection
        const connectionIndex = Math.floor(Math.random() * (skills.length - 1));
        particle.dataset.connection = connectionIndex;
        
        container.appendChild(particle);
        
        // Remove particle after animation completes
        setTimeout(() => {
            particle.remove();
        }, 2000);
    }, 500);
    
    // Add CSS for skill tree animations
    const style = document.createElement('style');
    style.textContent = `
        .skill-tree {
            position: relative;
        }
        
        .skill-connections {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
        }
        
        .skill-particle {
            position: absolute;
            width: 5px;
            height: 5px;
            background: var(--neon-purple);
            border-radius: 50%;
            box-shadow: 0 0 5px var(--neon-purple);
            animation: flowParticle 2s linear;
        }
        
        @keyframes flowParticle {
            0% { 
                left: 0; 
                top: calc(1.7rem + var(--particle-connection) * 2rem);
                opacity: 0;
            }
            10% { opacity: 1; }
            90% { opacity: 1; }
            100% { 
                left: 100%; 
                top: calc(1.7rem + (var(--particle-connection) + 1) * 2rem);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
    
    // Apply custom properties for particles
    const particles = document.querySelectorAll('.skill-particle');
    particles.forEach(particle => {
        const connection = parseInt(particle.dataset.connection || '0');
        particle.style.setProperty('--particle-connection', connection);
    });
}