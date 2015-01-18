export MYSCRIPTS="$HOME/scripts/"
export PATH="${MYSCRIPTS}:${Build_Tools}:${PATH}"

function parse_git_branch(){
    BRANCH=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
    if [ ! "${BRANCH}" == "" ];then
        echo "[${BRANCH}]"
    else
        echo ""
    fi
}

PS1="[\[\e[32m\]\w\[\e[m\]]"
PS1="$PS1\n\[\e[35m\]\u\[\e[m\]@\[\e[36m\]\H\[\e[m\]"
export PS1="$PS1\n\[\e[33m\]$? \[\e[m\] \[\e[32m\] \`parse_git_branch\` \[\e[m\]\[\e[31m\]>\[\e[m\] "

function br(){
    open -a /Applications/Brackets.app $1
}

function mkexe(){
    chmod u+rwx $1
}

function addAlias(){
    echo "alias $1" >> ~/.profile
}

alias del="rm -rf"
alias ls="ls -G -t -A -p -h"
alias home="cd ~"
alias ccat="highlight -O ansi -i"