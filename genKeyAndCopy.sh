#!/bin/bash
[[ -d "~/.ssh" ]] && mkdir ~/.ssh && chmod 700 ~/.ssh && echo Made .ssh/ folder.
[[ -f "~/.ssh/id_rsa" ]] && [[ -f "~/.ssh/id_rsa.pub" ]] && ssh-keygen -t rsa -b 4096
ssh-copy-id ${1} && echo You can now ssh ${1} without a password.
