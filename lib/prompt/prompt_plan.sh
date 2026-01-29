#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

get_plan_prompt() {
    read -r -d '' prompt_content << EOF
# PLAN STEP

**IMPORTANT: This is step 1 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - your output feeds into the next step
- Do NOT ask questions or request clarification - work with what you have
- Be direct and factual - no conversational language needed

You are planning ONE task from TASKS.md.

## Your Job
1. Read CONTEXT.md for project info and commands
2. Read TASKS.md - find the FIRST unchecked \`- [ ]\` task
   - **CRITICAL**: Only plan tasks marked \`- [ ]\` (unchecked)
   - Skip any task marked \`- [x]\` (already complete)
3. **Parse the task**: Extract ACTION and OUTCOME (format: \`Action → Outcome\`)
4. Read specs/ folder for detailed specifications
5. Search the codebase for existing patterns, utilities, components
6. Write a plan to .task file

## STOP: Verify Task Is Actually Unchecked
Before planning, CONFIRM the task line starts with \`- [ ]\` (space between brackets).
If it starts with \`- [x]\`, it's ALREADY DONE - do not plan it, do not create .task file.

## Write to .task file:
\`\`\`
TASK: [exact task text from TASKS.md]
ACTION: [what to implement]
EXPECTED_OUTCOME: [how to verify success - from the → part]

EXISTING_CODE:
- [file/function to reuse]

PATTERNS:
- [pattern from codebase to follow]

PLAN:
1. [specific step]
2. [specific step]

FILES_TO_CREATE: [list]
FILES_TO_MODIFY: [list]
TEST_COMMAND: [from CONTEXT.md or detected]

OUTCOME_VERIFICATION:
- [specific check to confirm outcome, e.g., "grep for button with href=/login"]
- [curl command, file check, or code inspection to verify]
\`\`\`

## Architecture Principles
- REUSE existing code - search first
- EXTEND existing files when logical
- ONE clear responsibility per file
- Follow existing patterns in codebase
- Match existing code style

## Directory and File Path
- Working directory: \`$BJARNE_PROJECT_ROOT\`
- .task → In working directory

DO NOT implement unless explicitly asked. Just plan.
EOF
    
    echo "$prompt_content"
}

get_batch_plan_prompt() {
    local batch_size="$1"
    cat << BATCH_PLAN_EOF
# PLAN STEP (Batch Mode)

**IMPORTANT: This is step 1 of 4 in an automated pipeline (PLAN → EXECUTE → REVIEW → FIX).**
- There is NO human in the loop - your output feeds into the next step
- Do NOT ask questions or request clarification - work with what you have
- Be direct and factual - no conversational language needed

You are planning UP TO $batch_size RELATED tasks from TASKS.md.

## Your Job
1. Read CONTEXT.md for project info and commands
2. Read TASKS.md - scan ALL unchecked \`- [ ]\` tasks
3. **Identify naturally related tasks** - look for:
   - Tasks that touch the same file(s)
   - Tasks that are part of the same feature/component
   - Tasks that have logical dependencies (do A before B)
   - Tasks that share the same patterns/utilities
4. **Select UP TO $batch_size tasks** that make sense to do together
   - Could be 1 task if it's standalone
   - Could be 2-5 if they're tightly related
   - Don't force grouping - only batch what naturally belongs together
5. Read specs/ folder for detailed specifications
6. Search the codebase for existing patterns, utilities, components
7. Write a plan to .task file

## STOP: Verify Tasks Are Actually Unchecked
Before planning, CONFIRM each task line starts with \`- [ ]\` (space between brackets).
Skip any task marked \`- [x]\` (already complete).

## Write to .task file:
\`\`\`
TASKS:
- [exact task 1 text from TASKS.md]
- [exact task 2 text, if batching]
- [etc.]

EXPECTED_OUTCOMES:
- Task 1: [how to verify success - from the → part]
- Task 2: [verification for task 2]

EXISTING_CODE:
- [file/function to reuse]

PATTERNS:
- [pattern from codebase to follow]

PLAN:
1. [specific step - note which task(s) it addresses]
2. [specific step]

FILES_TO_CREATE: [list]
FILES_TO_MODIFY: [list]
TEST_COMMAND: [from CONTEXT.md or detected]

OUTCOME_VERIFICATION:
- Task 1: [specific check, e.g., "grep for button with href=/login"]
- Task 2: [verification for task 2]
\`\`\`

## Grouping Guidelines
- **DO batch**: All CRUD operations for one model, all UI components for one page, related API endpoints
- **DON'T batch**: Unrelated features, tasks in different areas of codebase, tasks with no shared context
- **When in doubt**: Smaller batches are fine. Quality over quantity.

## Architecture Principles
- REUSE existing code - search first
- EXTEND existing files when logical
- ONE clear responsibility per file
- Follow existing patterns in codebase
- Match existing code style

DO NOT implement. Just plan.
BATCH_PLAN_EOF
}

# Export functions for use in other scripts
export -f get_plan_prompt
export -f get_batch_plan_prompt