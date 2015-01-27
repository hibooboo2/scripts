counter=0
while [ $counter -le 10 ]; do
    if [ -z "$(docker ps -a > docker.txt; diff -q docker.txt docker2.txt;mv docker.txt docker2.txt)" ]; then
    clear
    cat docker2.txt
    sleep 2
    fi
done