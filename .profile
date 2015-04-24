#!/bin/bash

cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd
[[ -f "~/.privateVars" ]] && . ~/.privateVars
. ./.commonvars
. ./.dockerStuff
. ./.virtualenv
. ./.profile.sh
sand
clear
