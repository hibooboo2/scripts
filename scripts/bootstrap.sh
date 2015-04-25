#!/bin/bash

set -e

cd /source/scripts
mkdir /source/scripts/bin
apt-get update
apt-get install -y --no-install-recommends git curl vim openssh-client openssh-server
curl -OL http://stedolan.github.io/jq/download/linux64/jq
mv jq /source/scripts/jq
chmod u+x /source/scripts/jq
curl -o /source/scripts/hub.tar.gz https://github.com/github/hub/releases/download/v2.2.1/hub-linux-amd64-2.2.1.tar.gz
tar -zxvf /source/scripts/hub.tar.gz
