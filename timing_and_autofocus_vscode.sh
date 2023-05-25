#!/bin/bash

export FIRST_FOLDER_OPENED=$(pwd)

function time_before_command() {
    export LAST_TRAP_TIME=$(date +%s)
}

function __timing_and_diff() {
    local current_time=$(date +%s)
    export __time_diff=$((current_time-LAST_TRAP_TIME))
}

export TIME_NEEDED_TO_FOCUS_VSCODE=30
function __focus_vs_code() {
    if [ "${TERM_PROGRAM}" = "vscode" ]; then
        if [ "$__time_diff" -gt "${TIME_NEEDED_TO_FOCUS_VSCODE}" ]; then
            code ${FIRST_FOLDER_OPENED}
        fi
    fi
}

export PROMPT_COMMAND="__timing_and_diff;${PROMPT_COMMAND};__focus_vs_code"

trap time_before_command DEBUG
