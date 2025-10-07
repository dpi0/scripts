# `docker container management`

Perhaps the simpler way to perform these actions was:

- **to stop all containers**: `docker stop $(docker ps -q)`
- **to stop all except**: `docker ps --format '{{.Names}}' | grep -vE '^(backrest|traefik|gotify|tinyauth)$' | xargs -r docker stop`
- **to stop some**: `docker stop immich-server immich-postgres-db immich-redis2`
- **to start all that were exited**: `docker start $(docker ps -aq -f status=exited)`

the trickiest one is: **to start all except**

```bash
docker ps -aq -f status=exited | xargs -r docker inspect --format '{{.Name}} {{.Id}}' \
  | sed 's|^/||' \
  | grep -vE '^(backrest|traefik|gotify|tinyauth) ' \
  | awk '{print $2}' \
  | xargs -r docker start
```
