FROM ubuntu:22.04 AS builder

RUN mkdir -p /opt && \
    mkdir -p /install

COPY opt/Anaconda3-2024.06-1-Linux-x86_64.sh /install/

#安装Anaconda&Jupyter
RUN chmod +x /install/Anaconda3-2024.06-1-Linux-x86_64.sh && \
    /install/Anaconda3-2024.06-1-Linux-x86_64.sh -b -p /opt/Anaconda

FROM ubuntu:22.04

COPY --from=builder /opt /opt

ENV PATH="/opt/Anaconda/bin:$PATH"   
ENV CONDA_ENVS_PATH="/opt/Anaconda/envs"


#添加启动脚本
COPY entrypoint-Jupyter.sh /
RUN chmod +x /entrypoint-Jupyter.sh

# 定义默认命令
ENTRYPOINT ["/entrypoint-Jupyter.sh"]