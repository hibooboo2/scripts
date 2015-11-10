#!/bin/bash
: ${SHORT_OPTS:="ab:c-:"} # The -: allows long flags ex --this-is-a-flag --thisflag --flag
: ${LONG_OPTS:="flag;arg:;flag-long;flag-longer-arg:;"}
set -x
is_valid_long_flag(){
    if [[ ${LONG_OPTS} == *${1}\;* || ${LONG_OPTS} == *${1}:\;* ]]
    then
        return
    else
        echo $(tput setaf 1) --${1} is not valid long flag. $(tput sgr0)
        exit 1
    fi
}

need_arg(){
    if [[ ${LONG_OPTS} == *${1}:* ]]
    then
        echo true
    else
        echo false
    fi
}

long_args(){
    #ADD support for long flags.
    #To use just call this function at the begining of the use of getopts before your case statement.
    #Be sure to pass in the value of ${!OPTIND} ex: long_args "${!OPTIND}"
    #Not sure why but cannot call ${!OPTIND} from within the function and get correct value so Must do It before hand
    #and pass in as a var or arg. So I chose arg.
    if [ "$opt" == "-" ]
    then
        echo  $(tput setaf 3) OPTARG: $OPTARG$(tput sgr0)
        opt=$OPTARG
        FLAG_TYPE="--"

        if [[ $OPTARG == *=* ]]
        then

            EQUALS_USED="true"
            FLAG=$(echo ${OPTARG} |cut -f 1 -d "=")
            is_valid_long_flag ${FLAG}
            NEED_ARG=$(need_arg ${FLAG})
            [[ ${NEED_ARG} == "false" ]] && echo $(tput setaf 1) Flag: --${FLAG} doesn\'t take an argument $(tput sgr0) && exit 1

        else

            EQUALS_USED="false"
            is_valid_long_flag ${OPTARG}
            NEED_ARG=$(need_arg ${OPTARG})

        fi

        if [ ${EQUALS_USED} == "true" ]
        then
            val=${OPTARG#*=}
            opt=${OPTARG%=${val}}
            OPTARG=${val}

        else

            if [ "${NEED_ARG}" == "true" ]
            then

                OPTARG="${1}"
                [[ -z ${OPTARG} ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
                [[ ${OPTARG} = -* ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
                OPTIND=$(( $OPTIND + 1 ))

            else
                OPTARG=
            fi

        fi

    else

        FLAG_TYPE="-"

    fi
    #End support for long flags. now opt can use cases that are words.
    #You can use FLAG_TYPE to determine weather the called flag was long or short. - is short -- is long.
    # echo ${FLAG_TYPE}${opt} ${OPTARG}
    #Uncomment above line to display flag with arg that was just parsed.
}

while  getopts "$SHORT_OPTS" opt; do

    long_args "${!OPTIND}"

    case ${opt} in
        \?)
            echo $(tput setaf 1) Invalid Flag $(tput sgr0)
            exit 1
            ;;
        :)
            echo What happened ${FLAG_TYPE}${opt}${OPTARG}
            ;;
        *)
            echo $(tput setaf 2)  used ${FLAG_TYPE}${opt} ${OPTARG} $(tput sgr0)
            ;;
    esac
    echo done
done

exit 0