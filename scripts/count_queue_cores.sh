#!/bin/bash

if [ -z "$1" ]
then
printf "\n\n"
echo "please add a queue argument or \"all\" for all power5 cpus"
echo "exiting"
exit 1
fi

if [ $1 = all ]
then
all_power5_cores=`qmgr -c 'p n @d'|grep ncpu|awk '{sum+=$6}END{print sum}'`
echo "all power5 cores : "$all_power5_cores
exit 0 
fi

q0_nodes=`qmgr -c 'p n @d'|grep -w $1|awk '{print $3}'|paste -s -d' '`
node_ncpu_sum=0
for qnode in ${q0_nodes[@]};do 
node_ncpu=`qmgr -c "p n $qnode"|grep ncpus|awk '{print $6}'` 
let "node_ncpu_sum = node_ncpu + node_ncpu_sum"
done
echo "cores in $1 queue : "$node_ncpu_sum
