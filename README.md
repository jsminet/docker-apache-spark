# docker-apache-spark
Docker image for Apache Spark version 2

# Docker compose usage

Launching Spark cluster with compose

```docker compose --env-file .env -f docker-compose.yml up```

Launch shortcut command 

```docker compose up```

Launching Spark cluster for Swarm

```docker stack deploy -c docker-stack.yml```