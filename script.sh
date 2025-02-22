#!/bin/bash

# Exit script on error
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No color

# Ensure bzip2 is installed
echo -e "${YELLOW}INFO:${NC} checking is wanted packages are installed"

if ! command -v bzip2 &> /dev/null; then
    echo ""
    echo -e "${RED}Warning:${NC} 'bzip2' is not installed!"
    sudo apt-get install -y bzip2
else 
    echo ""
    echo -e "${GREEN}INFO:${NC} 'bzip2' is intalled"
fi