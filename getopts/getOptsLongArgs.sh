#!/bin/bash
: ${SHORT_OPTS:="ab:c-:"} # The -: allows long flags ex --this-is-a-flag --thisflag --flag
: ${LONG_OPTS:="[flag]:[arg]:[flag-long][flag-longer-arg]:"}

set -x

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
            echo Using = approch.
            FLAG=$(echo ${opt} |cut -f 1 -d "=")

            [[ ${LONG_OPTS} != *\[${FLAG}\]* ]] && echo "$(tput setaf 1) Flag: --${FLAG} is not a valid flag $(tput sgr0)" && exit 1
            [[ ${LONG_OPTS} != *\[${FLAG}\]:* ]] && echo "$(tput setaf 1) Flag: --${FLAG} doesn\'t take an argument $(tput sgr0)" && exit 1

            val=${opt#*=}
            opt=${opt%=${val}}
            OPTARG=${val}

        elif [[ ${LONG_OPTS} = *\[${opt}\]:* ]]
        then
            echo Using --long-flag arg1
            OPTARG="${1}"
            [[ -z ${OPTARG} ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
            [[ ${OPTARG} = -* ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
            OPTIND=$(( $OPTIND + 1 ))

        elif  [[ ${LONG_OPTS} = *\[${opt}\]* ]]
        then
            echo No args --long-flag
            OPTARG=

        else
            echo $(tput setaf 1) Flag: --${opt} is not a valid flag $(tput sgr0)
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
done

exit 0