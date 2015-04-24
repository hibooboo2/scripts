#!/bin/bash

export HISTCONTROL=ignoredups  # no duplicate entries
export HISTSIZE=10000000                   # big big history
export HISTFILESIZE=10000000000000               # big big history
shopt -s histappend

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

function no_sudo_docker(){
    [[ -z "$(which docker)" ]] && echo Docker seems to not be here. && exit 1
    docker ps
    [[ "0" == "${?}" ]] && echo No sudo required to use docker. && exit 0
    sudo groupadd docker
    sudo gpasswd -a ${USER} docker
    sudo service docker restart
}

export PROMPT_COMMAND=__prompt_command  # Func to gen PS1 after CMDs

function br(){
    open -a /Applications/Brackets.app $1
}
function jet(){
    open -a /Applications/IntelliJ\ IDEA\ 14.app ${1}
}
function pyCharm(){
    open -a /Applications/PyCharm.app ${1}
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

function ccat(){
    [[ -z "$(which highlight)" ]] && cat ${1}
    highlight --force -O ansi -i ${1}
}
#redefine pushd and popd so they don't output the directory stack
pushd()
{
    builtin pushd "$@" > /dev/null
}
popd()
{
    builtin popd "$@" > /dev/null
}

#alias cd so it uses the directory stack
alias cd='pushd'
#aliad cdb as a command that goes one directory back in the stack
alias cdb='popd'
alias dirs='dirs -v -l'
alias gi='grep -i'
alias gg='git grep -i'
alias myip='curl canihazip.com/s'

alias gcm="git commit -am"
alias myscripts="cd $MYSCRIPTS"
alias del="rm -rf"
alias home="cd ~"
alias sand="mkdir -p ~/sandbox; cd ~/sandbox"
if [ "$(uname)" == 'Linux' ]; then
    alias ls='ls -t -A -p -h -F --color=auto'
    shopt -s autocd 2&>1 /dev/null
    shopt -s dotglob 2&>1 /dev/null
    shopt -s globstar 2&>1 /dev/null
elif [ "$(uname)" == 'Freebsd' ]; then
   alias ls='ls -GtAphF'
elif [ "$(uname)" == 'Darwin' ]; then
   alias ls='ls -GtAphF'
fi

