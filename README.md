# Not for production
Size for built ubuntu machine: 8.14 GB

## Running container (example commands)
```
docker pull ubuntu:20.04
docker build -t ubuntu-20:1.0 .
docker images

docker run -it --name cardano-node -d -v /home/ubuntu/test-mnt:/root/tmp:ro ubuntu-20:1.0
docker exec -it cardano-node bash

or

docker run -it --name cardano-node -v /home/ubuntu/test-mnt:/root/tmp:ro --rm ubuntu-20:1.0

docker ps
```