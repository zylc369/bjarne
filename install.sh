#!/bin/bash

set -e

log() {
    local msg="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_content="[$timestamp] $msg"
    echo "$log_content"
}

log "🚀 Installing Bjarne..."
log ""

# 设置安装目录
BJARNE_HOME="$HOME/.bjarne"
BJARNE_BIN_DIR="$HOME/.local/bin"

# 确保当前脚本所在目录为项目根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查必要文件是否存在
if [[ ! -f "$SCRIPT_DIR/bjarne" ]] || [[ ! -f "$SCRIPT_DIR/bjarne_init" ]] || \
   [[ ! -d "$SCRIPT_DIR/lib" ]] || [[ ! -d "$SCRIPT_DIR/resources" ]]; then
    log "错误：当前目录缺少必要的文件或目录（bjarne, bjarne_init, lib, resources）"
    exit 1
fi

copy_to_home() {
    # 创建bjarne的目录
    mkdir -p "$BJARNE_HOME"

    # 复制可执行脚本
    cp "$SCRIPT_DIR/bjarne" "$BJARNE_HOME/"
    cp "$SCRIPT_DIR/bjarne_init" "$BJARNE_HOME/"

    # 复制 lib 和 resources 目录（保留结构）
    cp -r "$SCRIPT_DIR/lib" "$BJARNE_HOME/"
    log "Copied lib directory to $BJARNE_HOME/lib/"
    cp -r "$SCRIPT_DIR/resources" "$BJARNE_HOME/"
    log "Copied resources directory to $BJARNE_HOME/resources/"

    # 确保脚本有执行权限
    # chmod +x "$BJARNE_HOME/bjarne" "$BJARNE_HOME/bjarne_init"
}

install() {
    log ""

    mkdir -p "$BJARNE_BIN_DIR"

    # Create bjarne command
    cat > "$BJARNE_BIN_DIR/bjarne" << 'EOF'
#!/bin/bash

BJARNE_HOME="$HOME/.bjarne"

exec "$BJARNE_HOME/bjarne" "$@"
EOF
    chmod a+x "$BJARNE_BIN_DIR/bjarne"
    log "Installed bjarne command to $BJARNE_BIN_DIR/bjarne"

    # Create bjarne-init command
    cat > "$BJARNE_BIN_DIR/bjarne-init" << 'EOF'
#!/bin/bash


BJARNE_HOME="$HOME/.bjarne"

exec "$BJARNE_HOME/bjarne_init" "$@"
EOF
    chmod a+x "$BJARNE_BIN_DIR/bjarne-init"
    log "Installed bjarne-init command to $BJARNE_BIN_DIR/bjarne-init"

    log ""
}

copy_to_home
install

# 提示用户添加 PATH
log "✅ 安装成功！"
log "请将以下行添加到你的 shell 配置文件中（如 ~/.bashrc、~/.zshrc 等）："
log ""
log "    export PATH=\"\$PATH:$BJARNE_BIN_DIR\""
log ""
log "然后运行：source ~/.bashrc（或对应配置文件）以生效。"