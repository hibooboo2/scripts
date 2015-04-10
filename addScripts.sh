#!/bin/bash

set -ex

: ${MYSCRPITS:=${HOME}/scripts}

[[ ! -d "${MYSCRPITS}" ]] && [[ ! -z $(which git) ]] && git clone https://github.com/hibooboo2/scripts.git ${MYSCRPITS}

if [ ! -f "~/.bashrc" ]
then
    echo . ${MYSCRPITS}/.profile >> ~/.bashrc
else if [ ! -f "~/.profile" ]
then
    echo . ${MYSCRPITS}/.profile >> ~/.profile
else
    echo Where do you want to source ${MYSCRIPTS}/.profile ?
fi
