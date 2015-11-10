#!/bin/bash
export SHORT_OPTS="abc:de:f-:"
export LONG_OPTS="[good][great]:[flag-arg]:[flag-no-arg]"


./getOptsLongArgs.sh --fail
[[ $? == "0" ]] && exit 1

./getOptsLongArgs.sh -a -b -c hello --good
[[ $? != "0" ]] && exit 2

./getOptsLongArgs.sh -t
[[ $? == "0" ]] && exit 3

./getOptsLongArgs.sh -test
[[ $? == "0" ]] && exit 4

./getOptsLongArgs.sh --great arg -bade arg2 -f --good --flag-no-arg
[[ $? != "0" ]] && exit 5

./getOptsLongArgs.sh -good
[[ $? == "0" ]] && exit 6

./getOptsLongArgs.sh --flag-arg 34 --flag-no-arg --great test -abfde toe
[[ $? != "0" ]] && exit 7

./getOptsLongArgs.sh -f --good -c arg1 --great arg2 --flag-arg arg3 -ab --flag-no-arg --good
[[ $? != "0" ]] && exit 8

./getOptsLongArgs.sh -f --good -c arg1 --great arg2 --flag-arg -ab --flag-no-arg --good
[[ $? == "0" ]] && exit 9

./getOptsLongArgs.sh --great -abc arg1
[[ $? == "0" ]] && exit 10

./getOptsLongArgs.sh -great
[[ $? == "0" ]] && exit 11

echo All tests passed
exit 0
