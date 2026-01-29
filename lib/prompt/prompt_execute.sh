#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

get_execute_prompt() {
    local task_file_path="${1:-$DEFAULT_CURRENT_TASK_FILE_PATH}"
    read -r -d '' prompt_content << EOF
# EXECUTE STEP

**IMPORTANT: This is step 2 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - just implement the plan
- Do NOT ask questions or request approval - execute the plan
- Be direct and factual - no conversational language needed

Read .task file. Follow the plan exactly.

.task file path: $task_file_path

**Your primary job is IMPLEMENTATION - use Write and Edit tools to create/modify files.**
The PLAN phase already researched the codebase. Trust the plan's EXISTING_CODE and PATTERNS.
You may read files when needed for implementation, but prioritize writing code over exploration.

## Rules
- Follow the PLAN steps in order
- REUSE code listed in EXISTING_CODE
- Follow PATTERNS for consistency
- Match existing code style in the project
- Clear names, no abbreviations
- Handle errors meaningfully

## Code Quality (adapt to project's tech stack)
- Keep functions focused (single responsibility)
- Keep files cohesive (related code together)
- Comments explain WHY not WHAT

## When Done
Mark the task complete in TASKS.md with a short note if you learned something useful:
- Simple completion: \`- [x] Task description\`
- With note: \`- [x] Task description → Note: [one-line insight]\`

Only add a note if it would help future tasks (e.g., "used X instead of Y", "requires Z first").

Then commit: "feat: [task description]"

## Directory and File Path
- Working directory: $BJARNE_PROJECT_ROOT
EOF
    
    echo "$prompt_content"
}

export -f get_execute_prompt