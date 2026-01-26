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
DEFAULT_LOG_FILE_SUFFIX="${BJARNE_EXECUTE_SCENE:+-${BJARNE_EXECUTE_SCENE}}"
LOG_DIR="$PROJECT_BJARNE_DIR/logs"
# 默认的日志文件
LOG_FILE="$LOG_DIR/bjarne${DEFAULT_LOG_FILE_SUFFIX}.log"
# AI参数和响应记录文件
LOG_FILE_AI_PARAM_RESP="$LOG_DIR/bjarne${DEFAULT_LOG_FILE_SUFFIX}-AI-ParamResp.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

#==============================================================================
# Log function

inner_log() {
    local level="$1"
    local msg="$2"
    local file_path="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local log_content="[$timestamp] [$level] $msg"

    if [ -z "$file_path" ]; then
        echo "$log_content"
    else
        echo "$log_content" >> "$file_path"
    fi
}

log() {
    inner_log "$1" "$2" "$LOG_FILE"
}

log_ai_param() {
    local request_id="$1"
    local msg="$2"
    local new_msg="=== AI PARAM [request_id=$request_id] ===
$msg
=========================
"
    inner_log "INFO" "$new_msg" "$LOG_FILE_AI_PARAM_RESP"
}

log_ai_response() {
    local request_id="$1"
    local msg="$2"
    local new_msg="=== AI RESPONSE [request_id=$request_id] ===
$msg
=========================
"
    inner_log "INFO" "$new_msg" "$LOG_FILE_AI_PARAM_RESP"
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
export -f log_ai_param
export -f log_ai_response