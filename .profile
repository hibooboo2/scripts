#!/bin/bash
. ${HOME}/.privateVars

pushd "$( dirname "${BASH_SOURCE[0]}" )" && pwd


if test "${PS1+set}";
then
	if [ "${SCRIPTS_UPDATE}" == "true" ]
	then
	    git fetch --all
	    git checkout origin/master
	    git submodule init
	    git submodule update

	fi
fi

if test "${TERM+set}";
then
    . ./.commonvars
    . ./.dockerStuff
    . ./.profile.sh

	export CDPATH=".:~:${CODE_HOME}/:${CDPATH}"
	export CDPATH=":${CDPATH}:${GOPATH}/src/github.com/"
	export CDPATH=":${CDPATH}:${GOPATH}/src/github.com/jjeffrey-bolste/"
	export CDPATH=":${CDPATH}:${GOPATH}/src/github.com/hibooboo2/"
	export CDPATH=":${CDPATH}:${GOPATH}/src/gogs.jhrb.us/wizardofmath/"
	export CDPATH=":${CDPATH}:${HOME}/projects"
	clear
fi

popd
