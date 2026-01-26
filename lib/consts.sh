#!/bin/bash

set -e

# Files
TASK_FILE="TASKS.md"
CONTEXT_FILE="CONTEXT.md"
SPECS_DIR="specs"
TASK_STATE=".task"

# Directories
BJARNE_HOME="$HOME/.bjarne"

BJARNE_PROJECT_ROOT="$(pwd)"
PROJECT_BJARNE_DIR="$BJARNE_PROJECT_ROOT/.bjarne"

# Retry settings
MAX_RETRIES=5
RETRY_DELAY=10

# Instance-specific temp folder for verbose command output
# Uses PID + timestamp for uniqueness across concurrent instances
BJARNE_INSTANCE_ID="$$_$(date +%s)"
BJARNE_TMP_DIR="/tmp/bjarne-${BJARNE_INSTANCE_ID}"

#==============================================================================
# Export variables
export TASK_FILE
export CONTEXT_FILE
export SPECS_DIR
export TASK_STATE

export BJARNE_HOME
export BJARNE_PROJECT_ROOT
export PROJECT_BJARNE_DIR

export MAX_RETRIES
export RETRY_DELAY

export BJARNE_TMP_DIR