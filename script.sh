#!/bin/bash
# if we are adding a '-x' if will print some intresting results 
# Exit script on error
set -e

# the script is almost done I just need to add the fucking commands to run it correclty and stuff 

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
    local fix=$2

    if ! command -v "$package" &> /dev/null; then
        log WARNING "'$package' is not installed!"
        if [ "$package" == "defects4j" ]; then
            # Check if defects4j is installed by running `defects4j help`
            if ! defects4j help &> /dev/null; then
                log WARNING "'defects4j' is not installed or not accessible!"
                if [ "$fix" == "true" ]; then
                    fixPackages "$package"
                fi
            else
                log SUCCESS "'defects4j' is installed and accessible."
            fi
        else
            if [ "$fix" == "true" ]; then
                fixPackages "$package"
            fi
        fi
    else
        log SUCCESS "'$package' is already installed"
    fi
}


doctor() {
    local fixPackages=$1
    log INFO "Checking required packages..."
    if [ "$fixPackages" == "true" ]; then
       checkPackage bzip2 true
       checkPackage defects4j true
    else 
        checkPackage defects4j
        checkPackage bzip2 
    fi
}

fixPackages() {
    local package=$1
    if [[ "$package" == "defects4j" ]]; then
        log INFO "Fixing defects4j" 
        cd "$targetDefects4j" || { log ERROR "Failed to change directory to $targetDefects4j"; exit 1; }
        log INFO "going inside of '$PWD'"
        log LOADING "initialting the script" 
        ./init.sh
        export PATH=$PATH:$targetDefects4j/framework/bin
        checkPackage defects4j
    else
        log LOADING "Installing '$package'..."
        sudo apt-get install -y "$package"
        log SUCCESS "'$package' installed successfully!"
    fi
}

# checkout : -p -v -w 
# coverage : nothing for normal, -s for a test generated suite  
# mutation : here we have to check if the version number is fixed or not 
# gen_tests : -g -n -o -b 
PROJECT_NAME=""
VERSION=""
WORKING_DIR=""
B_VALUE=""

commandHelp() {
    log INFO "Usage of the script:"
    echo " -d, --doctor      : Check for required packages"
    echo " --fix-packages    : Attempt to fix missing packages"
    echo " -h                : Show this help menu"
    exit 1
}

if [ "$#" -eq 0 ]; then 
    echo "Arguments received: $# -> $@"
    log ERROR "no parameters were supplied"
    comandHelp
fi

fix=false
doctor_flag=false

# Loop through all arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p) PROJECT_NAME="$2"; shift 2 ;;  # Shift past argument and value
        -v) VERSION="$2"; shift 2 ;;
        -w) WORKING_DIR="$2"; shift 2 ;;
        -b) B_VALUE="$2"; shift 2 ;;
        -d|--doctor) doctor_flag=true; shift ;;
        --fix-packages) fix=true; shift ;;
        -h) commandHelp ;;
        *) log ERROR "Unknown argument: $1"; commandHelp ;;
    esac
done

# if [[ -z "$PROJECT_NAME" || -z "$VERSION" || -z "$WORKING_DIR" || -z "$B_VALUE" ]]; then
#     log ERROR "Missing required parameters!"
#     commandHelp
# fi

# Check if we need to call the doctor function
if [ "$doctor_flag" == true ]; then
    if [ "$fix" == true ]; then
        doctor true   # If both doctor and --fix are provided, fix packages
    else
        doctor false  # Just check packages without fixing
    fi
fi

# log INFO "Project Name: $PROJECT_NAME"
# log INFO "Version: $VERSION"
# log INFO "Working Directory: $WORKING_DIR"
# log INFO "B Value: $B_VALUE"