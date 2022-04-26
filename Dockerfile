FROM openjdk:8-jdk-slim-buster
LABEL maintainer="JS Minet"

ENV KYUUBI_VERSION 1.5.1-incubating
ENV SPARK_MAJOR_VERSION 3.2
ENV SPARK_MINOR_VERSION 3.2.1
ENV HADOOP_VERSION 3.2

ENV KYUUBI_HOME /opt/apache-kyuubi-${KYUUBI_VERSION}-bin
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
 tini \
 wget

ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${KYUUBI_HOME}/bin

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
  apt-get update && DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y ${BUILD_DEPS} && \
  wget --progress=bar:force:noscroll -O kyuubi-bin.tgz \
      "https://dlcdn.apache.org/incubator/kyuubi/kyuubi-${KYUUBI_VERSION}/apache-kyuubi-${KYUUBI_VERSION}-bin.tgz" && \ 
  tar -xvf kyuubi-bin.tgz && \
  rm kyuubi-bin.tgz && \
  cd ${KYUUBI_HOME}/externals && \
  wget --progress=bar:force:noscroll -O spark-bin.tgz \
      "https://dlcdn.apache.org/spark/spark-${SPARK_MINOR_VERSION}/spark-${SPARK_MINOR_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
  tar -xvf spark-bin.tgz && \
  rm spark-bin.tgz && \
  chmod +x /usr/local/bin/docker-entrypoint.sh && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]