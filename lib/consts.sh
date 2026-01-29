#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

# Files
TASK_FILE="TASKS.md"
CONTEXT_FILE="CONTEXT.md"
SPECS_DIR="specs"
TASK_STATE=".task"

# Directories
BJARNE_HOME="$HOME/.bjarne"

BJARNE_PROJECT_ROOT="$(pwd)"
PROJECT_BJARNE_DIR="$BJARNE_PROJECT_ROOT/.bjarne"

# 当前要执行的任务文件路径
DEFAULT_CURRENT_TASK_FILE_PATH="$BJARNE_PROJECT_ROOT/$TASK_STATE"

# Retry settings
MAX_RETRIES=5
RETRY_DELAY=10

#==============================================================================
# Export variables
export TASK_FILE
export CONTEXT_FILE
export SPECS_DIR
export TASK_STATE

export BJARNE_HOME
export BJARNE_PROJECT_ROOT
export PROJECT_BJARNE_DIR

export DEFAULT_CURRENT_TASK_FILE_PATH

export MAX_RETRIES
export RETRY_DELAY
