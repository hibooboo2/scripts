#!/usr/bin/env bash -e
#Add short help
#Add rest of usage
# ping slack that all nodes are up and running.
DCE_NAME=$(basename "$0")
DCE_INSTALLED=$(which ${DCE_NAME})
VERBOSE_MODE="false"

SHORT_FLAGS=":M:m:C:c:v:p:H:u:n:b:s:DqhVfdN:h-:"
LONG_FLAGS="[help][delete][delete-only][cattle-version]:"

show_usage()
{
    cat 1>&2 <<EOF > /tmp/${DCE_NAME}-usage.txt
${DCE_NAME} Usage:
    -M - Memory for master node default:2048
        Needs to be im MB ex: -M 4096
        \$DCE_MASTER_MEM

    -m - Memory for slave nodes default:1024
        Needs to be im MB ex: -M 4096
        \$DCE_SLAVE_MEM

    -C Number of cores to use for the master node (If drive supports this.)
        Needs to be a number ex: -C 4
        \$DCE_MASTER_CORES

    -c Number of cores to use for the slave nodes (If drive supports this.)
        Needs to be a number ex: -c 4
        \$DCE_SLAVE_CORES

    -v | --cattle-version Specify cattle version in format {githubUser}/{branch/tag/commitSha}
        ex:
            ${DCE_NAME} -v rancher/v0.106.0
            ${DCE_NAME} -v rancher/56744ac585f5e0aa39ef7568a08049d305cdea05
            ${DCE_NAME} -v rancher/master

    -p Similar to -v but for Python agent version.
        ex:
            ${DCE_NAME} -p rancher/v0.59.0
            ${DCE_NAME} -p rancher/304646088882dee48f34b330a0182bfe96cec4fd
            ${DCE_NAME} -p rancher/master

    -H Similar to -v but for Host api version.

    -u Similar to -v but for Ui version.

    -n Similar to -v but for Node agent version.

    -b Similar to -v but for build tools version.

    -N Name of the cluster
        ex: ${DCE_NAME} -N rancher-test-cluster
        Master has -master appended and Nodes/slaves have -slave appended.
        Default cluster name is grabbed from whoami
        \$DCE_CLUSTER_NAME

    -h / --help Show this help dialogue.
        ex: ${DCE_NAME} -h

    -V Verbose output. This will display extra text to tell user what is going on while running.
        ex: -V
        Use flag twice to output messages using random colors per line. And set -x
        ex: -VV or -V {some other flags} -V

    -f Run with no confirm using all defaults.

    -q Run quietly. Meaning set +o

    -d | --delete Delete the cluster if it already exists.
        ex: ${DCE_NAME}
        \$DCE_DELETE_CLUSTER
    -D | --delete-only Delete the cluster if it already exists. Then exit. (Preempts other flags.)
        When used no other commands will occur. Cluster will just be deleted.
        ex: ${DCE_NAME}
        \$DCE_DELETE_ONLY


Example usage:
    All defaults: virtual box with 1 master 4 cores 2048 mb ram 3 slaves 2 cores 1096 mb
    ram master for all components from rancher.
        ${DCE_NAME} -f
        or
        ${DCE_NAME} -C 4 -M 2048 -c 2 -m 1024 -s 3

EOF
cat /tmp/${DCE_NAME}-usage.txt | less
}

myEcho(){
    if [ "${VERBOSE_MODE}" == "true" ]
    then
        if [ "${USE_RANDOM_COLORS}" == "true" ]
        then
            echo $(tput setaf $(echo $((RANDOM%7+1)))) ${@} $(tput sgr0)
        else
            echo ${@}
        fi
    fi
}

isNum() {
    re='^[0-9]+$'
    if ! [[ ${1} =~ $re ]] ; then
        myEcho "${1} is not a valid number" >&2; show_short_help; exit 3
    fi
}

isValidRepoCommit() {
    local SUPPLIED=${1}
    arrIN=(${SUPPLIED//// })
    [[ -z "${arrIN[0]}" || -z "${arrIN[1]}" ]] && myEcho ${1} is not a proper \{githubUser\}/\{git\|commit/tag/branch\} && exit 4
    EXISTS=$(curl -s -L github.com/${arrIN[0]}/cattle/tree/${arrIN[1]})
    if [[ ${EXISTS} == *"Not Found"* ]]
    then
        echo ${SUPPLIED} not found on github.
        exit 5
    fi
    return 0
}

show_short_help(){
    cat 1>&2 <<EOF
${DCE_NAME} flags:
    -M(Master Memory) -m(slave memory)
    -C(Master cores) -c(slave cores)
    -v | --cattle-version (cattle version)
    -p(python agent version)
    -H(host api version)
    -u(ui version)
    -n(node agent version)
    -N(Cluster name)
    -b(build tools version)
    -h | --help (show Long usage\help)
    -f(force run without other options. EG: use all defaults. Only needed if no other flags defined.)
    -q(silent/ quiet)
    -d | --delete(delete existing cluster if it exists.)
    -D | --delete-only(Only delete existing cluster if it exists.)

Minimal command to use all defaults:
    ${DCE_NAME} -f
    Using above command will yield 4 machines 1 master 3 slaves where the slaves have 1GB ram 2 cores
    The master will have 4 cores 2 gb of ram  and the will use plain build-master with virtualbox driver.
EOF
}

long_args(){
    #ADD support for long flags.
    #To use just call this function at the begining of the use of getopts before your case statement.
    #Be sure to pass in the value of ${!OPTIND} ex: long_args "${!OPTIND}"
    #Not sure why but cannot call ${!OPTIND} from within the function and get correct value so Must do It before hand
    #and pass in as a var or arg. So I chose arg.
    if [ "$opt" == "-" ]
    then
        #Uncomment line to print current flag before processing
        #echo  $(tput setaf 3) OPTARG: $OPTARG$(tput sgr0)
        opt=$OPTARG
        FLAG_TYPE="--"
        echo OPT:${opt}
        echo 1:${1}
        if [[ ${opt} = *=* ]]
        then
            FLAG=$(echo ${opt} |cut -f 1 -d "=")

            [[ ${LONG_FLAGS} != *\[${FLAG}\]* ]] && echo "$(tput setaf 1) Flag: --${FLAG} is not a valid flag $(tput sgr0)" && show_short_help && exit 1
            [[ ${LONG_FLAGS} != *\[${FLAG}\]:* ]] && echo "$(tput setaf 1) Flag: --${FLAG} doesn\'t take an argument $(tput sgr0)" && show_short_help && exit 1

            val=${opt#*=}
            opt=${opt%=${val}}
            OPTARG=${val}

        elif [[ ${LONG_FLAGS} = *\[${opt}\]:* ]]
        then
            OPTARG="${1}"
            [[ -z ${OPTARG} ]] && echo "$(tput setaf 1) --${opt} requires an Argument. $(tput sgr0)" && show_short_help && exit 1
            [[ ${OPTARG} = -* ]] && echo "$(tput setaf 1) --${opt} requires an Argument. $(tput sgr0)" && show_short_help && exit 1
            OPTIND=$(( $OPTIND + 1 ))

        elif  [[ ${LONG_FLAGS} = *\[${opt}\]* ]]
        then
            OPTARG=

        else
            echo "$(tput setaf 1) Flag: --${opt} is not a valid flag $(tput sgr0)"
            show_short_help
            exit 1
        fi
        #End support for long flags. now opt can use cases that are words.
        #You can use FLAG_TYPE to determine weather the called flag was long or short. - is short -- is long.
        #Uncomment above line to display flag with arg that was just parsed.
        # echo ${FLAG_TYPE}${opt} ${OPTARG}
    else
        FLAG_TYPE="-"
    fi
}

all_env(){
    : ${CATTLE_REPO:="https://github.com/rancher/cattle.git"}
    : ${CATTLE_WORK_DIR:=cattle}
    : ${CATTLE_COMMIT:=master}
    : ${PYTHON_AGENT_REPO:="https://github.com/rancher/python-agent.git"}
    : ${PYTHON_AGENT_WORK_DIR:=python-agent}
    : ${PYTHON_AGENT_COMMIT:=master}
    : ${HOST_API_REPO:="https://github.com/rancher/host-api.git"}
    : ${HOST_API_WORK_DIR:=host-api}
    : ${HOST_API_COMMIT:=master}
    : ${UI_REPO:="https://github.com/rancher/ui.git"}
    : ${UI_WORK_DIR:=ui}
    : ${UI_COMMIT:=master}
    : ${VALIDATION_TESTS_REPO:="https://github.com/rancher/validation-tests.git"}
    : ${VALIDATION_TESTS_WORK_DIR:=validation-tests}
    : ${VALIDATION_TESTS_COMMIT:=master}
    : ${NODE_AGENT_REPO:="https://github.com/rancher/node-agent.git"}
    : ${NODE_AGENT_WORK_DIR:=node-agent}
    : ${NODE_AGENT_COMMIT:=master}
    : ${BUILD_TOOLS_REPO:="https://github.com/rancher/build-tools.git"}
    : ${BUILD_TOOLS_COMMIT:=master}
    : ${CATTLE_UI_URL:="http://cdn.rancher.io/ui/latest/static/index.html"}
    cat << EOF > /tmp/envVars
export CATTLE_REPO=$CATTLE_REPO
export CATTLE_WORK_DIR=$CATTLE_WORK_DIR
export CATTLE_COMMIT=$CATTLE_COMMIT
export PYTHON_AGENT_REPO=$PYTHON_AGENT_REPO
export PYTHON_AGENT_WORK_DIR=$PYTHON_AGENT_WORK_DIR
export PYTHON_AGENT_COMMIT=$PYTHON_AGENT_COMMIT
export HOST_API_REPO=$HOST_API_REPO
export HOST_API_WORK_DIR=$HOST_API_WORK_DIR
export HOST_API_COMMIT=$HOST_API_COMMIT
export UI_REPO=$UI_REPO
export UI_WORK_DIR=$UI_WORK_DIR
export UI_COMMIT=$UI_COMMIT
export VALIDATION_TESTS_REPO=$VALIDATION_TESTS_REPO
export VALIDATION_TESTS_WORK_DIR=$VALIDATION_TESTS_WORK_DIR
export VALIDATION_TESTS_COMMIT=$VALIDATION_TESTS_COMMIT
export NODE_AGENT_REPO=$NODE_AGENT_REPO
export NODE_AGENT_WORK_DIR=$NODE_AGENT_WORK_DIR
export NODE_AGENT_COMMIT=$NODE_AGENT_COMMIT
export BUILD_TOOLS_REPO=$BUILD_TOOLS_REPO
export BUILD_TOOLS_COMMIT=$BUILD_TOOLS_COMMIT
export CATTLE_UI_URL=$CATTLE_UI_URL
EOF
}

start_build_master() {
    . /tmp/envVars
    docker run -d -p 80:8080 \
        -e CATTLE_REPO=$CATTLE_REPO \
        -e CATTLE_WORK_DIR=$CATTLE_WORK_DIR \
        -e CATTLE_COMMIT=$CATTLE_COMMIT \
        -e PYTHON_AGENT_REPO=$PYTHON_AGENT_REPO \
        -e PYTHON_AGENT_WORK_DIR=$PYTHON_AGENT_WORK_DIR \
        -e PYTHON_AGENT_COMMIT=$PYTHON_AGENT_COMMIT \
        -e HOST_API_REPO=$HOST_API_REPO \
        -e HOST_API_WORK_DIR=$HOST_API_WORK_DIR \
        -e HOST_API_COMMIT=$HOST_API_COMMIT \
        -e UI_REPO=$UI_REPO \
        -e UI_WORK_DIR=$UI_WORK_DIR \
        -e UI_COMMIT=$UI_COMMIT \
        -e VALIDATION_TESTS_REPO=$VALIDATION_TESTS_REPO \
        -e VALIDATION_TESTS_WORK_DIR=$VALIDATION_TESTS_WORK_DIR \
        -e VALIDATION_TESTS_COMMIT=$VALIDATION_TESTS_COMMIT \
        -e NODE_AGENT_REPO=$NODE_AGENT_REPO \
        -e NODE_AGENT_WORK_DIR=$NODE_AGENT_WORK_DIR \
        -e NODE_AGENT_COMMIT=$NODE_AGENT_COMMIT \
        -e BUILD_TOOLS_REPO=$BUILD_TOOLS_REPO \
        -e CATTLE_UI_URL=$CATTLE_UI_URL \
        --privileged \
        rancher/build-master
}

: ${DCE_MASTER_MEM=2048}
: ${DCE_SLAVE_MEM=1024}
: ${DCE_MASTER_CORES=4}
: ${DCE_SLAVE_CORES=2}
: ${DCE_CLUSTER_NAME=$(whoami)}
: ${DCE_RUN="false"}
: ${DCE_SKIP_CHECK="false"}
: ${DCE_SLAVES=3}
: ${DCE_USE_NGROK:="false"}
: ${DCE_NGROK_SUBDOMAIN:=}
: ${DCE_NGROK_CLIENT_URL:=https://dl.ngrok.com/ngrok_2.0.19_linux_amd64.zip}

while getopts "${SHORT_FLAGS}" opt; do

    long_args "${!OPTIND}"

    case $opt in
        \?)
            echo "Invalid option: -$OPTARG" >&2
            show_short_help
            exit 1
            ;;
        N)
            DCE_CLUSTER_NAME=$OPTARG
            ;;
        M)
            isNum $OPTARG
            DCE_MASTER_MEM=$OPTARG
            ;;
        m)
            isNum $OPTARG
            DCE_SLAVE_MEM=$OPTARG
            ;;
        C)
            isNum $OPTARG
            DCE_MASTER_CORES=$OPTARG
            ;;
        c)
            isNum $OPTARG
            DCE_SLAVE_CORES=$OPTARG
            ;;
        v | cattle-version)
            #Set version of cattle. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            CATTLE_REPO="https://github.com/${arrIN[0]}/cattle.git"
            CATTLE_COMMIT=${arrIN[1]}
            myEcho Using cattle version $CATTLE_REPO:$CATTLE_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/cattle/tree/${arrIN[1]}
            ;;
        p)
            #Set version of python agent. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            PYTHON_AGENT_REPO="https://github.com/${arrIN[0]}/python-agent.git"
            PYTHON_AGENT_COMMIT=${arrIN[1]}
            myEcho Using cattle version $PYTHON_AGENT_REPO:$PYTHON_AGENT_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/python-agent/tree/${arrIN[1]}
            ;;
        H)
            #Set version of hostapi. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            HOST_API_REPO="https://github.com/${arrIN[0]}/host-api.git"
            HOST_API_COMMIT=${arrIN[1]}
            myEcho Using cattle version $HOST_API_REPO:$HOST_API_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/host-api/tree/${arrIN[1]}
            ;;
        u)
            #Set version of ui. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            UI_REPO="https://github.com/${arrIN[0]}/ui.git"
            UI_COMMIT=${arrIN[1]}
            myEcho Using cattle version $UI_REPO:$UI_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/ui/tree/${arrIN[1]}
            ;;
        n)
            #Set version of node agent. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            NODE_AGENT_REPO="https://github.com/${arrIN[0]}/node-agent.git"
            NODE_AGENT_COMMIT=${arrIN[1]}
            myEcho Using cattle version $NODE_AGENT_REPO:$NODE_AGENT_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/node-agent/tree/${arrIN[1]}
            ;;
        b)
            #Set version of build tools. In form of {githubUser}/{commit/tag/branch}
            isValidRepoCommit $OPTARG; arrIN=(${OPTARG//// })
            BUILD_TOOLS_REPO="https://github.com/${arrIN[0]}/build-tools.git"
            BUILD_TOOLS_COMMIT=${arrIN[1]}
            myEcho Using cattle version $BUILD_TOOLS_REPO:$BUILD_TOOLS_COMMIT
            myEcho Github Web view: github.com/${arrIN[0]}/build-tools/tree/${arrIN[1]}
            ;;
        s)
            isNum $OPTARG
            DCE_SLAVES=$OPTARG
            ;;
        d | delete)
            DCE_DELETE_CLUSTER="true"
            ;;
        D | delete-only)
            DCE_DELETE_CLUSTER="true"
            DCE_DELETE_ONLY="true"
            ;;
        V)
            echo $(tput setaf 2) 'Verbose mode enabled' $(tput sgr0)
            [[ "${VERBOSE_MODE}" == "true" ]] && USE_RANDOM_COLORS=true && set -x
            VERBOSE_MODE=true
            ;;
        q)
            VERBOSE_MODE=false
            ;;
        f)
            DCE_SKIP_CHECK="true"
            ;;
        h | help)
            if [ -z "${DCE_INSTALLED}" ]
            then
                echo ${DCE_NAME} is not installed on your system.
                echo Thought you should know.
            else
                echo ${DCE_NAME} is installed. To run just type: ${DCE_NAME}
            fi
            show_usage
            exit 0
            ;;
        *)
            myEcho Missing arg for param -$OPTARG
            show_short_help
            exit 1
            ;;
    esac
    DCE_NO_FLAGS="true"
done
[[ -z "${DCE_NO_FLAGS}" ]] && show_short_help && exit 1
if [ "${DCE_SKIP_CHECK}" == "false" ]
then
    (set -o posix; set) | grep DCE_
    echo $(tput setaf 3) Are these options correct? \(Y/N\) $(tput sgr0)
    read ANS
    [[ "$ANS" != "Y" ]] && myEcho exiting && exit 202
fi


get_master_ip() {
    echo $(docker-machine ip "${DCE_CLUSTER_NAME}-master")
}

get_project_id()
{
    echo $(curl -s -X GET http://$(get_master_ip)/v1/projects|python -c'import json,sys;print(json.load(sys.stdin)["data"][0]["id"])')
}
create_reg_tokens() # Signature: rancher_server_ip
{
    echo $(curl -s -X POST http://${1}/v1/projects/$(get_project_id)/registrationtokens|python -c'import json,sys; print(json.load(sys.stdin)["links"]["self"])')
}

get_total_project_hosts()
{
    echo $(curl -s http://$(get_master_ip)/v1/projects/$(get_project_id)/hosts|python -c'import json,sys; print(len(json.load(sys.stdin).items()[5][1]))')
}

get_run_cmd()
{
    ip=$(get_master_ip)
    reg_tokens_link=$(create_reg_tokens ${ip})
    sleep 1
    DOCKER_ARG="-e CATTLE_AGENT_IP=$(docker-machine ip ${1})"
    COMMAND=$(curl -s -X GET $reg_tokens_link|python -c'import json,sys; print(json.load(sys.stdin)["command"])')
    echo $(echo $(echo ${COMMAND} | cut -d " " -f 1-3)) ${DOCKER_ARG} $(echo $(echo ${COMMAND} | cut -d " " -f 4-))
    # get then args after sudo docker run and be fore -d
}

create_master(){
    myEcho Starting creation of master
    docker-machine create --driver virtualbox --virtualbox-cpu-count "${DCE_MASTER_CORES}" \
        --virtualbox-memory "${DCE_MASTER_MEM}" --virtualbox-no-share "${DCE_CLUSTER_NAME}-master"
    all_env
    docker-machine scp /tmp/envVars "${DCE_CLUSTER_NAME}-master":/tmp/envVars
    docker-machine ssh "${DCE_CLUSTER_NAME}-master" ". /tmp/envVars;$(typeset -f start_build_master);start_build_master"
    myEcho Master created.
}

createSlave() {
    myEcho Creating  ${DCE_CLUSTER_NAME}-slave-${1}
    docker-machine create --driver virtualbox --virtualbox-cpu-count "${DCE_SLAVE_CORES}" \
        --virtualbox-memory "${DCE_SLAVE_MEM}" --virtualbox-no-share "${DCE_CLUSTER_NAME}-slave-${1}"
    docker-machine ssh "${DCE_CLUSTER_NAME}-slave-${1}" "$(get_run_cmd "${DCE_CLUSTER_NAME}-slave-${1}")"
}
create_slaves() {
     for i in `seq 1 ${DCE_SLAVES}`;
        do
            myEcho Creating slave ${i}
            createSlave ${i} &
        done
}

delete_cluster(){
    nodes=$(docker-machine ls -q| grep ${DCE_CLUSTER_NAME})
    for i in ${nodes};
    do
        docker-machine rm ${i}
    done
    [[ "${DCE_DELETE_ONLY}" == "true" ]] && exit 0
}

build_cluster()
{
    CLUSTER_EXISTS=$(echo $(docker-machine ls -q| grep ${DCE_CLUSTER_NAME} | wc -l))
    [[ "${CLUSTER_EXISTS}" != "0" && "${DCE_DELETE_CLUSTER}" != "true" ]] && echo Cluster already exists with ${CLUSTER_EXISTS} nodes && exit 1
    [[ "${DCE_DELETE_CLUSTER}" == "true" ]] && delete_cluster
    CLUSTER_EXISTS=$(echo $(docker-machine ls -q| grep ${DCE_CLUSTER_NAME} | wc -l))
    if [ "${CLUSTER_EXISTS}" == 0 ]; then
        start=$(date -u +"%s")
        create_master
        IP=$(get_master_ip)
        echo -n "Waiting for server to start "

        [[ ${VERBOSE_MODE} == true ]] && set +x
        while sleep 3; do
            if [ "$(curl -s http://${IP}/ping)" = "pong" ]; then
                master=$(date -u +"%s")
                break
            fi
            echo -n "."
        done
        [[ ${VERBOSE_MODE} == true ]] && set -x

        create_slaves

        [[ ${VERBOSE_MODE} == true ]] && set +x

        echo
        echo -n "Waiting for slaves to register "
        while sleep 3; do
            if [ "$(get_total_project_hosts)" == "3" ]; then
                #Slack
                all_slaves=$(date -u +"%s")
                echo 3 HOSTS found.
                break
            fi
            echo -n "."
        done

        [[ ${VERBOSE_MODE} == true ]] && set -x


        diff=$(($master-$start))
        echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed to create master and start rancher."
        diff=$(($all_slaves-$master))
        echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed to create slaves and get them all in rancher."
        exit 0
    else
        echo Cluster exists still, or existed and didn\'t delete
        exit 69
    fi
}

 main() {
    [[ ! -z "${DCE_SLAVES}" ]] && build_cluster
    show_usage
 }

 main
