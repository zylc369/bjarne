#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

# 根据错误输出不同的信息
# 返回值:
# 0: 无错误
# 1: 一般错误
# 2: API 5小时使用上限错误
# 3: 流式模式错误
inner_log_with_error_output() {
    local phase="$1"
    local attempt="$2"
    local exit_code="$3"
    local output="$4"

    # Check for the specific streaming error
    if echo "$output" | grep -qi "only prompt commands are supported in streaming mode"; then
        log "ERROR" "❌ [$phase] Claude failed, streaming mode error on attempt $attempt/$MAX_RETRIES (exit: $exit_code, output=${output:0:200}...), detail logged in $LOG_FILE_AI_PARAM_RESP"
        return 3  # Special return code for streaming mode error
    fi

    # Check if the failure is due to API X-hour limit
    if echo "$output" | grep -qi "5.*hour.*limit\|limit.*reached.*try.*back\|usage.*limit.*reached\|小时.*使用上限"; then
        log "ERROR" "🚫 Claude API X-hour usage limit reached, output=${output:0:200}...), detail logged in $LOG_FILE_AI_PARAM_RESP"
        return 2  # Special return code for API limit
    fi

    log "ERROR" "❌ [$phase] Claude failed (attempt $attempt/$MAX_RETRIES, exit code $exit_code, output=${output:0:200}...), detail logged in $LOG_FILE_AI_PARAM_RESP"
    return 1
}

#==============================================================================
# CLAUDE RUN FUNCTION WITH RETRIES
#==============================================================================

# Run claude with retry logic (safe mode aware)
# Usage: run_claude "prompt" "PHASE_NAME"
run_claude() {    
    # 设置默认值
    local user_prompt=""
    local phase="UNKNOWN"
    local session_is_new="false"
    local session_id=""
    local save_mode="false"
    local loop_count=""
    local disable_verbose_output_rules_prompt="false"

    while [ $# -gt 0 ]; do
        case "$1" in
            "user_prompt")       user_prompt="$2"; shift 2 ;;
            "phase")             phase="$2"; shift 2 ;;
            "session_is_new")    session_is_new="$2"; shift 2 ;;
            "session_id")        session_id="$2"; shift 2 ;;
            "save_mode")         save_mode="$2"; shift 2 ;;
            "loop_count")        loop_count="$2"; shift 2 ;;
            "disable_verbose_output_rules_prompt")
                disable_verbose_output_rules_prompt="true"
                shift 1
                ;;
            *)
                log "ERROR" "Warning: unknown parameter '$1'" >&2
                shift 2
                return 1
                ;;
        esac
    done

    # 检查 claude 命令是否可用
    if ! command -v claude &>/dev/null; then
        log "ERROR" "错误: 'claude' 命令未找到" >&2
        log "ERROR" "请确保 Anthropic CLI 已正确安装" >&2
        log "ERROR" "安装方法: npm install -g @anthropic-ai/claude" >&2
        return 1
    fi

    local attempt=1
    local exit_code
    local output

    #----------------------------------------------------------------------------
    # APPEND verbose output rules to ALL prompts (at end = more prominent)
    local prompt="$user_prompt"
    if [[ "$disable_verbose_output_rules_prompt" != "true" ]]; then
        prompt="${prompt}

$(get_verbose_output_rules "$BJARNE_TMP_DIR")"
    fi
    #----------------------------------------------------------------------------

    local prompt_size=${#prompt}

    local claude_args=("-p" "--dangerously-skip-permissions")
    if [[ "$session_is_new" == "true" ]]; then
        claude_args+=("--session-id" "$session_id")
    else
        if [[ -n "$session_id" ]]; then
            claude_args+=("-r" "$session_id")
        else
            log "WARNING" "没有指定session ID，继续使用Claude的默认会话管理"
        fi
    fi
    claude_args+=("$prompt")

    log "INFO" "Starting $phase phase (session_is_new: $session_is_new, session_id: $session_id, save_mode: $save_mode, prompt_size: $prompt_size bytes)"

    while [[ $attempt -le $MAX_RETRIES ]]; do
        log "INFO" "[run_claude] Attempt $attempt for $phase phase"

        local request_id="${session_id}#${phase}#${loop_count}#${attempt}"
        log_ai_param "$request_id" "$(printf "%s\n" "${claude_args[@]}")"

        if [[ "$save_mode" == true ]]; then
            # Run in Docker container (as 'bjarne' user, not root)
            local docker_args="-v $(pwd):/workspace"
            docker_args+=" -v $HOME/.claude/.credentials.json:/home/bjarne/.claude/.credentials.json:ro"

            # Add gh CLI config if available (for PR creation in task mode)
            if [[ -d "$HOME/.config/gh" ]]; then
                docker_args+=" -v $HOME/.config/gh:/home/bjarne/.config/gh:ro"
            fi

            # Add gitconfig if available (for commits)
            if [[ -f "$HOME/.gitconfig" ]]; then
                docker_args+=" -v $HOME/.gitconfig:/home/bjarne/.gitconfig:ro"
            fi

            # Add dependency volume if applicable
            local dep_volume=$(get_dep_volume)
            if [[ -n "$dep_volume" ]]; then
                docker_args+=" -v $dep_volume"
            fi

            # Mount temp folder for verbose output logs (same path inside container)
            docker_args+=" -v $BJARNE_TMP_DIR:$BJARNE_TMP_DIR"

            # Capture both stdout and stderr
            # Run as host user's UID/GID so mounted files have correct permissions
            output=$(docker run --rm --user "$(id -u):$(id -g)" -e HOME=/home/bjarne \
                $docker_args -w /workspace "$SAFE_MODE_IMAGE_NAME" \
                claude "${claude_args[@]}" 2>&1)
            exit_code=$?
        else
            # 保存原有的ERR和INT信号处理
            local old_trap_err=$(trap -p ERR)
            local old_trap_int=$(trap -p INT)

            # 设置错误处理
            trap 'echo "在文件 claude.sh 中出错: 第 $LINENO 行，状态: $?" >&2' ERR
            # 设置Ctrl+C处理
            trap 'echo -e "\n检测到Ctrl+C，正在终止..." >&2; exit 130' INT

            # Run on host (existing behavior), capture output
            # -p: 打印响应并退出（适用于管道操作）。注意：当Claude以-p模式运行时，会跳过工作区信任对话框。请仅在受信任的目录中使用此标志。
            # --dangerously-skip-permissions: 绕过所有权限检查。建议仅在无网络访问的沙箱环境中使用。
            output=$(claude "${claude_args[@]}" 2>&1)
            exit_code=$?

            # 恢复之前的trap
            eval "$old_trap_err"
            eval "$old_trap_int"
        fi

        if [[ $exit_code -eq 0 ]]; then
            # Output the result (so it still shows on screen)
            log_ai_response "SUCCESS" "$request_id" "$output"
            log "INFO" "$phase phase completed successfully"
            return 0
        fi

        #------------------------------------------------------------
        # 打印错误信息

        inner_log_with_error_output "$phase" "$attempt" "$exit_code" "$output"
        local error_type=$?
        if [[ $error_type -eq 2 ]]; then
            # API X-hour limit reached, no point retrying
            return 2
        elif [[ $error_type -eq 3 ]]; then
            # Streaming mode error, no point retrying
            return 3
        fi

        # Log failure details including the actual prompt
        claude_failure_msg_array=("=== BJARNE FAILURE LOG ===")
        claude_failure_msg_array+=("Phase: $phase")
        claude_failure_msg_array+=("Attempt: $attempt/$MAX_RETRIES")
        claude_failure_msg_array+=("Exit Code: $exit_code")
        claude_failure_msg_array+=("Prompt Size: $prompt_size bytes")
        claude_failure_msg_array+=("Working directory: $(pwd)")
        claude_failure_msg_array+=("Safe mode: $SAFE_MODE")
        claude_failure_msg_array+=("")
        claude_failure_msg_array+=("=== CLAUDE OUTPUT ===")
        claude_failure_msg_array+=("$output")
        claude_failure_msg_array+=("")
        claude_failure_msg_array+=("=== CURRENT .task FILE (if exists) ===")
        if [[ -f "$TASK_STATE" ]]; then
            claude_failure_msg_array+=("Path: $TASK_STATE")
        else
            claude_failure_msg_array+=("(no .task file)")
        fi
        log_ai_response "ERROR" "$request_id" "$(printf "%s\n" "${claude_failure_msg_array[@]}")"

        #------------------------------------------------------------

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            log "Error" "[run_claude] $phase phase failed on attempt $attempt, will retry in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        fi

        ((attempt++))
    done

    log "ERROR" "[run_claude] $phase phase failed after $MAX_RETRIES attempts"
    return 1
}

#==============================================================================
# Export functions
export -f run_claude