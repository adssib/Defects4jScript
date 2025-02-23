#!/bin/bash

# if we are adding a '-x' if will print some intresting results 

# Exit script on error
set -e

if [ "@?" -ne 0] ; then 
    log ERROR "no parameters were supplied"
    help()
fi 

for arg in "$@";
do
    case "$arg" in
        -h) help()

    esac
done 
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

help() {
    log INFO "idk how to use my script either" 
    exit 1
}
log() {
    local level=$1
    local message=$2
    case $level in
        SUCCESS) echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
        INFO) echo -e "${WHITE}[INFO]${NC} $message" ;;
        WARNING) echo -e "${YELLOW}[WARNING]${NC} $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $message" ;;
        LOADING) echo -e "${BLUE}[LOADING]${NC} $message" ;;
        DEBUG) echo -e "${CYAN}[DEBUG]${NC} $message" ;;
        *) echo -e "${WHITE}[UNKNOWN]${NC} $message" ;;  
    esac
}

check_package() {
    local package=$1
    if ! command -v "$package" &> /dev/null; then
        log WARNING "'$package' is not installed!"
        log LOADING "Installing '$package'..."
        sudo apt-get install -y "$package"
        log SUCCESS "'$package' installed successfully!"
    else
        log SUCCESS "'$package' is already installed"
    fi
}

log INFO "Checking required packages..."
check_package bzip2
