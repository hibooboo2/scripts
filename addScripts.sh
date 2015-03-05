#!/bin/bash

set -ex

: ${MYSCRPITS:=${HOME}/scripts}

[[ ! -d "${MYSCRPITS}" ]] && [[ ! -z $(which git) ]] && git clone https://github.com/hibooboo2/scripts.git ${MYSCRPITS}

echo . ${MYSCRPITS}/.profile >> ~/.profile

