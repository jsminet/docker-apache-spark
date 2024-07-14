#!/bin/bash
set -ex

export SPARK_NO_DAEMONIZE=true
export PATH=$PATH:${SPARK_HOME}/bin:${SPARK_HOME}/sbin

case `uname` in
    (SunOS)
        HOSTNAME="`/usr/sbin/check-hostname | awk '{print $NF}'`"
        ;;
    (*)
        HOSTNAME="`hostname -f`"
        ;;
esac


SPARK_CMD="$1"
case "$SPARK_CMD" in
  master)
  shift 1
  export SPARK_MASTER_PORT=${SPARK_MASTER_PORT:-7077}
  export SPARK_MASTER_WEBUI_PORT=${SPARK_MASTER_WEBUI_PORT:-8080}
  export SPARK_MASTER_HOST=${SPARK_MASTER_HOST:-$HOSTNAME}

  echo "Spark master host set to $SPARK_MASTER_HOST"

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
    export SPARK_WORKER_WEBUI_PORT=${SPARK_WORKER_WEBUI_PORT:-8081}
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
  *)
    echo "Unknown command: $SPARK_CMD" 1>&2
    exit 1
esac

# Execute the container CMD under tini for better hygiene
exec tini -s -- "${CMD[@]}"