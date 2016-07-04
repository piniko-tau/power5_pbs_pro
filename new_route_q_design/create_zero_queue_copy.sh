#!/bin/bash
#
#new queue adis_in
#
#route : adis_0q -> power_0q -> adis
#
#this script will create a new queue_in :
#

if [ -z "$1" ] 
then 
printf "\n\n"
echo "please add a queue argument"
echo "exiting"
exit 1
fi

let queue_node_ncpus_sum=0

for queue_node in `qmgr -c 'p n @d'|grep $1|awk '{print $3}'`;do
let queue_node_ncpus=`qmgr -c "p n $queue_node"|grep vailable.ncpus|awk '{print $6}'`
let queue_node_ncpus_sum=queue_node_ncpus_sum+queue_node_ncpus
done 

printf "\nNew 0q queue setup :\n\n"
#first create a 0q copy of the original queue
#adis_0q queue
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_0q/g'
#add :
echo "set queue $1_0q from_route_only = True"
echo "set queue $1_0q max_queued_res.ncpus = [o:PBS_ALL=$queue_node_ncpus_sum]"
#then do power_0q1 -> adis power_0qa1 a 0 queue specific to adis_0q
#meaning that it contans all the nodes NOT in adis_0q

#qmgr -c 'p q adis'|grep -v '^#'|sed s/Execution/Route/g|sed 's/adis/adis_in/g'
##add : 
#echo 'set queue adis_in route_destinations = adis_0q'
#echo 'set queue adis_in route_destinations += power_queue_0q'
#echo 'set queue adis_in route_destinations += adis'

