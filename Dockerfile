FROM openjdk:8-alpine
LABEL maintainer="JS Minet"

ENV SPARK_VERSION 2.4.8
ENV HADOOP_VERSION 2.7
ENV SPARK_HOME /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV SPARK_NO_DAEMONIZE true

ENV SPARK_MASTER_PORT ${SPARK_MASTER_PORT:-7077}
ENV SPARK_MASTER_WEBUI_PORT ${SPARK_MASTER_WEBUI_PORT:-8080}
ENV SPARK_WORKER_WEBUI_PORT ${SPARK_WORKER_WEBUI_PORT:-8081}
ENV SPARK_WORKER_CORES ${SPARK_WORKER_CORES:-1}
ENV SPARK_WORKER_MEMORY ${SPARK_WORKER_MEMORY:-1g}
ENV SPARK_DRIVER_MEMORY ${SPARK_DRIVER_MEMORY:-1g}

ENV SPARK_CONF_DIR ${SPARK_CONF_DIR:-$SPARK_HOME/conf}
ENV SPARK_WORKER_DIR ${SPARK_WORKER_DIR:-$SPARK_HOME/work}
ENV SPARK_LOG_DIR ${SPARK_LOG_DIR:-$SPARK_HOME/logs}

ENV BUILD_DEPS \
 bash \
 coreutils \
 procps \
 tar \
 tini \
 wget

ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
        apk update && \
        apk add --no-cache ${BUILD_DEPS} && \
        wget --progress=bar:force:noscroll -O spark-bin-hadoop.tgz \
                "https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
        tar -xvf spark-bin-hadoop.tgz && \
        rm spark-bin-hadoop.tgz && \
        cd ${SPARK_HOME} && \
        rm -rf data examples licenses kubernetes R yarn python && \
        chmod +x /usr/local/bin/docker-entrypoint.sh && \
        apk del tar wget && \
        rm -rf /var/cache/apk/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]