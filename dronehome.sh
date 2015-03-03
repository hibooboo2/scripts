#!/bin/sh

docker run -d --privileged -e DRONE_GITHUB_CLIENT=${DRONE_GITHUB_CLIENT} \
-e DRONE_GITHUB_SECRET=${DRONE_GITHUB_SECRET} \
-p 8080:80 -v /var/lib/drone/ -v /var/run/docker.sock:/var/run/docker.sock drone/drone
