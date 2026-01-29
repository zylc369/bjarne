#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

# 导入 prompt 片段
source "$SCRIPT_DIR/prompt/prompt_plan.sh"

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

### REQUIRED PATTERN - Use this exact format, the wildcard \`*\` represents any number of arguments:
\`\`\`bash
# CORRECT - redirect and show exit code:
npm * > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
pip * > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
pip3 * > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
cargo build > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
pytest > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
mvn * > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"
gradlew * > $bjarne_tmp_dir/command_process.log 2>&1; echo "Exit code: \$?"

# WRONG - never do this:
npm *          # FORBIDDEN
pip *          # FORBIDDEN
pip3 *         # FORBIDDEN
cargo build    # FORBIDDEN
mvn *          # FORBIDDEN
gradlew *      # FORBIDDEN
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

get_finalize_prompt() {
    local worktree_branch="$1"
    
    read -r -d '' prompt_content << FINALIZE_EOF
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
export -f get_finalize_prompt