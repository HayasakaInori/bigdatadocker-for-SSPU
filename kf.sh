#!/bin/bash

# 定义常量
KAFKA_HOME="/opt/kafka_2.12-3.7.2"
CONFIG_FILE="$KAFKA_HOME/config/server.properties"
HOSTS=("localhost")  # 可扩展为多节点数组
TIMEOUT=60           # 等待超时（秒）
LOG_FILE="/var/log/kafka-server.log"

HOST_IP=$(getent ahostsv4 host.docker.internal | awk '{print $1}' | head -n1)
#LISTENER="PLAINTEXT://${HOST_IP}:9092"
LISTENER="PLAINTEXT://localhost:9092"

sed -i "s|^#advertised.listeners=.*|advertised.listeners=${LISTENER}|" /opt/kafka_2.12-3.7.2/config/server.properties

# 日志函数
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 检查Kafka进程状态
check_kafka() {
    ssh $1 "ps aux | grep -i [k]afka.Kafka" >/dev/null 2>&1
    return $?
}

# 等待Kafka启动/停止
wait_for_status() {
    local host=$1
    local expected_status=$2  # "running" or "stopped"
    local end_time=$(( $(date +%s) + $TIMEOUT ))

    while [ $(date +%s) -lt $end_time ]; do
        if [ "$expected_status" == "running" ]; then
            check_kafka $host && return 0
        else
            ! check_kafka $host && return 0
        fi
        sleep 2
    done
    return 1
}

# 启动Kafka服务
start_kafka() {
    for host in "${HOSTS[@]}"; do
        log "正在启动 $host Kafka 服务..."
        
        # 检查是否已运行
        if check_kafka $host; then
            log "$host Kafka 服务已在运行"
            continue
        fi

        # 启动服务
        ssh $host "nohup $KAFKA_HOME/bin/kafka-server-start.sh -daemon $CONFIG_FILE > $LOG_FILE 2>&1 &"
        
        # 验证启动
        if wait_for_status $host "running"; then
            log "$host Kafka 启动成功 | 日志: $LOG_FILE"
        else
            log "$host Kafka 启动失败！请检查日志: $LOG_FILE"
            return 1
        fi
    done
}

# 停止Kafka服务
stop_kafka() {
    for host in "${HOSTS[@]}"; do
        log "正在停止 $host Kafka 服务..."
        
        # 检查是否已停止
        if ! check_kafka $host; then
            log "$host Kafka 服务已停止"
            continue
        fi

        # 停止服务
        ssh $host "$KAFKA_HOME/bin/kafka-server-stop.sh"
        
        # 验证停止
        if wait_for_status $host "stopped"; then
            log "$host Kafka 已停止"
        else
            log "$host Kafka 停止失败！尝试强制终止..."
            ssh $host "pkill -9 -f kafka.Kafka"
        fi
    done
}

# 主逻辑
case "$1" in
    "start")
        start_kafka
        ;;
    "stop")
        stop_kafka
        ;;
    "status")
        for host in "${HOSTS[@]}"; do
            if check_kafka $host; then
                log "$host Kafka 正在运行"
            else
                log "$host Kafka 未运行"
            fi
        done
        ;;
    "restart")
        stop_kafka
        sleep 5
        start_kafka
        ;;
    *)
        echo "用法: $0 {start|stop|status|restart}"
        exit 1
        ;;
esac

exit 0