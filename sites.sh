#!/bin/bash

set -e

: ${CERTS:="${HOME}/.certs"}

[[ ! -d "${CERTS}" ]] && mkdir ${CERTS}
docker stop nginx-proxy 2>/dev/null | echo Proxy stopped.
docker rm -fv nginx-proxy 2>/dev/null | echo Proxy removed.
docker run -d -p 80:80 \
 -p 443:443 \
 -v ${CERTS}/certs:/etc/nginx/certs:ro \
 -v /var/run/docker.sock:/tmp/docker.sock \
 --name=nginx-proxy \
 jwilder/nginx-proxy
