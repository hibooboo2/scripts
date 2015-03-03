#!/bin/sh

docker stop drone-ci
docker rm drone-ci
docker run -d --privileged \
--name="drone-ci" \
-e DRONE_GITHUB_CLIENT=${DRONE_GITHUB_CLIENT} \
-e DRONE_GITHUB_SECRET=${DRONE_GITHUB_SECRET} \
-e DRONE_DATABASE_DATASOURCE=/var/lib/drone/drone.sqlite \
-p 8080:80 \
-v /var/lib/drone/ \
-v ${HOME}/drone.sqlite:/var/lib/drone/drone.sqlite \
-v /var/run/docker.sock:/var/run/docker.sock \
drone/drone
