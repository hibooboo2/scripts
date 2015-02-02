count=0
while [ $count -lt 10000 ]
do
    docker run -d hibooboo2/counting
    count+=1
done
