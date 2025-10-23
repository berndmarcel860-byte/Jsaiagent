#!/bin/bash

# System Check Script for JSAIAgent
# Verifies all dependencies and configurations

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   JSAIAgent System Check                                   ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Helper functions
check_command() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✓${NC} $2 found"
        return 0
    else
        echo -e "${RED}✗${NC} $2 not found"
        ((ERRORS++))
        return 1
    fi
}

check_port() {
    if netstat -tuln 2>/dev/null | grep -q ":$1 "; then
        echo -e "${GREEN}✓${NC} Port $1 is in use ($2)"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} Port $1 is not in use ($2)"
        ((WARNINGS++))
        return 1
    fi
}

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $2 exists"
        return 0
    else
        echo -e "${RED}✗${NC} $2 not found"
        ((ERRORS++))
        return 1
    fi
}

check_service() {
    if systemctl is-active --quiet $1 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $2 is running"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $2 is not running"
        ((WARNINGS++))
        return 1
    fi
}

# Check Node.js
echo -e "${BLUE}=== Checking Node.js ===${NC}"
if check_command node "Node.js"; then
    VERSION=$(node --version)
    MAJOR_VERSION=$(echo $VERSION | cut -d'.' -f1 | sed 's/v//')
    if [ "$MAJOR_VERSION" -ge 18 ]; then
        echo "  Version: $VERSION (OK)"
    else
        echo -e "  ${YELLOW}Warning: Node.js version $VERSION (< 18 recommended)${NC}"
        ((WARNINGS++))
    fi
fi
check_command npm "npm"
echo ""

# Check Asterisk
echo -e "${BLUE}=== Checking Asterisk ===${NC}"
if check_command asterisk "Asterisk"; then
    if check_service asterisk "Asterisk service"; then
        echo "  $(asterisk -V)"
    fi
fi
echo ""

# Check Python and TTS
echo -e "${BLUE}=== Checking Python & TTS ===${NC}"
check_command python3 "Python 3"
check_command pip3 "pip3"
if command -v tts &> /dev/null; then
    echo -e "${GREEN}✓${NC} Coqui TTS installed"
else
    echo -e "${YELLOW}⚠${NC} Coqui TTS not installed"
    ((WARNINGS++))
fi
echo ""

# Check ports
echo -e "${BLUE}=== Checking Ports ===${NC}"
check_port 4573 "AGI Server"
check_port 5002 "Coqui TTS"
check_port 5038 "Asterisk AMI"
check_port 5060 "Asterisk SIP"
echo ""

# Check configuration files
echo -e "${BLUE}=== Checking Configuration Files ===${NC}"
check_file ".env" ".env configuration file"
check_file "package.json" "package.json"
check_file "src/index.js" "Main application file"
check_file "asterisk/extensions.conf" "Asterisk extensions.conf"
check_file "asterisk/sip.conf" "Asterisk sip.conf"
check_file "asterisk/manager.conf" "Asterisk manager.conf"
echo ""

# Check environment variables
echo -e "${BLUE}=== Checking Environment Variables ===${NC}"
if [ -f .env ]; then
    source .env 2>/dev/null || true
    
    if [ -n "$OPENAI_API_KEY" ]; then
        echo -e "${GREEN}✓${NC} OPENAI_API_KEY is set"
    else
        echo -e "${RED}✗${NC} OPENAI_API_KEY is not set"
        ((ERRORS++))
    fi
    
    if [ -n "$ASTERISK_PASSWORD" ]; then
        echo -e "${GREEN}✓${NC} ASTERISK_PASSWORD is set"
    else
        echo -e "${YELLOW}⚠${NC} ASTERISK_PASSWORD is not set"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}✗${NC} .env file not found"
    ((ERRORS++))
fi
echo ""

# Check Node modules
echo -e "${BLUE}=== Checking Node.js Dependencies ===${NC}"
if [ -d "node_modules" ]; then
    echo -e "${GREEN}✓${NC} node_modules directory exists"
    
    # Check critical packages
    PACKAGES=("openai" "agi" "winston" "dotenv" "axios")
    for pkg in "${PACKAGES[@]}"; do
        if [ -d "node_modules/$pkg" ]; then
            echo -e "${GREEN}✓${NC} $pkg installed"
        else
            echo -e "${RED}✗${NC} $pkg not installed"
            ((ERRORS++))
        fi
    done
else
    echo -e "${RED}✗${NC} node_modules not found"
    echo "  Run: npm install"
    ((ERRORS++))
fi
echo ""

# Check logs directory
echo -e "${BLUE}=== Checking Directories ===${NC}"
[ -d "logs" ] && echo -e "${GREEN}✓${NC} logs directory exists" || (echo -e "${YELLOW}⚠${NC} logs directory missing"; ((WARNINGS++)))
[ -d "audio" ] && echo -e "${GREEN}✓${NC} audio directory exists" || (echo -e "${YELLOW}⚠${NC} audio directory missing"; ((WARNINGS++)))
echo ""

# Check Asterisk configuration
echo -e "${BLUE}=== Checking Asterisk Configuration ===${NC}"
if [ -f "/etc/asterisk/extensions.conf" ]; then
    if grep -q "5000" /etc/asterisk/extensions.conf; then
        echo -e "${GREEN}✓${NC} Extension 5000 configured in Asterisk"
    else
        echo -e "${YELLOW}⚠${NC} Extension 5000 not found in Asterisk config"
        ((WARNINGS++))
    fi
fi

if [ -f "/etc/asterisk/sip.conf" ]; then
    if grep -q "\[1000\]" /etc/asterisk/sip.conf; then
        echo -e "${GREEN}✓${NC} Extension 1000 configured in Asterisk"
    else
        echo -e "${YELLOW}⚠${NC} Extension 1000 not found in Asterisk config"
        ((WARNINGS++))
    fi
fi
echo ""

# Network connectivity test
echo -e "${BLUE}=== Checking Network Connectivity ===${NC}"
if curl -s --max-time 5 https://api.openai.com > /dev/null; then
    echo -e "${GREEN}✓${NC} Can reach OpenAI API"
else
    echo -e "${RED}✗${NC} Cannot reach OpenAI API"
    ((ERRORS++))
fi

if [ -n "$COQUI_TTS_URL" ]; then
    if curl -s --max-time 5 $COQUI_TTS_URL > /dev/null; then
        echo -e "${GREEN}✓${NC} Can reach Coqui TTS Server"
    else
        echo -e "${YELLOW}⚠${NC} Cannot reach Coqui TTS Server at $COQUI_TTS_URL"
        ((WARNINGS++))
    fi
fi
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Summary                                                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo "  You're ready to start JSAIAgent!"
    echo ""
    echo "  Start with: npm start"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    echo "  System should work, but some features might be limited."
    echo ""
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) and $WARNINGS warning(s) found${NC}"
    echo "  Please fix the errors before starting JSAIAgent."
    echo ""
    echo "Quick fixes:"
    [ $ERRORS -gt 0 ] && echo "  - Run: npm install"
    [ ! -f .env ] && echo "  - Copy .env.example to .env and configure"
    [ -z "$OPENAI_API_KEY" ] && echo "  - Set OPENAI_API_KEY in .env"
    echo ""
    exit 1
fi
