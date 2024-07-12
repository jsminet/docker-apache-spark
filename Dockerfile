FROM openjdk:17-jdk-slim-buster
LABEL maintainer="JS Minet"

ENV BUILD_DEPS="tini wget" \
    MAVEN_MIRROR=${MAVEN_MIRROR:-https://repo1.maven.org/maven2} \
    WGET_OPTS=--progress=bar:force:noscroll \
    KYUUBI_VERSION=1.9.1 \
    SPARK_VERSION=3.5.1 \
    HADOOP_MAJOR_VERSION=3 \
    AWS_JAVA_SDK_VERSION=1.12.757 \
    SPARK_HADOOP_VERSION=3.3.4 \
    KYUUBI_HADOOP_VERSION=3.3.6 \
    HIVE_VERSION=3.1.3 \
    ICEBERG_VERSION=1.5.2 \
    POSTGRES_VERSION=12 \
    POSTGRES_JDBC_VERSION=42.7.3 \
    SCALA_BINARY_VERSION=2.13 \
    SPARK_BINARY_VERSION=3.5

ENV ICEBERG_SPARK_JAR_NAME=iceberg-spark-runtime-${SPARK_BINARY_VERSION}_${SCALA_BINARY_VERSION} \
    SPARK_HADOOP_CLOUD_JAR_NAME=spark-hadoop-cloud_${SCALA_BINARY_VERSION} \
    HADOOP_CLOUD_STORAGE_JAR_NAME=hadoop-cloud-storage \
    HADOOP_AWS_JAR_NAME=hadoop-aws \
    AWS_JAVA_SDK_BUNDLE_JAR_NAME=aws-java-sdk-bundle \
    POSTGRES_JDBC_JAR_NAME=postgresql \
    TPCDS_CONNECTOR_JAR_NAME=kyuubi-spark-connector-tpcds_${SCALA_BINARY_VERSION} \
    TPCH_CONNECTOR_JAR_NAME=kyuubi-spark-connector-tpch_${SCALA_BINARY_VERSION} \
    KYUUBI_HOME=/opt/apache-kyuubi-${KYUUBI_VERSION}-bin

ENV SPARK_HOME=${KYUUBI_HOME}/externals/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}
    
COPY --chmod=+x docker-entrypoint.sh /usr/local/bin/

WORKDIR /opt

RUN set -ex && \
  apt-get update && DEBIAN_FRONTEND=noninteractive && \
  apt-get install -y ${BUILD_DEPS} && \
  wget ${WGET_OPTS} -O kyuubi-bin.tgz \
      "https://dlcdn.apache.org/kyuubi/kyuubi-${KYUUBI_VERSION}/apache-kyuubi-${KYUUBI_VERSION}-bin.tgz" && \ 
  tar -xf kyuubi-bin.tgz && \
  rm kyuubi-bin.tgz && \
  cd /opt/apache-kyuubi-${KYUUBI_VERSION}-bin/externals && \
  wget ${WGET_OPTS} -O spark-bin.tgz \
      "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_MAJOR_VERSION}.tgz" && \
  tar -xf spark-bin.tgz && \
  rm spark-bin.tgz && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/iceberg/${ICEBERG_SPARK_JAR_NAME}/${ICEBERG_VERSION}/${ICEBERG_SPARK_JAR_NAME}-${ICEBERG_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/spark/${SPARK_HADOOP_CLOUD_JAR_NAME}/${SPARK_VERSION}/${SPARK_HADOOP_CLOUD_JAR_NAME}-${SPARK_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/hadoop/${HADOOP_CLOUD_STORAGE_JAR_NAME}/${SPARK_HADOOP_VERSION}/${HADOOP_CLOUD_STORAGE_JAR_NAME}-${SPARK_HADOOP_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/hadoop/${HADOOP_CLOUD_STORAGE_JAR_NAME}/${KYUUBI_HADOOP_VERSION}/${HADOOP_CLOUD_STORAGE_JAR_NAME}-${KYUUBI_HADOOP_VERSION}.jar \ 
            -P ${KYUUBI_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/hadoop/${HADOOP_AWS_JAR_NAME}/${SPARK_HADOOP_VERSION}/${HADOOP_AWS_JAR_NAME}-${SPARK_HADOOP_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/hadoop/${HADOOP_AWS_JAR_NAME}/${KYUUBI_HADOOP_VERSION}/${HADOOP_AWS_JAR_NAME}-${KYUUBI_HADOOP_VERSION}.jar \
           -P ${KYUUBI_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/com/amazonaws/${AWS_JAVA_SDK_BUNDLE_JAR_NAME}/${AWS_JAVA_SDK_VERSION}/${AWS_JAVA_SDK_BUNDLE_JAR_NAME}-${AWS_JAVA_SDK_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  ln -s ${SPARK_HOME}/jars/${AWS_JAVA_SDK_BUNDLE_JAR_NAME}-${AWS_JAVA_SDK_VERSION}.jar ${KYUUBI_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/com/amazonaws/${AWS_JAVA_SDK_BUNDLE_JAR_NAME}/${AWS_JAVA_SDK_VERSION}/${AWS_JAVA_SDK_BUNDLE_JAR_NAME}-${AWS_JAVA_SDK_VERSION}.jar \
           -P ${KYUUBI_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/postgresql/${POSTGRES_JDBC_JAR_NAME}/${POSTGRES_JDBC_VERSION}/${POSTGRES_JDBC_JAR_NAME}-${POSTGRES_JDBC_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/kyuubi/${TPCDS_CONNECTOR_JAR_NAME}/${KYUUBI_VERSION}/${TPCDS_CONNECTOR_JAR_NAME}-${KYUUBI_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  wget ${WGET_OPTS} ${MAVEN_MIRROR}/org/apache/kyuubi/${TPCH_CONNECTOR_JAR_NAME}/${KYUUBI_VERSION}/${TPCH_CONNECTOR_JAR_NAME}-${KYUUBI_VERSION}.jar \
           -P ${SPARK_HOME}/jars && \
  rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["master"]