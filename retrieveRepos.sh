#!/bin/bash

set -e

[[ -z "${1}" ]] && echo Please specify User or Org to clone. && exit 1
: ${CODE_HOME:=${HOME}/code} && mkdir -p ${CODE_HOME} && echo CODE_HOME is set to ${CODE_HOME}

CMDS="hub jq curl git"

for i in $CMDS
do
        # command -v will return >0 when the $i is not found
	which $i >/dev/null && continue || { echo "$i command not found."; exit 1; }
done

[[ ! -d ${CODE_HOME}/ ]] && echo Making code Folder && mkdir ${CODE_HOME}/
[[ ! -d ${CODE_HOME}/$1 ]] && echo Making User Folder Git repos && mkdir ${CODE_HOME}/$1
[[ ! $(curl -# https://api.github.com/orgs/$1/repos | jq -r .message) == "Not Found" ]] && type=org
[[ ! $(curl -# https://api.github.com/users/$1/repos | jq -r .message) == "Not Found" ]] && type=user
echo Fetching ${type} ${1}
[[ -z "${type}" ]] && echo Invalid User or Org && exit 2

for i in $(curl -# https://api.github.com/${type}s/${1}/repos | jq -r .[].name)
do
    if [ ! -d ${CODE_HOME}/$1/$i ]; then
        cd ${CODE_HOME}/${1}
        hub clone ${1}/${i} >/dev/null && echo Cloned ${1}/${i} to ${CODE_HOME}/${1}/${i}
    else
        echo You already have ${1}/$i
        if [ "$2" == "update" ]; then
            cd ${CODE_HOME}/${1}/${i}
            git fetch --all
        fi
    fi
done
