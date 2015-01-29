CMDS="hub jq curl git"
for i in $CMDS
do
        # command -v will return >0 when the $i is not found
	which $i >/dev/null && continue || { echo "$i command not found."; exit 1; }
done
if [ -d ${RANCH_HOME:?"Is is not set. Please set it."} ]; then
    cd $RANCH_HOME
    for i in $(curl https://api.github.com/orgs/rancherio/repos | jq -r .[].name)
    do 
        if [ ! -d "./$i" ]; then
            hub clone rancherio/$i >/dev/null
            echo cloned $i
        else
            echo You already have rancherio/$i
            hub checkout master && hub pull
        fi
        touch .youHaveTheRanch
    done
fi