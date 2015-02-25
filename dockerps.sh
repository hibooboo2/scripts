counter=0
while sleep 0.5
do
    result = $(docker ps $1 > $MYSCRIPTS/.docker.txt; diff -q $MYSCRIPTS/.docker.txt $MYSCRIPTS/.docker2.txt;mv $MYSCRIPTS/.docker.txt $MYSCRIPTS/.docker2.txt)
    if [ -z "$result" ]; then
    clear
    cat $MYSCRIPTS/.docker2.txt
    wc -l < $MYSCRIPTS/.docker2.txt
    fi
done

#Containers=$(docker ps -qa)
#for i in $Containers
#do
#    Inspect=$(docker inspect $i)
#    echo Name = $(echo $Inspect | jq -r .[0].Name) Image  = $(echo $Inspect | jq -r .[0].AppArmorProfile)
#    
#done