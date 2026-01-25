#!/bin/bash

set -e

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
mvn install > $BJARNE_TMP_DIR/install.log 2>&1; echo "Exit code: $?"
mvn clean compile > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
mvn compile > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
mvn clean package > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
mvn package > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
mvn clean > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
mvn test > $BJARNE_TMP_DIR/test.log 2>&1; echo "Exit code: $?"
gradlew install > $BJARNE_TMP_DIR/install.log 2>&1; echo "Exit code: $?"
gradlew build > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"
gradlew test > $BJARNE_TMP_DIR/test.log 2>&1; echo "Exit code: $?"
gradlew assemble > $BJARNE_TMP_DIR/build.log 2>&1; echo "Exit code: $?"

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

# Export functions for use in other scripts
export -f get_verbose_output_rules