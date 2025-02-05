#!/bin/bash

# Script: KAS Version Upgrade Manager
# Description: Manages KAS tool version upgrades with safety checks
# Author: Sandesh Ghimire
# Date: Current
# Version: 2.0

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Define minimum required version
MIN_VERSION="4.7"

# Setup logging
LOG_FILE="/tmp/kas_upgrade_$(date +%Y%m%d_%H%M%S).log"
exec 1> >(tee -a "$LOG_FILE")
exec 2>&1

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to check if pip3 is installed
check_pip() {
    if ! command -v pip3 &>/dev/null; then
        echo -e "${RED}Error: pip3 is not installed${NC}"
        log "pip3 not found. Please install python3-pip"
        exit 1
    fi
}

# Function to validate version number
validate_version() {
    if [[ ! $1 =~ ^[0-9]+\.[0-9]+$ ]]; then
        echo -e "${RED}Error: Invalid version format detected${NC}"
        log "Invalid version format: $1"
        exit 1
    fi
}

# Main execution starts here
log "Starting KAS upgrade check"
check_pip

# Get current KAS version with error handling
if ! current_version=$(kas --version 2>/dev/null | grep -oP '\d+\.\d+'); then
    echo -e "${RED}Error: Failed to get current KAS version${NC}"
    log "Failed to get KAS version"
    exit 1
fi

validate_version "$current_version"
log "Current KAS version: $current_version"

# Compare versions
if (($(echo "$current_version < $MIN_VERSION" | bc -l))); then
    echo -e "${YELLOW}Current KAS version ($current_version) is lower than $MIN_VERSION. Upgrading...${NC}"
    log "Starting upgrade process"

    # Create backup of current configuration
    if [ -f ~/.kas ]; then
        backup_file="kas_config_backup_$(date +%Y%m%d_%H%M%S)"
        cp ~/.kas "$backup_file"
        log "Configuration backup created: $backup_file"
    fi

    # Upgrade KAS using pip with error handling
    if pip3 install --upgrade "kas>=$MIN_VERSION"; then
        # Verify new version
        new_version=$(kas --version | grep -oP '\d+\.\d+')
        validate_version "$new_version"

        echo -e "${GREEN}KAS successfully upgraded to version $new_version${NC}"
        log "Upgrade successful: $new_version"
    else
        echo -e "${RED}Error: Upgrade failed${NC}"
        log "Upgrade failed"
        exit 1
    fi
else
    echo -e "${GREEN}Current KAS version ($current_version) is $MIN_VERSION or higher. No upgrade needed.${NC}"
    log "No upgrade required"
fi

log "Script completed successfully"
