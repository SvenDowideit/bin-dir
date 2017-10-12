#!/bin/bash -ex

#apt-cacher-ng
docker run -d -p 3142:3142 --restart always --name apt-cacher -v /var/cache/apt-cacher-ng:/var/cache/apt-cacher-ng svendowideit/apt-cacher-ng
#a docker registry
docker run -d -p 5000:5000 --name registry --restart always registry
#a hub registry mirror
docker run -d --name mirror --restart always -v /var/lib/registry-mirror:/registry -e STORAGE_PATH=/registry -e STANDALONE=false -e MIRROR_SOURCE=https:/registry-1.docker.io -e MIRROR_SOURCE_INDEX=https://index.docker.io -p 5555:5000 registry
docker exec mirror sh -c "echo 'proxy:' >> /etc/docker/registry/config.yml"
docker exec mirror sh -c "echo '  remoteurl: https://registry-1.docker.io' >> /etc/docker/registry/config.yml"
docker restart mirror
