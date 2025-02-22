#!/bin/bash

# Exit script on error
set -e

# Ensure bzip2 is installed
if ! command -v bzip2 &> /dev/null; then
    echo "Installing bzip2..."
    sudo apt-get install -y bzip2
else 
    echo "bzip2 is already nstalled"
fi