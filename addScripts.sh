#!/bin/bash

set -ex

: ${MYSCRPITS:=${HOME}/scripts}
[[ -z $(which git) ]] && echo You need git installed! && exit 1
if [ -d "${MYSCRPITS}" ]
then
    pushd ${MYSCRPITS}
    git pull -r origin master
    popd
else
    git clone https://github.com/hibooboo2/scripts.git ${MYSCRPITS}
fi

if [ ! -f "~/.bashrc" ]
then
    echo . ${MYSCRPITS}/.profile >> ~/.bashrc
elif [ ! -f "~/.profile" ]
then
    echo . ${MYSCRPITS}/.profile >> ~/.profile
else
    echo Where do you want to source ${MYSCRIPTS}/.profile ?
    read TOSOURCE
    [[ -f "${TOSOURCE}" ]] && echo . ${MYSCRPITS}/.profile >> ${TOSOURCE}
fi
