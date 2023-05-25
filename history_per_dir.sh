#!/bin/bash

function change_history_file() {
    local history_file_dir="${HOME}/.bash_history_files/$(pwd)"
    mkdir -p ${history_file_dir}
    local new_history_file="${history_file_dir}/.bash_history"
    if [ "${HISTFILE}" != "${new_history_file}" ];then
        history -a
        echo "new_history_file=${new_history_file}"
        export HISTFILE=${new_history_file}
        history -c 
        history -r
    fi
}

export PROMPT_COMMAND="change_history_file;${PROMPT_COMMAND}"
