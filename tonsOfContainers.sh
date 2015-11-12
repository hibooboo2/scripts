#!/usr/bin/env bash

set -e

count=0
while [ $count -lt 10000 ]
do
    docker run -d hibooboo2/counting
    sleep 1
    count=$(($count+1))
    echo $count
done
