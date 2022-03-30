# docker-apache-spark
Docker image for Apache Spark with Kyuubi and Thrift Server integration.
Don't use both in same time, choose your need.

## To use Docker compose
```docker compose up```

## To use Docker swarm
```docker stack deploy -c <(docker-compose config) stack-name-here```