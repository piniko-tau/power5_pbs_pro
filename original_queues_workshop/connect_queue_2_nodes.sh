#!/bin/bash


if [ -z "$1" ]
then 
echo "please add a queue argument followed by a Qlist argument"
echo "exiting"
exit 1
fi

echo "checking if queue and nodes are defined OK..."
echo ""
echo ""
sleep 2

if qmgr -c "p q $1" | grep -q "Qlist = $2"
then
printf "queue Qlist variable is defined ok :\n "
qmgr -c "p q $1" | grep "Qlist = $1"
echo ""
else
printf "please set this:\n\n"
echo "qmgr -c \"set queue $1 default_chunk.Qlist = $1\""
fi

p5_git_dir="/root/power5_pbspro_configs_git/nodes"

pbsnodes -a |grep ^com>$p5_git_dir/p5nodes_list

#grep -f $p5_git_dir/nodes_only_power2  $p5_git_dir/p5nodes_list

for p5compute in `cat $p5_git_dir/p5nodes_list` 
do	
#	echo $p5compute
	if qmgr -c "p n $p5compute" | grep -q -w "$2" 
	then
	#echo "$p5compute is connected to $1"
	continue
	else
		if grep $p5compute $p5_git_dir/nodesp2|grep -q $1  
		then	
		if ! [[ $m = True ]] ;then
		printf "\n\nplease set this:\n\n"
		fi
		m="True"
		echo "qmgr -c \"set node $p5compute resources_available.Qlist += $2\" "
		fi
	fi

done
