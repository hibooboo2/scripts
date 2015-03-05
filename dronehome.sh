#!/bin/sh

docker pull drone/drone
docker stop drone-ci
docker rm drone-ci
docker run -d --privileged \
--name="drone-ci" \
-e VIRTUAL_HOST=drone.jamescarlharris.com \
-e DRONE_GITHUB_CLIENT=${DRONE_GITHUB_CLIENT} \
-e DRONE_GITHUB_SECRET=${DRONE_GITHUB_SECRET} \
-e DRONE_DATABASE_DATASOURCE=/var/lib/drone/drone.sqlite \
-e DRONE_WORKER_NODES=unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock,unix:///var/run/docker.sock \
-v /var/lib/drone/ \
-v ${HOME}/drone.sqlite:/var/lib/drone/drone.sqlite \
-v /var/run/docker.sock:/var/run/docker.sock \
drone/drone
#-p 8080:80 \

docker pull scottwferg/drone-wall
docker stop drone-wall
docker rm drone-wall
docker run \ 
-d \
-e VIRTUAL_HOST=wall.jamescarlharris.com \
-e API_SCHEME=$API_SCHEME \
-e API_DOMAIN=$API_DOMAIN \
-e API_TOKEN=$API_TOKEN \
-e API_PORT=$API_PORT \
--name="drone-wall" \
scottwferg/drone-wall
#-p 5000:3000 \
