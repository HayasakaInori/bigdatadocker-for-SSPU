FROM ubuntu:22.04


# 安装必要的工具和依赖
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    curl \
    net-tools \
    ssh \
    python3\
    python3-pip\
    python2\
    vim\
    rpm\
    && ln -s /usr/bin/python3 /usr/bin/python \
    && rm -rf /var/lib/apt/lists/*


# 设置环境变量
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH
	


#创建文件夹
RUN mkdir -p /opt && \
    mkdir -p /install


# 从本地复制安装包到容器中
COPY hadoop-3.3.6.tar.gz /install/ 
COPY spark-3.5.6-bin-hadoop3.tgz /install/ 
COPY hbase-2.5.11-bin.tar.gz /install/ 
COPY kafka_2.12-3.7.2.tgz /install/ 
COPY flink-1.17.2-bin-scala_2.12.tgz /install/ 
COPY phoenix-hbase-2.5-5.2.1-bin.tar.gz /install/ 
COPY phoenix-queryserver-6.0.0-bin.tar.gz /install/ 
COPY apache-zookeeper-3.8.4-bin.tar.gz /install/ 
COPY scala-2.12.0.tgz /install/ 
COPY pyspark-4.0.0.tar.gz /install/ 
COPY mysql57-community-release-el7-9.noarch.rpm /install/
COPY mysql-connector-java-8.0.18.jar /install/
COPY apache-hive-4.0.1-bin.tar.gz /install/ 
COPY apache-flume-1.11.0-bin.tar.gz /install/ 
#COPY Anaconda3-2023.09-0-Linux-x86_64.sh /install/

# 安装Hadoop
RUN tar -xzf /install/hadoop-3.3.6.tar.gz -C /opt/ 
    #rm /install/hadoop-3.3.6.tar.gz
ENV HADOOP_HOME=/opt/hadoop-3.3.6
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin


#安装Zookeeper
RUN tar -xzf /install/apache-zookeeper-3.8.4-bin.tar.gz -C /opt/
    #rm /install/apache-zookeeper-3.8.4-bin.tar.gz
ENV ZOOKEEPER_HOME=/opt/apache-zookeeper-3.8.4-bin
ENV PATH=$ZOOKEEPER_HOME/bin:$PATH


#安装Scala
RUN tar -xzf /install/scala-2.12.0.tgz -C /opt/
    #rm scala-2.12.0.tgz
ENV SCALA_HOME=/opt/scala-2.12.0
ENV PATH=$SCALA_HOME/bin:$PATH


# 安装Spark
RUN tar -xzf install/spark-3.5.6-bin-hadoop3.tgz -C /opt/ 
    #rm /install/spark-3.5.6-bin-hadoop3.tgz
ENV SPARK_HOME=/opt/spark-3.5.6-bin-hadoop3
ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
#ENV PYSPARK_PYTHON=/opt/anaconda/envs/py38/bin/python#不知道要不要


# 安装HBase
RUN tar -xzf /install/hbase-2.5.11-bin.tar.gz -C /opt/ 
    #rm /install/hbase-2.5.11-bin.tar.gz
ENV HBASE_HOME=/opt/hbase-2.5.11
ENV PATH=$PATH:$HBASE_HOME/bin


#安装MySQL
RUN rpm -ivh /install/mysql57-community-release-el7-9.noarch.rpm 
RUN rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2022
RUN apt-get update && apt-get install -y mysql-server
RUN service mysql start
#没用到yum不知道需不需要上面的下载


#安装Hive
RUN tar -xzf /install/apache-hive-4.0.1-bin.tar.gz -C /opt/
    #rm /install/apache-hive-4.0.1-bin.tar.gz
ENV HADOOP_HOME=/opt/hadoop-3.3.6
ENV HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
ENV HADOOP_OPTS="-Djava.library.path=${HADOOP_HOME}/lib"
ENV HIVE_HOME=/opt/apache-hive-4.0.1-bin
ENV HIVE_CONF_DIR=${HIVE_HOME}/conf
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV JRE_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH=.:$JAVA_HOME/bin:$JRE_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin:$PATH


# 安装Kafka
RUN tar -xzf /install/kafka_2.12-3.7.2.tgz -C /opt/ 
    #rm /install/kafka_2.12-3.7.2.tgz
ENV KAFKA_HOME=/opt/kafka_2.12-3.7.2
ENV PATH=$PATH:$KAFKA_HOME/bin


# 安装Flink
RUN tar -xzf /install/flink-1.17.2-bin-scala_2.12.tgz -C /opt/ 
    #rm /install/flink-1.17.2-bin-scala_2.12.tgz
ENV FLINK_HOME=/opt/flink-1.17.2
ENV PATH=$PATH:$FLINK_HOME/bin


#安装Flume
RUN tar -xzf /install/apache-flume-1.11.0-bin.tar.gz -C /opt/
ENV FLUME_HOME=/opt/apache-flume-1.11.0-bin
ENV FLUME_CONF_DIR=$FLUME_HOME/conf
ENV PATH=$PATH:$FLUME_HOME/bin


# 安装Phoenix 
RUN tar -xzf /install/phoenix-hbase-2.5-5.2.1-bin.tar.gz -C /opt
# 复制 JAR 文件到 HBase 库目录
RUN cp /opt/phoenix-hbase-2.5-5.2.1-bin/phoenix-server-hbase-2.5-5.2.1.jar /opt/hbase-2.5.11/lib/ && \
    cp /opt/phoenix-hbase-2.5-5.2.1-bin/phoenix-pherf-5.2.1.jar /opt/hbase-2.5.11/lib/


# 安装Queryserver
RUN tar -xzf /install/phoenix-queryserver-6.0.0-bin.tar.gz -C /opt
RUN cp /opt/phoenix-hbase-2.5-5.2.1-bin/phoenix-client-lite-hbase-2.5-5.2.1.jar /opt/phoenix-queryserver-6.0.0



#配置Hadoop
RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export HADOOP_PID_DIR=/opt/hadoop-3.3.6/pids' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export HADOOP_LOG_DIR=/opt/hadoop-3.3.6/logs' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export HDFS_NAMENODE_USER=root' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export HDFS_DATANODE_USER=root' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export HDFS_SECONDARYNAMENODE_USER=root' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export YARN_RESOURCEMANAGER_USER=root' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh &&\
    echo 'export YARN_NODEMANAGER_USER=root' >> /opt/hadoop-3.3.6/etc/hadoop/hadoop-env.sh

RUN sed -i '/<\/configuration>/i\<property>\n\
        <name>fs.defaultFS</name>\n\
        <value>hdfs://localhost:9000</value>\n\
    </property>\n\
    <property>\n\
        <name>io.file.buffer.size</name>  \n\
        <value>131072</value>\n\
    </property>\n\
     <property>\n\
        <name>hadoop.proxyuser.root.hosts</name>\n\
        <value>*</value>\n\
        <description>Hadoop的超级用户root能代理的节点</description>\n\
    </property>\n\
    <property>\n\
        <name>hadoop.proxyuser.root.groups</name>\n\
        <value>*</value>\n\
        <description>Hadoop的超级用户root能代理的用户组</description>\n\
    </property>' /opt/hadoop-3.3.6/etc/hadoop/core-site.xml

RUN sed -i '/<\/configuration>/i\<property>\n\
        <name>dfs.replication</name>\n\
        <value>1</value>\n\
    </property>\n\
    <property>\n\
        <name>fs.namenode.name.dir</name>\n\
        <value>/opt/hadoop-3.3.6/namenode</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.blocksize</name>\n\
    <value>268435456</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.namenode.handler.count</name>\n\
        <value>100</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.datanode.data.dir</name>\n\
        <value>/opt/hadoop-3.3.6/datanode</value>\n\
    </property>' /opt/hadoop-3.3.6/etc/hadoop/yarn-site.xml

RUN sed -i '/<\/configuration>/i\<property>\n\
        <name>dfs.replication</name>\n\
        <value>1</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.namenode.name.dir</name>\n\
<value>/opt/hadoop-3.3.6/namenode</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.blocksize</name>\n\
        <value>268435456</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.namenode.handler.count</name>\n\
        <value>100</value>\n\
    </property>\n\
    <property>\n\
        <name>dfs.datanode.data.dir</name>\n\
        <value>/opt/hadoop-3.3.6/datanode</value>\n\
    </property>' /opt/hadoop-3.3.6/etc/hadoop/hdfs-site.xml

RUN sed -i '/<\/configuration>/i\<property>\n\
        <name>mapreduce.framework.name</name>\n\
        <value>yarn</value>\n\
    </property>' /opt/hadoop-3.3.6/etc/hadoop/mapred-site.xml

RUN sed -i '/<\/configuration>/i\<property>\n\
        <!--NodeManager获取数据的方式-->\n\
        <name>yarn.nodemanager.aux-services</name>\n\
        <value>mapreduce_shuffle</value>\n\
    </property>\n\
    <!--指定YARN集群的管理者（ResourceManager）的地址-->\n\
    <property>\n\
        <name>yarn.resourcemanager.hostname</name>\n\
        <value>localhost</value>\n\
    </property>' /opt/hadoop-3.3.6/etc/hadoop/yarn-site.xml
#ssh要自启动


#配置Zookeeper
RUN mv /opt/apache-zookeeper-3.8.4-bin/conf/zoo_sample.cfg /opt/apache-zookeeper-3.8.4-bin/conf/zoo.cfg

RUN mkdir /opt/apache-zookeeper-3.8.4-bin/data

RUN sed -i 's/dataDir=\/tmp\/zookeeper/dataDir=\/opt\/apache-zookeeper-3.8.4-bin\/data/' /opt/apache-zookeeper-3.8.4-bin/conf/zoo.cfg && \
    echo 'server.0=localhost:2888:3888' >> /opt/apache-zookeeper-3.8.4-bin/conf/zoo.cfg

RUN echo '0' >> /opt/apache-zookeeper-3.8.4-bin/data/myid
#不清楚分发和myid是否必须
#myid必须


#配置Spark 
#local部署模式
RUN cp /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh.template /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh 

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh&& \
    echo 'export SCALA_HOME=/opt/scala-2.12.0' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'export SPARK_WORKER_MEMORY=1g' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'export SPARK_WORKER_CORES=2' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'export SPARK_HOME=/opt/spark-3.5.6-bin-hadoop3' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'HADOOP_HOME=/opt/hadoop-3.3.6' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'HADOOP_CONF_DIR=/opt/hadoop-3.3.6' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh && \
    echo 'YARN_CONF_DIR=/opt/hadoop-3.3.6/etc/hadoop' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-env.sh

RUN cp /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf.template /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf

#yarn部署模式
RUN cp /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf.template /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf

RUN echo 'spark.eventLog.enabled          true' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf && \
    echo 'spark.eventLog.dir              hdfs://localhost:9000/user/spark/directory' >> /opt/spark-3.5.6-bin-hadoop3/conf/spark-defaults.conf

#修改wokers
RUN cp /opt/spark-3.5.6-bin-hadoop3/conf/workers.template /opt/spark-3.5.6-bin-hadoop3/conf/workers

#安装pyspark
#RUN pip3 install --default-timeout=100 /install/pyspark-4.0.0.tar.gz


#配置Hbase
#RUN rm /opt/hbase-2.5.11/lib/client-facing-thirdparty/slf4j-reload4j-1.7.33.jar

RUN echo 'export HBASE_MANAGES_ZK=false' >> /opt/hbase-2.5.11/conf/hbase-env.sh && \
    echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /opt/hbase-2.5.11/conf/hbase-env.sh && \
    echo 'export HBASE_CLASSPATH=/opt/hadoop-3.3.6/etc/hadoop' >> /opt/hbase-2.5.11/conf/hbase-env.sh && \
    echo 'export HADOOP_HOME=/opt/hadoop-3.3.6' >> /opt/hbase-2.5.11/conf/hbase-env.sh && \
    echo 'export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP="true"' >> /opt/hbase-2.5.11/conf/hbase-env.sh

RUN sed -i '/<\/configuration>/i\
<property>\n\
        <name>hbase.rootdir</name>\n\	
        <value>hdfs://localhost:9000/hbase</value>\n\
        <description>这个目录是region server的共享目录，用来持久化Hbase</description>\n\
</property>\n\
<property>\n\
        <name>hbase.cluster.distributed</name>\n\
        <value>true</value>\n\
        <description>Hbase的运行模式。false是单机模式，true是分布式模式</description>\n\
</property>\n\
<property>\n\
        <name>hbase.master</name>\n\
        <value>hdfs://localhost:60000</value>\n\
        <description>hmaster port</description>\n\
</property>\n\
<property>\n\
        <name>hbase.zookeeper.quorum</name>\n\
        <value>localhost</value>\n\
        <description>zookeeper集群的URL配置，多个host之间用逗号（,）分割</description>\n\
</property>\n\
<property>\n\
        <name>hbase.zookeeper.property.dataDir</name>\n\
        <value>/opt/apache-zookeeper-3.8.4-bin/data</value>\n\
        <description>zookeeper的zooconf中的配置，快照的存储位置</description>\n\
</property>\n\
<property>\n\
        <name>hbase.zookeeper.property.clientPort</name>\n\
        <value>2181</value>\n\
</property>\n\	
<property>\n\
        <name>hbase.master.info.port</name>\n\
        <value>60010</value>\n\
</property>\n\
' /opt/hbase-2.5.11/conf/hbase-site.xml

#RUN echo'' >> /opt/hbase-2.5.11/conf/regionservers

#拷贝Hadoop配置
RUN cp /opt/hadoop-3.3.6/etc/hadoop/hdfs-site.xml /opt/hbase-2.5.11/conf
RUN cp /opt/hadoop-3.3.6/etc/hadoop/core-site.xml /opt/hbase-2.5.11/conf


#配置Phoenix
RUN sed -i '/<\/configuration>/i\<property>\n\
  <name>hbase.regionserver.wal.codec</name>\n\
  <value>org.apache.hadoop.hbase.regionserver.wal.IndexedWALEditCodec</value>\n\
</property>\n\
<property>\n\
  <name>phoenix.schema.mapSystemTablesToNamespace</name>\n\
  <value>true</value>\n\
</property>' /opt/hbase-2.5.11/conf/hbase-site.xml

RUN /opt/hbase-2.5.11/bin/stop-hbase.sh && \
    /opt/hbase-2.5.11/bin/start-hbase.sh

#RUN pip3 install phoenixdb


#配置MySQL
RUN sed -i 's/^# *pid-file *=.*/pid-file      = \/var\/run\/mysqld\/mysqld.pid/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^# *socket *=.*/socket = \/var\/run\/mysqld\/mysqld.sock/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^# *port *=.*/port           = 3306/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^# *datadir *=.*/datadir        = \/var\/lib\/mysql/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^bind-address *=.*/bind-address            = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^mysqlx-bind-address *=.*/mysqlx-bind-address     = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

RUN echo "" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "[client]" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "port=3306" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "socket = /var/run/mysqld/mysqld.sock" >> /etc/mysql/mysql.conf.d/mysqld.cnf

#echo "skip-grant-tables" >> /etc/mysql/mysql.conf.d/mysqld.cnf && \不能加，加了不监听端口


#还有一个启动脚本


#配置Hive
RUN cp /opt/apache-hive-4.0.1-bin/conf/hive-env.sh.template /opt/apache-hive-4.0.1-bin/conf/hive-env.sh
RUN rm /opt/apache-hive-4.0.1-bin/lib/log4j-slf4j-impl-2.18.0.jar

RUN echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /opt/apache-hive-4.0.1-bin/hive-env.sh && \
    echo 'export HIVE_HOME=/opt/apache-hive-4.0.1-bin' >> /opt/apache-hive-4.0.1-bin/hive-env.sh && \
    echo 'export HIVE_CONF_DIR=/opt/apache-hive-4.0.1-bin/conf' >> /opt/apache-hive-4.0.1-bin/hive-env.sh && \
    echo 'export HIVE_AUX_JARS_PATH=/opt/apache-hive-4.0.1-bin/lib' >> /opt/apache-hive-4.0.1-bin/hive-env.sh && \
    echo 'export HADOOP_HOME=/opt/hadoop-3.3.6' >> /opt/apache-hive-4.0.1-bin/hive-env.sh

RUN cp /opt/apache-hive-4.0.1-bin/conf/hive-default.xml.template /opt/apache-hive-4.0.1-bin/conf/hive-site.xml

RUN sed -i '/<\/configuration>/i\<property>\n\
        <name>hive.exec.local.scratchdir</name>\n\
        <value>/opt/apache-hive-4.0.1-bin/tmp/</value>\n\
    </property>\n\
    <property>\n\
        <name>hive.downloaded.resources.dir</name>\n\
        <value>/opt/apache-hive-4.0.1-bin/tmp/${hive.session.id}_resources</value>\n\
    </property>\n\
    <property>\n\
        <name>hive.querylog.location</name>\n\
        <value>/opt/apache-hive-4.0.1-bin/tmp/</value>\n\
    </property>\n\
    <property>\n\
        <name>hive.server2.logging.operation.log.location</name>\n\
        <value>/opt/apache-hive-4.0.1-bin/tmp/root/operation_logs</value>\n\
    </property>\n\
    <property>\n\
        <name>javax.jdo.option.ConnectionDriverName</name>\n\
        <value>com.mysql.jdbc.Driver</value>\n\
    </property>\n\
    <property>\n\
        <name>javax.jdo.option.ConnectionURL</name>\n\
        <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true&amp;useSSL=false&amp;useUnicode=true&amp;characterEncoding=UTF-8</value>\n\
    </property>\n\
    <property>\n\
        <name>javax.jdo.option.ConnectionUserName</name>\n\
        <value>root</value>\n\
    </property>\n\
    <property>\n\
        <name>javax.jdo.option.ConnectionPassword</name>\n\
        <value>root</value>\n\
    </property>' /opt/apache-hive-4.0.1-bin/conf/hive-site.xml

RUN sed -i '/<\/configuration>/i\  <property>\n\
    <name>yarn.nodemanager.resource.memory-mb</name>\n\
    <value>2548</value>\n\
    <discription>每个节点可用内存,单位MB</discription>\n\
  </property>\n\
  <property>\n\
    <name>yarn.scheduler.minimum-allocation-mb</name>\n\
    <value>2048</value>\n\
    <discription>单个任务可申请最少内存，默认1024MB</discription>\n\
  </property>\n\
  <property>\n\
    <name>yarn.scheduler.maximum-allocation-mb</name>\n\
    <value>8192</value>\n\
    <discription>单个任务可申请最大内存，默认8192MB</discription>\n\
  </property>' /opt/hadoop-3.3.6/etc/hadoop/yarn-site.xml

RUN sed -i '/<\/configuration>/i\  <property>\n\
    <name>yarn.app.mapreduce.am.env</name>\n\
    <value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.6</value>\n\
  </property>\n\
  <property>\n\
    <name>mapreduce.map.env</name>\n\
    <value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.6</value>\n\
  </property>\n\
  <property>\n\
    <name>mapreduce.reduce.env</name>\n\
    <value>HADOOP_MAPRED_HOME=/opt/hadoop-3.3.6</value>\n\
  </property>' /opt/hadoop-3.3.6/etc/hadoop/mapred-site.xml

RUN cp /install/mysql-connector-java-8.0.18.jar /opt/apache-hive-4.0.1-bin/lib

#由于在该配置文件中有如下两个配置项注明了hive在HDFS中数据存储的目录，因此我们需要在HDFS上手动创建并赋权限，也就是需要在hdfs上创建/tmp/hive 和/user/hive/warehouse
#RUN hadoop fs -mkdir -p /user/hive/warehouse
#RUN hadoop fs -chmod -R 777 /user/hive/warehouse
#RUN hadoop fs -mkdir -p /tmp/hive/ 
#RUN hadoop fs -chmod -R 777 /tmp/hive 

#RUN service mysql start && \
    #mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"

#RUN /opt/apache-hive-4.0.1-bin/bin/schematool -initSchema -dbType mysql
#可能需要写入脚本


#Hive整合Hbase
#RUN hbase shell
#create 'tablename', cf1'
#"habse.columns.mapping" = ":key,data:cf1"
#./hive --service hiveserver2 -hiveconf hive.server2.thrift.port=10000


#配置Kafka 
#RUN mkdir /opt/kafka_2.12-3.7.2/logs#感觉没必要

#RUN sed -i 's/broker.id=0/broker.id=0/' /opt/kafka_2.12-3.7.2/config/server.properties#单节点不配

RUN sed -i 's/zookeeper.connect=localhost:2181/zookeeper.connect=localhost:2181\/kafka/' /opt/kafka_2.12-3.7.2/config/server.properties


#配置Flume 
RUN cp /opt/apache-flume-1.11.0-bin/conf/flume-env.sh.template /opt/apache-flume-1.11.0-bin/conf/flume-env.sh

RUN echo 'JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /opt/apache-flume-1.11.0-bin/conf/flume-env.sh

RUN echo "# 定义这个agent的名称" > /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sources = r1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks = k1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.channels = c1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "# 配置源，用于监控文件" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sources.r1.type = exec" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sources.r1.command = tail -F /opt/apache-flume-1.11.0-bin/test/1.log" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sources.r1.channels = c1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "# 配置接收器，用于HDFS" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.type = hdfs" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.path = hdfs://localhost:9000/flume/events/%y-%m-%d/%H-%M" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.filePrefix = events-" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.round = true" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.roundValue = 10" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.roundUnit = minute" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.rollInterval = 0" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.rollSize = 1024" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.rollCount = 0" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.hdfs.useLocalTimeStamp = true" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.channel = c1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "# 配置通道，内存型" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.channels.c1.type = memory" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.channels.c1.capacity = 1000" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.channels.c1.transactionCapacity = 100" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "# 绑定源和接收器到通道" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sources.r1.channels = c1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf && \
     echo "a1.sinks.k1.channel = c1" >> /opt/apache-flume-1.11.0-bin/conf/hdfs-avro.conf


#配置Flink
RUN sed -i 's/jobmanager.rpc.address: localhost/jobmanager.rpc.address: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/jobmanager.bind-host: localhost/jobmanager.bind-host: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/taskmanager.bind-host: localhost/taskmanager.bind-host: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/taskmanager.host: localhost/taskmanager.host: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/#rest.port: 8081/rest.port: 8083/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/rest.address: localhost/rest.address: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/rest.bind-address: localhost/rest.bind-address: 0.0.0.0/' /opt/flink-1.17.2/conf/flink-conf.yaml && \
    sed -i 's/#rest.bind-port: 8083-8090/rest.bind-port: 8080-8090/' /opt/flink-1.17.2/conf/flink-conf.yaml
#不知道为什么8080-8090不行

#不知道有没有影响
#RUN sed -i 's/localhost:8081/0.0.0.0:8083/' /opt/flink-1.17.2/conf/masters
#或者lcoalhost:8083 如果都不行就把端口开回8081
#没改也没有影响访问webui


# 配置SSH
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

#启动后台
#RUN service ssh start
#RUN hdfs namenode -format && \
    #start-all.sh && \
    #zkServer.sh start && \
    #/opt/spark-3.5.6-bin-hadoop3/sbin/start-all.sh 
#可能需要写入脚本

#上传jar
#RUN hdfs dfs -mkdir -p /user/spark/directory && \
    #hdfs dfs -put /opt/spark-3.5.6-bin-hadoop3/jars/* /user/spark/directory



#配置启动脚本 
#RUN vim entrypoint.sh


#清理安装包
#RUN rm -rf /install


# 设置工作目录
WORKDIR /root

#添加启动脚本
 #COPY entrypoint.sh /

# 定义默认命令
#ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]