#!/bin/bash

# -e: 命令失败时立即退出
# -u: 使用未定义变量时报错
set -eu

get_real_path() {
    local path="$1"
    local clean_path=""
    # 方法1: realpath (macOS可能需要安装: brew install coreutils)
    if command -v realpath &> /dev/null; then
        clean_path=$(realpath "$path")
    # 方法2: readlink
    elif command -v readlink &> /dev/null; then
        clean_path=$(readlink -f "$path")
    # 方法3: 使用cd和pwd作为后备
    else
        clean_path=$(cd "$(dirname "$path")" && pwd)/$(basename "$path")
    fi
    echo "$clean_path"
}

export -f get_real_path