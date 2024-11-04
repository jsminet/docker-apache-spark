FROM openjdk:17-jdk-slim-buster
LABEL maintainer="JS Minet"

ARG SPARK_VERSION=3.5.2 \
    HADOOP_MAJOR_VERSION=3

ENV BUILD_DEPS="tini wget" \
    SPARK_HOME=/opt/spark
    
COPY --chmod=755 docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
  apt-get update && DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y ${BUILD_DEPS} && \
  wget --progress=bar:force:noscroll -O spark-bin.tgz \
      "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}.tgz" && \
  tar -xf spark-bin.tgz && \
  ln -s /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION} ${SPARK_HOME} && \
  rm spark-bin.tgz && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]