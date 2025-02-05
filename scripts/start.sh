#!/usr/bin/env bash


set -e

# 定义服务名称数组
services=(
    "deepseek-free-api" 
    "kimi-free-api" 
    "qwen-free-api" 
    "doubao-free-api" 
    "minimax-free-api"
    )
script="dist/index.js"

function status_msg() {
  echo "###[$(date +%T)]: ${1}"
}

status_msg "Starting..."

# Start the server

# 遍历服务数组并启动每个服务
for name in "${services[@]}"; do
    # 构建脚本路径
    cwd="/${name}"

    status_msg "Starting $name service..."
    cd "$cwd"
    pm2 start "$script" --name "$name" --cwd "$cwd" -f

    # 检查是否启动成功
    if [ $? -eq 0 ]; then
        status_msg "$name started successfully."
    else
        status_msg "Failed to start $name."
        exit 1
    fi
done

# 保存PM2进程列表
pm2 save --force

status_msg "Start Caddy server..."
caddy run --config /etc/caddy/Caddyfile

status_msg "All services have been started."
exit 0