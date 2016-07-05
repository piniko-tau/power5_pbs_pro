#!/bin/bash


if [ -z "$1" ] || [ -z "$2" ]
then 
printf "\n\n"
echo "please add a queue argument followed by a Qlist argument"
printf "\n\texample: connect_queue_2_nodes_check.sh adis adis\n"
echo "exiting"
exit 1
fi

printf "\n\n"
echo "Checking if queue $1 and its nodes are defined OK..."
printf "\n\n"
sleep 1

if qmgr -c "p q $1" | grep -q "Qlist = $2"
then
echo -en "\E[32m""Queue $1 Qlist variable is defined ok :"
tput sgr0
printf "\n\t"
qmgr -c "p q $1" | grep "Qlist = $1"
echo ""
else
echo -en "\E[32m""Please set this for $1 queue :"
tput sgr0
printf "\n\n\t"
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
		printf "\n"
		echo -en "\E[32m""Please set this for $1 nodes :"
		tput sgr0
		printf "\n\n"
		fi
		m="True"
		printf "\t"
		echo "qmgr -c \"set node $p5compute resources_available.Qlist += $2\" "
		fi
	fi

done
printf "\n"
