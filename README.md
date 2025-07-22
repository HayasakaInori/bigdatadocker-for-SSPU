# 大数据 Docker 环境

一个包含 Hadoop、Spark、HBase、Hive、Kafka、Flink 等组件的完整大数据生态系统 Docker 解决方案。

## 功能特点

- **多阶段构建**优化镜像体积
- **预配置**的大数据组件：
  - Hadoop 3.3.6
  - Spark 3.5.6
  - HBase 2.5.11
  - Hive 4.0.1
  - Kafka 3.7.2
  - Flink 1.17.2
  - Zookeeper 3.8.4
  - Phoenix 5.1.3/6.0.0
  - Flume 1.11.0
- **集成 MySQL** 作为 Hive 元数据存储
- **预配置网络**并暴露所有服务端口
- **自动化启动**脚本管理所有服务

## 组件与端口

| 组件          | 端口   | Web UI 端口  | 说明                      |
|---------------|--------|--------------|--------------------------|
| SSH           | 2222   | -            | 从主机端口 2222 映射      |
| MySQL         | 3307   | -            | 从主机端口 3307 映射      |
| Hadoop HDFS   | 9000   | 9870         | NameNode 网页界面         |
| Hadoop YARN   | 8088   | 8088         | ResourceManager 网页界面  |
| Spark         | 7077   | 8080         | Master 网页界面           |
| HBase         | 16000  | 16010        | Master 网页界面           |
| Hive          | 10000  | -            | HiveServer2 服务          |
| Kafka         | 9092   | -            |                           |
| Flink         | 8081   | 8081         | 网页控制台                |
| Zookeeper     | 2181   | -            |                           |
| Phoenix QServer| 8765  | -            |                           |

## 快速开始

### 前提条件

- 已安装 Docker
- 建议至少 8GB 内存

### 构建镜像

```bash
docker compose build 
```

### 启动容器  
```bash
docker compose up
```

## 访问 Web UI  

| 服务 | 地址 |
|---|---|
| Hadoop NameNode | http://localhost:9870 |
| YARN ResourceManager | http://localhost:8088 |
| Spark Master | http://localhost:8080 |
| HBase Master | http://localhost:16010 |
| Flink 控制台 | http://localhost:8081 |

---

## 配置亮点

- 所有组件配置为单节点模式  
- 预设环境变量包含所有主要组件路径  
- 首次运行自动格式化 HDFS  
- MySQL 预配置为 Hive 元数据存储  
- 启用 SSH 访问便于容器管理  

---

## 自定义配置

编辑 `docker-compose.yml` 文件可以：

- 修改端口映射  
- 调整网络设置
- 删除体积较大的Jupyter镜像

---

## 注意事项

- 容器包含自动启动脚本管理所有服务  
- 首次启动可能需要较长时间初始化服务  
- Hive 元数据存储会在首次运行时自动初始化
- 内置独立的Jupyter容器 体积较大  

---

## 问题排查

查看容器日志：  
```bash
docker logs bigdata-container
```

如需排查具体服务问题，可进入容器：  
```bash
docker exec -it bigdata-container /bin/bash
```

然后检查各组件日志目录 `/opt/[组件名]/logs/`
