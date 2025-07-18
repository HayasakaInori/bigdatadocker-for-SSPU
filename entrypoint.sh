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
    # 启动SSH服务
    start_service "SSH" "service ssh start" || exit 1
    
    # 格式化HDFS并启动Hadoop
    if [ ! -f /tmp/hadoop-formatted ]; then
        log "Formatting HDFS..."
        hdfs namenode -format && touch /tmp/hadoop-formatted
    fi
    start_service "Hadoop" "start-all.sh" || exit 1
    
    # 启动Zookeeper
    start_service "Zookeeper" "zkServer.sh start" || exit 1
    
    # 启动Spark
    start_service "Spark" "/opt/spark-3.5.6-bin-hadoop3/sbin/start-all.sh" || exit 1
    
    # 启动HBase
    start_service "HBase" "/opt/hbase-2.5.11/bin/start-hbase.sh" || exit 1
    start_service "thrift" "/opt/hbase-2.5.11/bin/hbase-daemon.sh start thrift" || exit 1
    
    # 启动Flink
    start_service "Flink" "/opt/flink-1.17.2/bin/start-cluster.sh" || exit 1
    
    # 启动Phoenix Query Server
    start_service "Phoenix Query Server" "python2 /opt/phoenix-queryserver-6.0.0/bin/queryserver.py start > /dev/null 2>&1 &" || exit 1
    
    # 启动Kafka
    start_service "Kafka" "/kf.sh start" || exit 1
    
    # 配置MySQL并初始化Hive元数据
        start_service "MySQL" "service mysql start" || exit 1

    log "Configuring MySQL..."
    mysql -u root -proot -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';"
    mysql -u root -proot -e "CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root';"
    mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
    mysql -u root -proot -e "FLUSH PRIVILEGES;"
    if [ ! -f /tmp/metastore_initialized ]; then
        echo "Initializing Hive metastore database..."
        schematool -dbType mysql -initSchema \
        -verbose
        touch /tmp/metastore_initialized
        echo "Hive metastore initialized"
    fi
    start_service "HiveMetastore" "nohup hive --service metastore > hiveserver2.log 2>&1 &" || exit 1
    start_service "Hive" "hive --service hiveserver2 > hiveserver2.log 2>&1 &"  || exit 1

    log "All services started successfully!"
    
    # 保持容器运行
    tail -f /dev/null
}

# 执行主函数
main