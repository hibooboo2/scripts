#!/bin/bash
[[ -z "${1}" ]] && echo Must provide a host name. && read HOST
[[ -z "${EMAIL}" ]] && echo Must provide email address. && read EMAIL
[[ -d "~/.ssh" ]] && mkdir ~/.ssh && chmod 700 ~/.ssh && echo Made .ssh/ folder.
[[ -f "~/.ssh/id_rsa" ]] && [[ -f "~/.ssh/id_rsa.pub" ]] && ssh-keygen -b 2048 -t rsa -q -N "" -C ${EMAIL}
[[ -f "~/.ssh/id_rsa" ]] && echo no id_rsa && exit 2
[[ -f "~/.ssh/id_rsa.pub" ]] && echo no id_rsa.pub && exit 3
if [[ -z "${1}" ]]
then
    ssh-copy-id ${HOST} && echo You can now ssh ${HOST} without a password.
else
    ssh-copy-id ${1} && echo You can now ssh ${1} without a password.
fi