#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

# Colors
LOG_COLOR_GREEN='\033[0;32m'
LOG_COLOR_YELLOW='\033[1;33m'
# LOG_COLOR_BLUE='\033[0;34m'
LOG_COLOR_BLUE='\033[94m'
LOG_COLOR_RED='\033[0;31m'
LOG_COLOR_CYAN='\033[0;36m'
LOG_COLOR_NC='\033[0m'

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
    local output_to_terminal="${4:-true}"

    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local color=""
    
    case $level in
        # "INFO")  color=$LOG_COLOR_BLUE ;;
        "WARN")  color=$LOG_COLOR_YELLOW ;;
        "ERROR") color=$LOG_COLOR_RED ;;
        "SUCCESS") color=$LOG_COLOR_GREEN ;;
        "LIGHT")
            color=$LOG_COLOR_CYAN
            level="INFO"
            ;;
        "LIGHT2")
            color=$LOG_COLOR_YELLOW
            level="INFO"
            ;;
        "LIGHT3")
            color=$LOG_COLOR_BLUE
            level="INFO"
            ;;
    esac

    local log_content="[$timestamp] [$level] $msg"

    if [[ "$output_to_terminal" == "true" ]]; then
        echo -e "${color}${log_content}${LOG_COLOR_NC}"
    fi

    if [ -n "$file_path" ]; then
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
    inner_log "INFO" "$new_msg" "$LOG_FILE_AI_PARAM_RESP" "false"
    log "INFO" "=== AI PARAM [request_id=$request_id] ==="
}

log_ai_response() {
    local level="$1"
    local request_id="$2"
    local msg="$3"
    local new_msg="=== AI RESPONSE [request_id=$request_id] ===
$msg
=========================
"
    inner_log "$level" "$new_msg" "$LOG_FILE_AI_PARAM_RESP" "false"
    log "$level" "=== AI RESPONSE [request_id=$request_id] ==="
}

#==============================================================================
# Export variables

export LOG_DIR
export LOG_FILE

export LOG_FILE_AI_PARAM_RESP

#==============================================================================
# Export functions
export -f log
export -f log_ai_param
export -f log_ai_response