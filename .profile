#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
. ~/.privateVars
if [ "${SCRIPTS_UPDATE}" == "true" ]
then
    git fetch --all
    git checkout origin/master
fi
. ./.commonvars
. ./.dockerStuff
. ./.virtualenv
. ./.profile.sh
sand
clear
