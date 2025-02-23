#!/bin/bash
# if we are adding a '-x' if will print some intresting results 
# Exit script on error
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
NC='\033[0m'

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

if [ "$EUID" -ne 0 ]
  then log ERROR "Please run as root"
  exit
fi

targetDefects4j="/home/adssib/345/defects4j"  # Fixed path
checkPackage() {
    local package=$1
    if ! command -v "$package" &> /dev/null; then
        log WARNING "'$package' is not installed!"
    else
        log SUCCESS "'$package' is already installed"
    fi
}


doctor() {
    log INFO "Checking required packages..."
    checkPackage bzip2
    checkPackage defects4j
}

fixPackages() {
    local package=$1
    if [[ "$package" == "defects4j" ]]; then
        log WARNING "defects4j is not installed" 
        cd "$targetDefects4j" || { log ERROR "Failed to change directory to $targetDefects4j"; exit 1; }
        log INFO "going inside of '$PWD'"
        log LOADING "initialting the script" 
        ./init.sh
    else
        log LOADING "Installing '$package'..."
        sudo apt-get install -y "$package"
        log SUCCESS "'$package' installed successfully!"
        log SUCCESS "'$package' is already installed"
    fi
}

comandHelp() {
    log INFO "idk how to use my script either" 
    exit 1
}

if [ "$#" -eq 0 ]; then 
    echo "Arguments received: $# -> $@"
    log ERROR "no parameters were supplied"
    comandHelp
fi

for arg in "$@";
do
    case "$arg" in
        -h) help ;;
        --doctor) doctor ;;
        -d) doctor ;;
        # -d --fix) 
        *) help ;;
    esac
done 
