#!/bin/bash

export MYSCRIPTS="$HOME/scripts"
export CODE_HOME="$HOME/code"
export GOPATH="$HOME/go"
export PATH="${MYSCRIPTS}:/usr/local/sbin:${PATH}:$GOPATH/bin"


function parse_git_branch(){
    BRANCH=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
    if [ ! "${BRANCH}" == "" ];then
        echo "[${BRANCH}] $(($(git st |wc -l)-1))"
    else
        echo ""
    fi
}

function __prompt_command() {
    local EXIT="$?"             # This needs to be first
    PS1="\n"

    local RCol='\[\e[0m\]'

    local Red='\[\e[0;31m\]'
    local Gre='\[\e[0;32m\]'
    local BYel='\[\e[1;33m\]'
    local BBlu='\[\e[1;34m\]'
    local Pur='\[\e[0;35m\]'
    local LBlu='\[\e[0;36m\]'
    local Whi='\[\e[0;29m\]'

    PS1+="${Gre}[\w]${RCol}\n" # Woriking Dir

    if [ $EXIT != 0 ]; then
        PS1+="${Red}\u${RCol}" # Add red if exit code non 0
        EXIT="${Red}${EXIT}${RCol}" #Red exit code
    else
        PS1+="${Pur}\u${RCol}" # purple username
        EXIT="${BYel}${EXIT}${RCol}" # Yellow exit code
    fi

    PS1+="@${LBlu}\h ${Rcol} \n" # user @ host
    PS1+="${EXIT} ${Gre}\`parse_git_branch\`${RCol}${Red} > ${Rcol}${Whi}${Rcol}" # Branch
}

export PROMPT_COMMAND=__prompt_command  # Func to gen PS1 after CMDs

function br(){
    open -a /Applications/Brackets.app $1
}
function jet(){
    open -a /Applications/IntelliJ\ IDEA\ 14.app ${1}
}

function allinBR(){
    grep $1 -irl . | xargs -L 1 br $1
}

function mkexe(){
    chmod u+rwx $1
}

function addAlias(){
    echo "alias $1" >> ~/.profile
}

alias gcm="git commit -am"
alias myscripts="cd $MYSCRIPTS"
alias del="rm -rf"
alias home="cd ~"
alias sand="cd ~/sandbox"
alias ccat="highlight -O ansi -i"
if [ "$(uname)" == 'Linux' ]; then
   alias ls='ls -t -A -p -h -F --color=auto'
elif [ "$(uname)" == 'Freebsd' ]; then
   alias ls='ls -GtAphF'
elif [ "$(uname)" == 'Darwin' ]; then
   alias ls='ls -GtAphF'
fi

sand
