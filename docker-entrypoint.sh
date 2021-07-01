#!/bin/bash

# echo commands to the terminal output
set -ex

SPARK_MASTER_PORT="${SPARK_MASTER_PORT:-7077}"
SPARK_MASTER_WEBUI_PORT="${SPARK_MASTER_WEBUI_PORT:-8080}"
SPARK_WORKER_WEBUI_PORT="${SPARK_WORKER_WEBUI_PORT:-8081}"

SPARK_MASTER_HOST=$(hostname -f)
echo "Spark master host set to $SPARK_MASTER_HOST"

SPARK_LOCAL_IP=$(hostname -i)
echo "Spark local IP set to $SPARK_LOCAL_IP"

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
exec /usr/bin/tini -s -- "${CMD[@]}"