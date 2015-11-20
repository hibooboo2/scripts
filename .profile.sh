#!/bin/bash
export HISTCONTROL=ignoreboth  # no duplicate entries
export HISTSIZE=100000000000000                   # big big history
export HISTFILESIZE=10000000000000000               # big big history
export HISTTIMEFORMAT='%b %d %H:%M:%S: '
shopt -s histappend
set cmdhist

NONE='\[\e[0m\]'
RED='\[\e[0;31m\]'
GREEN='\[\e[0;32m\]'
YELLOW='\[\e[1;33m\]'
BLUE='\[\e[1;34m\]'
PURPLE='\[\e[0;35m\]'
LIGHT_BLUE='\[\e[0;36m\]'
WHITE='\[\e[0;29m\]'
GREY='\[\e[1;30m\]'

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo -n "$var"
}

#PS4 is what is used to prepend commands executed when using set -x
export PS4="${GREY} ${BASH_SOURCE}:${LINENO} ${FUNCNAME[0]:+${FUNCNAME[0]}()} > \[\e[0m\]"

function append_or_blank() {
    local status="$(trim $(git status -s| grep "${1}"| wc -l))"
    if [[ ${status} != 0 ]]
    then
        echo "${1} ${status}"
    fi
}
function parse_git_branch(){
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
    if [ ! "${BRANCH}" == "" ];then
        local added="$(append_or_blank "A")"
        local modified="$(append_or_blank "M")"
        local untracked="$(append_or_blank "??")"
        local rest="$(trim $(git status -s| grep -v "??"|grep -v "M"|grep -v "A" | wc -l))"
        if [[ ${rest} == 0 ]]
        then
            unset rest
        else
            rest="R ${rest}"
        fi
        local staged=$(trim $(git diff --name-only --cached| wc -l))
        if [[ ${staged} == 0 ]]
        then
            unset staged
        else
            staged="S ${staged}"
        fi
        local git_status="${GREY}[ ${PURPLE}${BRANCH}${GREY} ]"
        git_status="${git_status} ( "
        [[ ! -z ${modified} ]] && git_status="${git_status}${YELLOW}${modified}${GREY}|"
        [[ ! -z ${added} ]] && git_status="${git_status}${LIGHT_BLUE}${added}${GREY}|"
        [[ ! -z ${untracked} ]] && git_status="${git_status}${RED}${untracked}${GREY}|"
        [[ ! -z ${rest} ]] && git_status="${git_status}${RED}${rest}${GREY}|"
        [[ ! -z ${staged} ]] && git_status="${git_status}${GREEN}${staged}"
        echo "${git_status%"${git_status##*[!\|]}"} ${GREY})${NONE}"
    else
        echo ""
    fi
}

function __prompt_command() {
    local EXIT="$?"    # This needs to be first

    PS1="\n"
    PS1+="${GREY}[${GREEN} \w ${GREY}] $(parse_git_branch)\n"
    if [ ${EXIT} != 0 ]; then
        EXIT="${RED}${EXIT}${NONE}"
    else
        EXIT="${GREEN}${EXIT}${NONE}"
    fi
    local hour=$(date +"%T" | cut -f 1 -d ":")
    hour="${hour#"${hour%%[!\0]*}"}"
    local time="$(echo $((hour % 12)):$(date +"%T" | cut -f 2-3 -d ":"))"
    PS1+="${GREY}[ ${BLUE}${time}${GREY} ] ${LIGHT_BLUE}\u${NONE}${GREY}@${YELLOW}\h ${GREY}\
    (${YELLOW}+${SHLVL}${GREY}|${YELLOW}%\j${GREY}|${LIGHT_BLUE}!\!${GREY}|${EXIT}${GREY})${NONE} \n"

    PS1+="${LIGHT_BLUE}\$${NONE}${WHITE}${NONE} "
}

function no_sudo_docker(){
    [[ -z "$(which docker)" ]] && echo Docker seems to not be here. && exit 1
    docker ps
    [[ "0" == "${?}" ]] && echo No sudo required to use docker. && exit 0
    sudo groupadd docker
    sudo gpasswd -a ${USER} docker
    sudo service docker restart
}

export PROMPT_COMMAND="__prompt_command"  # Func to gen PS1 after CMDs

function br(){
    open -a /Applications/Brackets.app $1
}
function jet(){
    open -a /Applications/IntelliJ\ IDEA\ 15.app ${1}
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
    if [ ! -z "less" ]
    then
        highlight --force -O ansi -i ${1} | less -r
    else
        highlight --force -O ansi -i ${1}
    fi
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

sendtext () { 
    curl http://textbelt.com/text -d number=${1} -d "message=$2" 
}


alias cd='pushd' #alias cd so it uses the directory stack
alias cdb='popd' #aliad cdb as a command that goes one directory back in the stack
alias del="rm -rf"
alias dirs='dirs -v -l'
alias dm='docker-machine'
alias ga='grep -rnw . -e'
alias gcm="git commit -am"
alias gg='git grep -in'
alias gi='grep -in'
alias goHome='ssh wizardofmath@home.jamescarlharris.com -p 2222'
alias home="cd ~"
alias myip='curl canihazip.com/s'
alias myscripts="cd $MYSCRIPTS"
alias sand="mkdir -p ~/sandbox; cd ~/sandbox"
#Always keep color with less.
alias less="less -r"

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

set +x
