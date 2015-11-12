#!/usr/bin/env bash
if [ -z "${1}" ]
then
    echo Must provide a host name. && read HOST
else
    HOST=${1}
fi

[[ -z "${EMAIL}" ]] && echo Must provide email address. && read EMAIL
[[ -d "~/.ssh" ]] && mkdir ~/.ssh && chmod 700 ~/.ssh && echo Made .ssh/ folder.
[[ -f "~/.ssh/id_rsa" ]] && [[ -f "~/.ssh/id_rsa.pub" ]] && ssh-keygen -b 2048 -t rsa -q -N "" -C ${EMAIL}
sleep 1
[[ -f "~/.ssh/id_rsa" ]] && echo no id_rsa && exit 2
[[ -f "~/.ssh/id_rsa.pub" ]] && echo no id_rsa.pub && exit 3
ssh-copy-id ${HOST} && echo You can now ssh ${HOST} without a password.
