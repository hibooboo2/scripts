#!/bin/sh

export MYSCRIPTS="$HOME/scripts"
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
PS1="\n[\[\e[32m\]\w\[\e[m\]]" #Working directory
PS1="$PS1\n\[\e[35m\]\u\[\e[m\]@\[\e[36m\]\H\[\e[m\]" #User and Host
export PS1="$PS1\n\[\e[33m\]$? \[\e[m\] \[\e[32m\] \`parse_git_branch\` \[\e[m\]\[\e[31m\]>\[\e[m\] " # Branch

function br(){
    open -a /Applications/Brackets.app $1
}
function jet(){
    open -a /Applications/IntelliJ\ IDEA\ 14.app $1
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
