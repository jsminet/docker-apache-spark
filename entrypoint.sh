#!/bin/bash

# echo commands to the terminal output
set -ex

if [ "$SPARK_MASTER_HOST" = "" ]; then
SPARK_MASTER_HOST=$(hostname)
echo "Master host set to $SPARK_MASTER_HOST"
fi

SPARK_CMD="$1"
case "$SPARK_CMD" in
  master)
  shift 1
  CLASS="org.apache.spark.deploy.master.Master"
    CMD=(
      spark-daemon.sh start $CLASS 1 \
--host $SPARK_MASTER_HOST
--port $SPARK_MASTER_PORT
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
  *)
    echo "Unknown command: $SPARK_CMD" 1>&2
    exit 1
esac

# Execute the container CMD under tini for better hygiene
exec /sbin/tini -s -- "${CMD[@]}"