FROM openjdk:8u191-jdk-alpine3.9
MAINTAINER JS Minet

ENV SPARK_VERSION 2.4.0
ENV HADOOP_VERSION 2.7
ENV SPARK_HOME /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}

ENV BUILD_DEPS \
 bash \
 coreutils \
 procps \
 tar \
 wget

ENV PATH $PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

RUN apk update \
&& apk add --no-cache ${BUILD_DEPS} \
&& cd /opt \
&& wget --progress=bar:force:noscroll -O spark-bin-hadoop.tgz  "https://www-eu.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" \
&& tar -xvf spark-bin-hadoop.tgz \
&& rm spark-bin-hadoop.tgz \
&& cd ${SPARK_HOME} \
&& rm -rf data examples licenses kubernetes R yarn python \
&& apk del tar wget \
&& rm -rf /var/cache/apk/*

CMD start-master.sh && tail -f /dev/null

EXPOSE 4040 7077 8080