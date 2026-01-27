#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

#==============================================================================
# VERBOSE OUTPUT RULES - Injected into all prompts to save tokens
#==============================================================================

# Generate verbose output rules with current temp folder path
get_verbose_output_rules() {
    local bjarne_tmp_dir="$1"
    cat << VERBOSE_EOF

## MANDATORY: Verbose Command Output Redirection

**YOU MUST FOLLOW THESE RULES. NO EXCEPTIONS.**

**Log folder for this session**: $bjarne_tmp_dir

### MANDATORY REDIRECTION - You MUST redirect these commands:
- **Package managers**: npm, yarn, pnpm, pip, pip3, cargo, go get/build, composer, bundle, maven, gradle, apt, brew
- **Build tools**: webpack, vite, tsc, esbuild, rollup, make, cmake, msbuild, gcc, g++, rustc, javac
- **Container tools**: docker build, docker pull, docker run, docker-compose
- **Test runners**: npm test, yarn test, jest, pytest, cargo test, go test, phpunit, rspec, mocha, vitest
- **Database tools**: migrations, db:push, db:pull, prisma, drizzle, typeorm, sequelize
- **Linters/Formatters**: eslint, prettier, black, flake8, clippy

### REQUIRED PATTERN - Use this exact format:
\`\`\`bash
# CORRECT - redirect and show exit code:
npm install > $bjarne_tmp_dir/install.log 2>&1; echo "Exit code: \$?"
npm test > $bjarne_tmp_dir/test.log 2>&1; echo "Exit code: \$?"
npm run build > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: \$?"
cargo build > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: \$?"
pytest > $bjarne_tmp_dir/test.log 2>&1; echo "Exit code: \$?"
mvn install > $bjarne_tmp_dir/install.log 2>&1; echo "Exit code: $?"
mvn clean compile > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
mvn compile > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
mvn clean package > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
mvn package > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
mvn clean > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
mvn test > $bjarne_tmp_dir/test.log 2>&1; echo "Exit code: $?"
gradlew install > $bjarne_tmp_dir/install.log 2>&1; echo "Exit code: $?"
gradlew build > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"
gradlew test > $bjarne_tmp_dir/test.log 2>&1; echo "Exit code: $?"
gradlew assemble > $bjarne_tmp_dir/build.log 2>&1; echo "Exit code: $?"

# WRONG - never do this:
npm install          # FORBIDDEN
npm test             # FORBIDDEN
cargo build          # FORBIDDEN
mvn install          # FORBIDDEN
mvn clean compile    # FORBIDDEN
mvn compile          # FORBIDDEN
mvn clean package    # FORBIDDEN
mvn package          # FORBIDDEN
mvn clean            # FORBIDDEN
mvn test             # FORBIDDEN
\`\`\`

### After running, check results with:
\`\`\`bash
# If exit code was 0, check last few lines to confirm:
tail -20 $bjarne_tmp_dir/test.log

# If exit code was non-zero, find errors:
grep -i "error\|fail\|exception" $bjarne_tmp_dir/test.log | head -30
\`\`\`

### Commands that DON'T need redirection:
- \`ls\`, \`cat\`, \`head\`, \`tail\`, \`grep\`, \`find\`
- \`git status\`, \`git diff\`, \`git log\` (short output)
- \`node script.js\` (when output is expected to be < 10 lines)
- File reads and quick checks

VERBOSE_EOF
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

get_finalize_prompt() {
    local worktree_branch="$1"
    
    read -r -d '' prompt_content << FINALIZE_EOF || true
# FINALIZE TASK

**IMPORTANT: This is the final step of an automated pipeline.**
- There is NO human in the loop - just complete the finalization
- Do NOT ask questions or request approval - just do the steps
- Be direct and factual - no conversational language needed

**GIT WORKTREE MODE:** You are in an isolated worktree on branch: $worktree_branch
- Do NOT switch branches - bjarne handles cleanup
- Just commit, push, and create PR

The task loop has completed. Now finalize the work:

## Your Actions

1. **Check git status**
   - Are there uncommitted changes? If so, commit them.
   - Are there commits to push?

2. **Push the branch**
   - Push: \`git push -u origin $worktree_branch\`
   - If push fails (no remote, auth issues), just note it and continue

3. **Create PR if appropriate**
   - Only if: pushed successfully and \`gh\` CLI is available
   - Check if PR already exists: \`gh pr list --head $worktree_branch\`
   - If no PR exists, create one with a good title and description
   - Include what was changed and how to test it

4. **Output summary**
   - List what was accomplished
   - Note any issues or incomplete items
   - Include PR URL if created

## Constraints
- Do NOT run git checkout or git switch - stay on $worktree_branch
FINALIZE_EOF
    
    echo "$prompt_content"
}

# Export functions for use in other scripts
export -f get_verbose_output_rules
export -f get_batch_plan_prompt
export -f get_finalize_prompt