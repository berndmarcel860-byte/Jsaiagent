#!/bin/bash

# JSAIAgent Setup Script
# Automatische Installation und Konfiguration

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   JSAIAgent Setup                                          ║"
echo "║   KI-gestützter Telefonagent Installation                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}✗ Bitte als root ausführen (sudo ./setup.sh)${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Running as root${NC}"

# Check Node.js
echo ""
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}✓ Node.js found: $NODE_VERSION${NC}"
else
    echo -e "${RED}✗ Node.js not found${NC}"
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    echo -e "${GREEN}✓ Node.js installed${NC}"
fi

# Check Asterisk
echo ""
echo "Checking Asterisk..."
if command -v asterisk &> /dev/null; then
    echo -e "${GREEN}✓ Asterisk found${NC}"
else
    echo -e "${YELLOW}⚠ Asterisk not found${NC}"
    read -p "Install Asterisk? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apt-get update
        apt-get install -y asterisk asterisk-core-sounds-de asterisk-core-sounds-de-gsm
        systemctl start asterisk
        systemctl enable asterisk
        echo -e "${GREEN}✓ Asterisk installed${NC}"
    else
        echo -e "${YELLOW}⚠ Skipping Asterisk installation${NC}"
    fi
fi

# Check Python (for Coqui TTS)
echo ""
echo "Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo -e "${GREEN}✓ Python found: $PYTHON_VERSION${NC}"
else
    echo "Installing Python..."
    apt-get install -y python3 python3-pip
    echo -e "${GREEN}✓ Python installed${NC}"
fi

# Install Coqui TTS
echo ""
read -p "Install Coqui TTS? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Coqui TTS..."
    pip3 install TTS
    echo -e "${GREEN}✓ Coqui TTS installed${NC}"
    
    # Create TTS service
    echo "Creating TTS systemd service..."
    cat > /etc/systemd/system/coqui-tts.service <<EOF
[Unit]
Description=Coqui TTS Server
After=network.target

[Service]
Type=simple
User=$SUDO_USER
ExecStart=/usr/local/bin/tts-server --model_name tts_models/de/thorsten/tacotron2-DDC --port 5002
Restart=always

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable coqui-tts
    systemctl start coqui-tts
    echo -e "${GREEN}✓ TTS service created and started${NC}"
fi

# Install Node.js dependencies
echo ""
echo "Installing Node.js dependencies..."
cd "$(dirname "$0")"
npm install
echo -e "${GREEN}✓ Dependencies installed${NC}"

# Create .env if not exists
echo ""
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo -e "${YELLOW}⚠ Please edit .env file with your configuration${NC}"
    echo -e "${YELLOW}  Especially: OPENAI_API_KEY${NC}"
else
    echo -e "${GREEN}✓ .env file already exists${NC}"
fi

# Create directories
echo ""
echo "Creating directories..."
mkdir -p logs audio
chown -R $SUDO_USER:$SUDO_USER logs audio
echo -e "${GREEN}✓ Directories created${NC}"

# Configure Asterisk
echo ""
read -p "Configure Asterisk? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Backing up Asterisk configuration..."
    cp /etc/asterisk/extensions.conf /etc/asterisk/extensions.conf.backup 2>/dev/null || true
    cp /etc/asterisk/sip.conf /etc/asterisk/sip.conf.backup 2>/dev/null || true
    cp /etc/asterisk/manager.conf /etc/asterisk/manager.conf.backup 2>/dev/null || true
    
    echo "Copying new configuration..."
    cp asterisk/extensions.conf /etc/asterisk/
    cp asterisk/sip.conf /etc/asterisk/
    cp asterisk/manager.conf /etc/asterisk/
    
    echo -e "${YELLOW}⚠ Please edit /etc/asterisk/manager.conf and set a secure password${NC}"
    echo -e "${YELLOW}⚠ Please edit /etc/asterisk/sip.conf and adjust IP addresses${NC}"
    
    echo "Reloading Asterisk..."
    asterisk -rx "dialplan reload"
    asterisk -rx "sip reload"
    asterisk -rx "manager reload"
    
    echo -e "${GREEN}✓ Asterisk configured${NC}"
fi

# Create systemd service
echo ""
read -p "Install JSAIAgent as systemd service? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Creating systemd service..."
    INSTALL_DIR=$(pwd)
    cat > /etc/systemd/system/jsaiagent.service <<EOF
[Unit]
Description=JSAIAgent - AI Phone Agent
After=network.target asterisk.service coqui-tts.service
Requires=asterisk.service

[Service]
Type=simple
User=$SUDO_USER
WorkingDirectory=$INSTALL_DIR
Environment=NODE_ENV=production
ExecStart=/usr/bin/node src/index.js
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable jsaiagent
    echo -e "${GREEN}✓ Service created${NC}"
    echo -e "${YELLOW}⚠ Service not started yet. Start with: sudo systemctl start jsaiagent${NC}"
fi

# Summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Installation Complete!                                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Next steps:"
echo "1. Edit .env file with your OpenAI API key"
echo "2. Edit /etc/asterisk/manager.conf with secure password"
echo "3. Edit /etc/asterisk/sip.conf with your network settings"
echo "4. Update .env with Asterisk password"
echo ""
echo "Start services:"
echo "  sudo systemctl start jsaiagent"
echo "  sudo systemctl status jsaiagent"
echo ""
echo "Test:"
echo "  Register SIP client with extension 1000"
echo "  Call extension 5000"
echo ""
echo "Logs:"
echo "  tail -f logs/combined.log"
echo "  sudo journalctl -u jsaiagent -f"
echo ""
echo -e "${GREEN}Have fun with your AI Phone Agent!${NC}"
