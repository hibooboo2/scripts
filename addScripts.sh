#!/bin/bash

: ${MYSCRPITS:=${HOME}/scripts}

[[ ! -z $(which git) ]] && git clone https://github.com/hibooboo2/scripts.git ${MYSCRPITS}
