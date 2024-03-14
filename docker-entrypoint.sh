#!/bin/bash

# echo commands to the terminal output
set -ex
HOSTNAME=$(hostname -f)

export KYUUBI_HOME=/opt/apache-kyuubi-${KYUUBI_VERSION}-bin
export KYUUBI_CONF_DIR=${KYUUBI_HOME}/conf
export KYUUBI_LOG_DIR=${KYUUBI_HOME}/logs
export KYUUBI_PID_DIR=${KYUUBI_HOME}/pid

export SPARK_MASTER_HOST=$HOSTNAME
export SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077}
export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}
export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}
export SPARK_WORKER_CORES=${SPARK_WORKER_CORES:-1}
export SPARK_WORKER_MEMORY=${SPARK_WORKER_MEMORY:-1g}
export SPARK_DRIVER_MEMORY=${SPARK_DRIVER_MEMORY:-1g}
export SPARK_HOME=${KYUUBI_HOME}/externals/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
export SPARK_CONF_DIR=$SPARK_HOME/conf
export SPARK_WORKER_DIR=$SPARK_HOME/work
export SPARK_LOG_DIR=$SPARK_HOME/logs
export SPARK_NO_DAEMONIZE=true

export PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin:${KYUUBI_HOME}/bin

echo "Spark master host set to $SPARK_MASTER_HOST"

SPARK_CMD="$1"
case "$SPARK_CMD" in
  master)
  shift 1
  CLASS="org.apache.spark.deploy.master.Master"
    CMD=(
      spark-daemon.sh start $CLASS 1 \
        --host $SPARK_MASTER_HOST \
        --port $SPARK_MASTER_PORT \
        --webui-port $SPARK_MASTER_WEBUI_PORT \
          "$@"
    )
    ;;
  worker)
  shift 1
  CLASS="org.apache.spark.deploy.worker.Worker"
    CMD=(
      spark-daemon.sh start $CLASS 1 \
        --host $HOSTNAME \
        --webui-port $SPARK_WORKER_WEBUI_PORT \
          "$@"
    )
    ;;
  shell)
  export SPARK_SUBMIT_OPTS="$SPARK_SUBMIT_OPTS -Dscala.usejavacp=true"
  shift 1
  CLASS="org.apache.spark.repl.Main"
    CMD=(
          spark-submit --class $CLASS \
          --name "Spark shell" \
          "$@"
    )
    ;;
  thriftserver)
  shift 1
  CLASS="org.apache.spark.sql.hive.thriftserver.HiveThriftServer2"
    CMD=(
      spark-daemon.sh submit $CLASS 1 \
      --name "Thrift JDBC/ODBC Server" \
        "$@"
   )
   ;;
  kyuubi)
  shift 1
    CMD=(
      kyuubi run \
        "$@"
   )
   ;;
  *)
    echo "Unknown command: $SPARK_CMD" 1>&2
    exit 1
esac

# Execute the container CMD under tini for better hygiene
exec tini -s -- "${CMD[@]}"