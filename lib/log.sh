#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Logging (use absolute path to survive worktree cd)
LOG_DIR="$PROJECT_BJARNE_DIR/logs"
LOG_FILE="$LOG_DIR/bjarne.log"

#==============================================================================
# Log function

log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local log_content="[$timestamp] [$level] $msg"
    echo "$log_content" >> "$LOG_FILE"
}

#==============================================================================
# Export variables
export GREEN
export YELLOW
export BLUE
export RED
export CYAN
export NC

export LOG_DIR
export LOG_FILE

#==============================================================================
# Export functions
export -f log