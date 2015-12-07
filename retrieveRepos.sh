#!/usr/bin/env bash

echo ${GITHUB_AUTHTOKEN}
function github(){
    if [ -z "${GITHUB_AUTHTOKEN}" ];
    then
        curl -s https://api.github.com/${1}
    else
        curl -s -H "Authorization: token ${GITHUB_AUTHTOKEN}" https://api.github.com/${1}
    fi
}

function clone() {
    echo Cloning https://github.com/${1}/${2}
    pushd ${CODE_HOME}/${1}/
    hub clone ${1}/${2} > /dev/null
    echo Cloned ${1}/${2} to ${CODE_HOME}/${1}/${2}
    popd
}

set -e

[[ -z "${1}" ]] && echo Please specify User or Org to clone. && exit 1
: ${CODE_HOME:=${HOME}/src} && mkdir -p ${CODE_HOME} && echo CODE_HOME is set to ${CODE_HOME}

CMDS="hub jq curl git"

for i in $CMDS
do
    # command -v will return >0 when the $i is not found
    which $i >/dev/null && continue || { echo "$i command not found."; exit 1; }
done

[[ ! -d ${CODE_HOME}/ ]] && echo Making code Folder && mkdir ${CODE_HOME}/
[[ ! -d ${CODE_HOME}/$1 ]] && echo Making User Folder Git repos && mkdir ${CODE_HOME}/$1
[[ ! $(github orgs/$1/repos | jq -r .message) == "Not Found" ]] && type=org
[[ ! $(github users/$1/repos | jq -r .message) == "Not Found" ]] && type=user
[[ -z "${type}" ]] && echo Invalid User or Org && exit 2
echo Fetching ${type} ${1}
for i in $(github ${type}s/${1}/repos | jq -r .[].name)
do
    if [ ! -d ${CODE_HOME}/$1/$i ];
    then
        if [ "$(github repos/${1}/${i} | jq .parent)" == "null" ];
        then
            clone ${1} ${i} &
        else
            if [ "${2}" == "-f" ];
            then
                clone ${1} ${i} &
            else
                echo https://github.com/${1}/${i} is a Fork of Repo. Not Cloning.
            fi
        fi
    else
        echo You already have ${1}/$i
        if [ "$2" == "-u" ]; then
            cd ${CODE_HOME}/${1}/${i}
            git fetch --all &
        fi
    fi
done
