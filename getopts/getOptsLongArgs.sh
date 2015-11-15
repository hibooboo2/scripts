#!/bin/bash
: ${SHORT_OPTS:="h-:"} # The -: allows long flags ex --this-is-a-flag --thisflag --flag
: ${LONG_OPTS:="[flag]:[arg]:[flag-long][flag-longer-arg]:"}

set -x
show_usage() {
            cat << EOF
This is a demonstration script showing how to use the import of long_args support for bash getopts.
If you want to use this source the file as it exports the long_args() function.
Inside of your while loop for getopts before your case statement call:
    long_args "\${!OPTIND}"
Inside of case statement:
    \${opt} (Name of flag / option ex: h or help if -h or --help is passed in.)
    \${OPTARG} (Value of the argument passed in for the flag if there is one.
        ex:
        -f somefile.txt
        --file somefile.txt
        Both of the above would have \${OPTARG} set to somefile.txt

You do need to define \${LONG_OPTS} to define what long flags can be used as well as weather
they have arguments or not. And you must have -: in your schema for the short_opts that your getopts call uses.
Syntax for \${LONG_OPTS}:
    [flag] or [flag]:
    [flag]  defines --flag as a flag that takes no argument.
    [flag-noarg] defines --flag-arg as a flag that takes no argument.
    [flag]: defines --flag as a flag that takes an argument.
    [flag-arg]: defines --flag-arg as a flag that takes an argument.
    ex:
        \${LONG_OPTS}="[help][flagwitharg]:[flagnoarg][another-flag-with-arg]:"
        The above defines 4 flags:
            --help (This takes no argument)
            --flagwitharg (This takes an argument)
            --flagnoarg (This take no argument)
            --another-flag-with-arg (This takes an argument)

When passing in flags short flags work to getopts spec. Long flags do with the exception that
a long flag must be by it self with no other flags touching it and the argument if there  is one has to have a " "
between it and the flag.

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

            [[ ${LONG_OPTS} != *\[${FLAG}\]* ]] && echo "$(tput setaf 1) Flag: --${FLAG} is not a valid flag $(tput sgr0)" && exit 1
            [[ ${LONG_OPTS} != *\[${FLAG}\]:* ]] && echo "$(tput setaf 1) Flag: --${FLAG} doesn\'t take an argument $(tput sgr0)" && exit 1

            val=${opt#*=}
            opt=${opt%=${val}}
            OPTARG=${val}

        elif [[ ${LONG_OPTS} = *\[${opt}\]:* ]]
        then
            OPTARG="${1}"
            [[ -z ${OPTARG} ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
            [[ ${OPTARG} = -* ]] && echo $(tput setaf 1) --${opt} requires an Argument. $(tput sgr0) && exit 1
            OPTIND=$(( $OPTIND + 1 ))

        elif  [[ ${LONG_OPTS} = *\[${opt}\]* ]]
        then
            OPTARG=

        else
            echo $(tput setaf 1) Flag: --${opt} is not a valid flag $(tput sgr0)
            exit 1
        fi
        #End support for long flags. now opt can use cases that are words.
        #You can use FLAG_TYPE to determine weather the called flag was long or short. - is short -- is long.
        #Uncomment below line to display flag with arg that was just parsed.
        # echo ${FLAG_TYPE}${opt} ${OPTARG}
    else
        FLAG_TYPE="-"
    fi
}
[[ -z "${@}" ]] && export long_args && set +x

while  getopts "$SHORT_OPTS" opt; do
    [[ -z "${@}" ]] && break
    long_args "${!OPTIND}"

    case ${opt} in
        \?)
            echo $(tput setaf 1) Invalid Flag $(tput sgr0)
            exit 1
            ;;
        h) show_usage;;

        :)
            echo What happened ${FLAG_TYPE}${opt}${OPTARG}
            ;;
        *)
            echo $(tput setaf 2)  used ${FLAG_TYPE}${opt} ${OPTARG} $(tput sgr0)
            ;;
    esac
done
