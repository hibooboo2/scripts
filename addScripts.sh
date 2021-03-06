#!/usr/bin/env bash

set -ex

: ${MYSCRIPTS:=${HOME}/scripts}

function ifInstall() {
    if [ ! -z "$(which apt-get)" ]
    then
        if [ -z $(which ${1}) ]
        then
            sudo apt-get -q -y install ${1} || echo ${1} not found to install
        fi
    fi
}

ifInstall jq
ifInstall vim
ifInstall git
ifInstall curl
ifInstall net-tools

[[ -z $(which git) ]] && echo You need git installed! && exit 1

if [ -d "${MYSCRIPTS}" ]
then
    pushd ${MYSCRIPTS}
    git pull -r origin master
    popd
else
    git clone --recursive https://github.com/hibooboo2/scripts.git ${MYSCRIPTS}
fi

if [ ! -f "~/.bashrc" ]
then
    echo "if tty -s; then . ${MYSCRIPTS}/scripts/.profile; fi" >> ~/.bashrc
elif [ ! -f "~/.profile" ]
then
    echo "if tty -s; then . ${MYSCRIPTS}/scripts/.profile; fi" >> ~/.profile
else
    echo Where do you want to source ${MYSCRIPTS}/.profile ?
    read TOSOURCE
    [[ -f "${TOSOURCE}" ]] && echo . ${MYSCRIPTS}/.profile >> ${TOSOURCE}
fi
