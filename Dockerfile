FROM openjdk:8
LABEL maintainer="JS Minet"

ENV KYUUBI_VERSION 1.2.0
ENV SPARK_MAJOR_VERSION 3.1
ENV SPARK_MINOR_VERSION 3.1.2
ENV HADOOP_VERSION 3.2

ENV KYUUBI_HOME /opt/kyuubi-${KYUUBI_VERSION}-bin-spark-${SPARK_MAJOR_VERSION}-hadoop${HADOOP_VERSION}
ENV KYUUBI_CONF_DIR ${KYUUBI_HOME}/conf
ENV KYUUBI_LOG_DIR ${KYUUBI_HOME}/logs
ENV KYUUBI_PID_DIR ${KYUUBI_HOME}/pid

ENV SPARK_MASTER_PORT ${SPARK_MASTER_PORT:-7077}
ENV SPARK_MASTER_WEBUI_PORT ${SPARK_MASTER_WEBUI_PORT:-8080}
ENV SPARK_WORKER_WEBUI_PORT ${SPARK_WORKER_WEBUI_PORT:-8081}
ENV SPARK_WORKER_CORES ${SPARK_WORKER_CORES:-1}
ENV SPARK_WORKER_MEMORY ${SPARK_WORKER_MEMORY:-1g}
ENV SPARK_DRIVER_MEMORY ${SPARK_DRIVER_MEMORY:-1g}

ENV SPARK_HOME ${KYUUBI_HOME}/externals/spark-${SPARK_MINOR_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_CONF_DIR $SPARK_HOME/conf
ENV SPARK_WORKER_DIR $SPARK_HOME/work
ENV SPARK_LOG_DIR $SPARK_HOME/logs

ENV SPARK_NO_DAEMONIZE true

ENV BUILD_DEPS \
 bash \
 coreutils \
 libc6 \
 libpam-modules \
 libnss3 \
 procps \
 tar \
 tini \
 wget

ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${KYUUBI_HOME}/bin

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt


RUN     set -ex && \
        sed -i 's/http:\/\/deb.\(.*\)/https:\/\/deb.\1/g' /etc/apt/sources.list && \
        apt-get update && \
        ln -s /lib /lib64 && \
        apt install -y ${BUILD_DEPS} && \
        wget --progress=bar:force:noscroll -O kyuubi-spark-bin-hadoop.tgz \
                "https://github.com/NetEase/kyuubi/releases/download/v${KYUUBI_VERSION}/kyuubi-${KYUUBI_VERSION}-bin-spark-${SPARK_MAJOR_VERSION}-hadoop${HADOOP_VERSION}.tar.gz" && \
        tar -xvf kyuubi-spark-bin-hadoop.tgz && \
        rm kyuubi-spark-bin-hadoop.tgz && \
        cd ${SPARK_HOME} && \
        chmod +x /usr/local/bin/docker-entrypoint.sh && \
        rm -rf /var/cache/apt/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]