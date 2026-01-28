#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

# 根据错误输出不同的信息
inner_log_with_error_output() {
    local phase="$1"
    local attempt="$2"
    local exit_code="$3"
    local output="$4"

    # Check for the specific streaming error
    if echo "$output" | grep -q "only prompt commands are supported in streaming mode"; then
        log "ERROR" "❌ [$phase] Claude failed, streaming mode error on attempt $attempt/$MAX_RETRIES (exit: $exit_code, output=${output:0:200}...)"
        return 3  # Special return code for streaming mode error
    fi

    # Check if the failure is due to API 5-hour limit
    if grep -qi "5.*hour.*limit\|limit.*reached.*try.*back\|usage.*limit.*reached\|小时*使用上限" "$output_file"; then
        log_status "ERROR" "🚫 Claude API 5-hour usage limit reached"
        return 2  # Special return code for API limit
    fi

    log "ERROR" "❌ [$phase] Claude failed (attempt $attempt/$MAX_RETRIES, exit code $exit_code, output=${output:0:200}...)"
    return 1
}

#==============================================================================
# CLAUDE RUN FUNCTION WITH RETRIES
#==============================================================================

# Run claude with retry logic (safe mode aware)
# Usage: run_claude "prompt" "PHASE_NAME"
run_claude() {
    local -n params_ref=$1  # 使用 nameref
    
    # 设置默认值
    local user_prompt="${params_ref[user_prompt]:-}"
    local phase="${params_ref[phase]:-UNKNOWN}"
    local session_is_new="${params_ref[session_is_new]:-false}"
    local session_id="${params_ref[session_id]:-}"
    local save_mode="${params_ref[save_mode]:-false}"
    local loop_count="${params_ref[loop_count]:-}"

    if [[ -n "$session_obj" ]]; then
        IFS=',' read -r session_is_new session_id <<< "$session_obj"
    fi

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
    local prompt="$user_prompt

$(get_verbose_output_rules $BJARNE_TMP_DIR)"
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
                $docker_args -w /workspace "$IMAGE_NAME" \
                claude "${claude_args[@]}" 2>&1)
            exit_code=$?
        else
             # 临时设置错误处理
            local old_trap=$(trap -p ERR)
            trap 'echo "在文件 claude.sh 中出错: 第 $LINENO 行，状态: $?" >&2' ERR

            # Run on host (existing behavior), capture output
            # -p: 打印响应并退出（适用于管道操作）。注意：当Claude以-p模式运行时，会跳过工作区信任对话框。请仅在受信任的目录中使用此标志。
            # --dangerously-skip-permissions: 绕过所有权限检查。建议仅在无网络访问的沙箱环境中使用。
            output=$(claude "${claude_args[@]}" 2>&1)
            exit_code=$?

            # 恢复之前的 trap
            eval "$old_trap"
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