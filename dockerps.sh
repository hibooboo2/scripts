counter=0
while [ $counter -le 10 ]
do
    result = $(docker ps $1 > docker.txt; diff -q docker.txt docker2.txt;mv docker.txt docker2.txt)
    if [ -z "$result" ]; then
    clear
    cat docker2.txt
    sleep 1
    fi
done