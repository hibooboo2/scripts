#!/bin/bash
#Add short help
#Add rest of usage
# ping slack that all nodes are up and running.
VERBOSE_MODE="false"
myEcho(){
    if [ "$VERBOSE_MODE" == "true" ]
    then
        echo $(tput setaf $(echo $((RANDOM%7+1)))) ${@} $(tput sgr0)
    fi
}
isNum() {
    re='^[0-9]+$'
    if ! [[ ${1} =~ $re ]] ; then
        myEcho "${1} is not a valid number" >&2; showShortHelp; exit 3
    fi
}
isValidRepoCommit() {
    local SUPPLIED=${1}
    arrIN=(${SUPPLIED//// })
    [[ -z "${arrIN[0]}" || -z "${arrIN[1]}" ]] && myEcho ${1} is not a proper \{githubUser\}/\{git\|commit/tag/branch\} && exit 4
    return 0
}
showUsage(){
    cat 1>&2 <<EOF
dce-10-acre.sh Usage:
    -M - Memory for master node default:2048
        Needs to be im MB ex: -M 4096
    -m - Memory for slave nodes default:1024
        Needs to be im MB ex: -M 4096


EOF
}

showShortHelp(){
    cat 1>&2 <<EOF
dce-10-acre.sh flags:
    -M(Master Memory) -m(slave memory)
    -C(Master cores) -c(slave cores)
    -v(cattle version)
    -p(python agent version)
    -h(host api version)
    -u(ui version)
    -n(node agent version)
    -N(Cluster name)
    -b(build tools version)
    -H(show Long usage\help)
    -q(silent mode)
    -f(force run without other options. EG: use all defaults. Only needed if no other flags defined.)

Minimal command to use all defaults:
    dce-10-acre.sh -f
    Using above command will yield 4 machines 1 master 3 slaves where the slaves have 1GB ram 2 cores
    The master will have 4 cores 2 gb of ram  and the will use plain build-master.
EOF
}
allEnv(){
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
startBuildMaster() {
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
        -e BUILD_TOOLS_COMMIT=$BUILD_TOOLS_COMMIT \
        -e CATTLE_UI_URL=$CATTLE_UI_URL \
        --privileged \
        rancher/build-master
}

DCE_MASTER_MEM=2048
DCE_SLAVE_MEM=1024
DCE_MASTER_CORES=4
DCE_SLAVE_CORES=2
DCE_CLUSTER_NAME=`whoami`
DCE_RUN="false"
DCE_SKIP_CHECK="false"
DCE_SLAVES=3
while getopts ":M:m:C:c:v:p:h:u:n:b:s:HDqVfdN:" opt; do
    case $opt in
        N)
            DCE_CLUSTER_NAME=$OPTARG
            ;;
        M)
            isNum $OPTARG
            DCE_MASTER_MEM=$OPTARG
            myEcho Master use $OPTARG MB ram
            ;;
        m)
            isNum $OPTARG
            DCE_SLAVE_MEM=$OPTARG
            myEcho Slaves use $OPTARG MB ram
            ;;
        C)
            isNum $OPTARG
            DCE_MASTER_CORES=$OPTARG
            myEcho Master use $OPTARG cores
            ;;
        c)
            isNum $OPTARG
            DCE_SLAVE_CORES=$OPTARG
            myEcho Slaves use $OPTARG cores
            ;;
        v)
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
        h)
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
            myEcho Use $OPTARG Slave nodes
            ;;
        d)
            DELETE_CLUSTER="true"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            showShortHelp
            exit 1
            ;;
        H) showUsage; exit 0;;
        V)
            echo $(tput setaf 2) 'Verbose mode enabled' $(tput sgr0)
            VERBOSE_MODE=true
            ;;
        f)
            DCE_SKIP_CHECK="true"
            ;;
        *)
            myEcho Missing arg for param -$OPTARG
            showShortHelp
            ;;
    esac
    DCE_NO_FLAGS="true"
done
[[ -z "${DCE_NO_FLAGS}" ]] && showShortHelp && exit 1
if [ "${DCE_SKIP_CHECK}" == "false" ]
then
    myEcho Are these options correct? \(Y/N\)
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
    echo $(curl -s -X POST http://$(get_master_ip)/v1/projects/$(get_project_id)/registrationtokens|python -c'import json,sys; print(json.load(sys.stdin)["links"]["self"])')
}

get_total_project_hosts()
{
    echo $(curl -s http://$(get_master_ip)/v1/projects/$(get_project_id)/hosts|python -c'import json,sys; print(len(json.load(sys.stdin).items()[5][1]))')
}

get_reg_url()
{
    ## This is a bit hacky...
    local reg_tokens_link
    reg_tokens_link=$(create_reg_tokens ${1})
    sleep 2
    echo $(curl -s -X GET $reg_tokens_link|python -c'import json,sys; print(json.load(sys.stdin)["registrationUrl"])')
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
    allEnv
    docker-machine scp /tmp/envVars "${DCE_CLUSTER_NAME}-master":/tmp/envVars
    docker-machine ssh "${DCE_CLUSTER_NAME}-master" ". /tmp/envVars;$(typeset -f startBuildMaster);startBuildMaster"
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
    nodes=$(docker-machine ls| grep ${DCE_CLUSTER_NAME} | cut -d " " -f 1)
    for i in ${nodes};
        do
            docker-machine rm ${i}
        done

}
build_cluster()
{
    CLUSTER_EXISTS=$(docker-machine ls | grep ${DCE_CLUSTER_NAME} | cut -d " " -f 1| wc -l)
    [[ "${CLUSTER_EXISTS}" != "0" && "${DELETE_CLUSTER}" != "true" ]] && echo Cluster already exists with ${CLUSTER_EXISTS} nodes && exit 1
    [[ "${DELETE_CLUSTER}" == "true" ]] && delete_cluster
    CLUSTER_EXISTS=$(docker-machine ls | grep ${DCE_CLUSTER_NAME} | cut -d " " -f 1| wc -l)
    if [ "${CLUSTER_EXISTS}" == 0 ]; then
        create_master
        IP=$(get_master_ip)
        echo -n "Waiting for server to start "
        while sleep 3; do
            if [ "$(curl -s http://${IP}/ping)" = "pong" ]; then
                echo Success
                break
            fi
            echo -n "."
        done
        create_slaves
        while sleep 3; do
            if [ "$(get_total_project_hosts)" == "3" ]; then
                #Slack
                echo 3 HOSTS found.
                break
            fi
        done
        exit 0
    else
        echo Cluster exists still, or existed and didn\'t delete
        exit 69
    fi
}

 main() {
    [[ ! -z "${DCE_SLAVES}" ]] && build_cluster
    showUsage
 }

 main