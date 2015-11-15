#!/usr/bin/env bash

set -ex

: ${MYSCRPITS:=${HOME}/scripts}

function ifInstall() {
    if [ ! -z "$(which apt-get)" ]
    then
        if [ -z $(which ${1}) ]
        then
            apt-get -q -y install ${1}
        fi
    fi
}

ifInstall jq
ifInstall vim
ifInstall git

[[ -z $(which git) ]] && echo You need git installed! && exit 1

if [ -d "${MYSCRPITS}" ]
then
    pushd ${MYSCRPITS}
    git pull -r origin master
    popd
else
    git clone --recursive https://github.com/hibooboo2/scripts.git ${MYSCRPITS}
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
