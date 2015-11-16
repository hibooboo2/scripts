#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
. ~/.privateVars
if [ "${SCRIPTS_UPDATE}" == "true" ]
then
    git fetch --all
    git checkout origin/master
    git submodule init
    git submodule update

fi
. ./.commonvars
. ./.dockerStuff
. ./.virtualenv
. ./.profile.sh
export CDPATH=".:~:${CODE_HOME}/:${CDPATH}"
sand
clear
