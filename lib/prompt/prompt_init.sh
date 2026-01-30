#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

LIB_PROMPT_INIT_SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"
LIB_PROMPT_INIT_RESOURCE_DIR=$(get_real_path "$LIB_PROMPT_INIT_SCRIPT_DIR/../../resources")
LIB_PROMPT_INIT_RESOURCE_PROMPTS_DIR="$LIB_PROMPT_INIT_RESOURCE_DIR/prompts"
# echo "LIB_PROMPT_INIT_RESOURCE_DIR=$LIB_PROMPT_INIT_RESOURCE_DIR"

get_init_prompt() {
    local task_file_path="${1:-$DEFAULT_CURRENT_TASK_FILE_PATH}"
    read -r -d '' prompt_content << EOF
# PROJECT INITIALIZATION (Planning Only)

You have an **IDEA CONTENT** (freeform, any format) and detected environment info.
Your job: Based on the **IDEA CONTENT**, create PLANNING FILES only (CONTEXT.md, TASKS.md, specs/).

## CRITICAL: This is a PLANNING phase, NOT implementation
- You create the roadmap, the PLAN→EXECUTE→REVIEW→FIX loop builds it
- DO NOT write any source code, HTML, CSS, JavaScript, Python, etc.
- DO NOT create the actual project files (index.html, app.py, main.js, etc.)
- ONLY create: CONTEXT.md, TASKS.md, and specs/*.md files
- The tasks you create will be implemented one-by-one in the dev loop

## Core Principle: RESPECT THE IDEA CONTENT
- User's idea is the source of truth - don't change their concept
- If they specified something, use it exactly
- If they didn't specify, infer sensibly from context
- Fill gaps to make it buildable, but preserve their intent
- A detailed spec needs less inference; a vague idea needs more

## Phase 1: Understand
1. Read the **IDEA CONTENT** - extract what the user actually wants
2. Identify what's SPECIFIED (use as-is) vs what's UNSPECIFIED (infer)
3. Check detected environment for existing tech stack
4. If CLAUDE.md exists, read for existing project rules
5. **IF EXISTING PROJECT**: Explore the codebase! Read source files to understand:
   - What's already built
   - Code patterns and architecture used
   - What the **IDEA CONTENT** is asking to ADD or CHANGE vs what exists

## Phase 2: Infer Missing Pieces (only if not specified)
For anything the user didn't specify, make smart choices:
- Tech stack: Use detected, or pick appropriate for project type
- Architecture: Simple and appropriate for scope (or follow existing patterns)
- Scope: Take **IDEA CONTENT** at face value - don't expand or reduce

## Testing Principle: IF YOU CAN'T TEST IT, BUILD A WAY TO TEST IT
Unless user explicitly says "no tests", you MUST include testing:
- Add test framework setup task early (jest, pytest, vitest, etc.)
- Include test tasks for each major feature
- Tests enable the REVIEW step to verify work automatically
- Without tests, the feedback loop is blind
- Even simple projects benefit from basic smoke tests

## Phase 3: Create Files

### 1. CONTEXT.md (static reference for development)
Read file creation specifications:\`$LIB_PROMPT_INIT_RESOURCE_PROMPTS_DIR/prompt_init_create_context_file_specs.md\`

### 2. TASKS.md
Read file creation specifications:\`$LIB_PROMPT_INIT_RESOURCE_PROMPTS_DIR/prompt_init_create_tasks_file_specs.md\`

### 3. specs/ folder (only if needed)
Create specs that ADD VALUE - don't create empty scaffolds:
- API project with endpoints → specs/API.md with routes, payloads
- UI with specific design → specs/DESIGN_SYSTEM.md
- Complex data model → specs/DATA_MODEL.md
- Skip specs that would just repeat the **IDEA CONTENT**

## What NOT to Do
- **DO NOT write implementation code** - no source files, no index.html, no app.py, etc.
- Don't add features the user didn't ask for
- Don't create specs that just restate obvious things
- Don't expand scope beyond what they described
- Don't change their architectural choices if specified
- Don't add "nice to have" tasks - stick to the **IDEA CONTENT**
- Don't create tasks for "start server" or other manual user actions
- **For existing projects**: Don't recreate what already exists!

## Directory and File Path
- **Working directory**: \`$BJARNE_PROJECT_ROOT\`. All relative paths are based here.
- **TASKS.md**,**CONTEXT.md**,**specs/**: In the first level of the working directory.
- **PROMPT FRAGMENT DIRECTORY** \`$LIB_PROMPT_INIT_RESOURCE_PROMPTS_DIR\`.

Read the **IDEA CONTENT**, understand the vision, create the planning files. Implementation happens later.
EOF
    
    echo "$prompt_content"
}

export -f get_init_prompt