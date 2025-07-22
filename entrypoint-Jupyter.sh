#!/bin/bash

# 定义日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查并启动服务函数
start_service() {
    local service_name=$1
    local start_command=$2
    local max_retries=3
    local retry_delay=5
    
    log "Starting ${service_name}..."
    
    for ((i=1; i<=$max_retries; i++)); do
        eval "$start_command"
        if [ $? -eq 0 ]; then
            log "${service_name} started successfully."
            return 0
        else
            log "Attempt ${i} failed to start ${service_name}. Retrying in ${retry_delay} seconds..."
            sleep $retry_delay
        fi
    done
    
    log "Failed to start ${service_name} after ${max_retries} attempts."
    return 1
}

# 主执行流程
main() {

    #启动Jupyter
    start_service "Jupyter" "nohup jupyter notebook  --ip=0.0.0.0 --port=8888  --no-browser --allow-root --NotebookApp.token='' --NotebookApp.password='' > /var/log/jupyter.log 2>&1 &" || exit 1

    log "All services started successfully!"
    
    # 保持容器运行
    tail -f /dev/null
}

# 执行主函数
main