#!/bin/bash

set -e

#==============================================================================
# CLAUDE RUN FUNCTION WITH RETRIES
#==============================================================================

# Run claude with retry logic (safe mode aware)
# Usage: run_claude "prompt" "PHASE_NAME"
run_claude() {
    local user_prompt="$1"
    local phase="${2:-UNKNOWN}"
    local save_mode="${3:-false}"

    local attempt=1
    local exit_code
    local output

    #----------------------------------------------------------------------------
    # APPEND verbose output rules to ALL prompts (at end = more prominent)
    local prompt="$user_prompt

$(get_verbose_output_rules)"
    #----------------------------------------------------------------------------

    local prompt_size=${#prompt}

    log "INFO" "Starting $phase phase (prompt: $prompt_size bytes)"

    while [[ $attempt -le $MAX_RETRIES ]]; do
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
                claude -p --dangerously-skip-permissions "$prompt" 2>&1)
            exit_code=$?
        else
            # Run on host (existing behavior), capture output
            output=$(claude -p --dangerously-skip-permissions "$prompt" 2>&1)
            exit_code=$?
        fi

        if [[ $exit_code -eq 0 ]]; then
            # Output the result (so it still shows on screen)
            echo "$output"
            log "INFO" "$phase phase completed successfully"
            return 0
        fi

        # Check for the specific streaming error
        if echo "$output" | grep -q "only prompt commands are supported in streaming mode"; then
            log "ERROR" "$phase: Got 'streaming mode' error (attempt $attempt)"
            echo -e "${YELLOW}  Claude failed (attempt $attempt/$MAX_RETRIES, exit code $exit_code)${NC}"
            echo -e "${RED}  Error: 'only prompt commands are supported in streaming mode'${NC}"
        else
            echo -e "${YELLOW}  Claude failed (attempt $attempt/$MAX_RETRIES, exit code $exit_code)${NC}"
        fi

        # Log failure details including the actual prompt
        log_failure "$phase" "$attempt" "$exit_code" "$output" "$prompt_size" "$prompt"

        if [[ $attempt -lt $MAX_RETRIES ]]; then
            echo -e "${YELLOW}  Retrying in ${RETRY_DELAY}s...${NC}"
            sleep $RETRY_DELAY
        fi

        ((attempt++))
    done

    echo -e "${RED}  All $MAX_RETRIES attempts failed${NC}"
    log "ERROR" "$phase phase failed after $MAX_RETRIES attempts"
    return 1
}

#==============================================================================
# Export functions
export -f run_claude