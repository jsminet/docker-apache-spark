FROM openjdk:11-jdk-slim-buster
LABEL maintainer="JS Minet"

ENV BUILD_DEPS="tini wget" \
    KYUUBI_VERSION=1.6.1-incubating \
    SPARK_MAJOR_VERSION=3.2 \
    SPARK_MINOR_VERSION=3.2.3 \
    HADOOP_VERSION=3.2

COPY docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
  apt-get update && DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y ${BUILD_DEPS} && \
  wget --progress=bar:force:noscroll -O kyuubi-bin.tgz \
      "https://dlcdn.apache.org/incubator/kyuubi/kyuubi-${KYUUBI_VERSION}/apache-kyuubi-${KYUUBI_VERSION}-bin.tgz" && \ 
  tar -xvf kyuubi-bin.tgz && \
  rm kyuubi-bin.tgz && \
  cd /opt/apache-kyuubi-${KYUUBI_VERSION}-bin/externals && \
  wget --progress=bar:force:noscroll -O spark-bin.tgz \
      "https://dlcdn.apache.org/spark/spark-${SPARK_MINOR_VERSION}/spark-${SPARK_MINOR_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" && \
  tar -xvf spark-bin.tgz && \
  rm spark-bin.tgz && \
  chmod +x /usr/local/bin/docker-entrypoint.sh && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]