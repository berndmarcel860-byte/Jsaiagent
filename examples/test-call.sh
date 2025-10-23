#!/bin/bash

# Test script to simulate a call from extension 1000 to 5000
# Requires Asterisk CLI access

echo "Testing JSAIAgent..."
echo "Simulating call from Extension 1000 to Extension 5000"
echo ""

# Check if Asterisk is running
if ! pgrep -x "asterisk" > /dev/null; then
    echo "Error: Asterisk is not running"
    exit 1
fi

# Originate call
echo "Originating call..."
asterisk -rx "channel originate SIP/1000 extension 5000@internal"

echo ""
echo "Call initiated. Check Asterisk CLI for details:"
echo "  sudo asterisk -rvvv"
echo ""
echo "Or check JSAIAgent logs:"
echo "  tail -f logs/combined.log"
