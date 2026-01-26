#!/bin/bash

set -e

BJARNE_HOME="$HOME/.bjarne"

BJARNE_PROJECT_ROOT="$(pwd)"

# Logging (use absolute path to survive worktree cd)
LOG_DIR="$BJARNE_PROJECT_ROOT/.bjarne/logs"
LOG_FILE="$LOG_DIR/bjarne.log"

# Export variables
export BJARNE_HOME
export BJARNE_PROJECT_ROOT
export LOG_DIR
export LOG_FILE
