PLEASE DO NOT USE FOR PRODUCTION  
This repository is just for test purpose.

Size for built ubuntu machine: 8.14 GB

## Running container (example commands)
```
docker pull ubuntu:20.04
docker build -t cnode:1.0 .
docker images

docker run -it --name cardano-node -d -v /local/mount/path:/container/mount/path:ro cnode:1.0
docker exec -it cardano-node bash

or

docker run -it --name cardano-node -v /local/mount/path:/container/mount/path:ro --rm cnode:1.0

docker ps
```
