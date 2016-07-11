#!/bin/bash

if [ -z "$1" ]
then
printf "\n\n"
echo "please add a queue argument"
echo "exiting"
exit 1
fi


q0_nodes=`qmgr -c 'p n @d'|grep -w $1|awk '{print $3}'|paste -s -d' '`
node_ncpu_sum=0
for qnode in ${q0_nodes[@]};do 
node_ncpu=`qmgr -c "p n $qnode"|grep ncpus|awk '{print $6}'` 
let "node_ncpu_sum = node_ncpu + node_ncpu_sum"
done
echo "cores in $1 queue : "$node_ncpu_sum
