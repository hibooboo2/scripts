export MYSCRIPTS="$HOME/scripts/"
export PATH="${MYSCRIPTS}:${PATH}"

export PS1="\[\e[00;35m\]\u\[\e[0m\]\[\e[00;37m\]@\[\e[0m\]\[\e[00;36m\]\H\[\e[0m\]\[\e[00;37m\]\n[\[\e[0m\]\[\e[00;32m\]\w\[\e[0m\]\[\e[00;37m\]]\n\[\e[0m\]\[\e[00;33m\]\$?\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;31m\] \[\`git rev-parse --abbrev-ref HEAD\`\]  >\[\e[0m\]"

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
alias ls="ls -G -t -A -p -h --color"
alias home="cd ~"
alias ccat="highlight -O ansi -i"cd 
