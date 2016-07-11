#!/bin/bash
#
#new queue adis_in
#
#route : original_0q -> original_pq -> original
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

################################################## first create a 0q copy of the original queue
printf "\nNew 0q queue setup :\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_0q/g'
#add :
echo "set queue $1_0q from_route_only = True"
echo "set queue $1 default_chunk.Qlist = $1_0q"
printf "\n\n"
###############################################################################################

#calculate the queue_0q nodes from the original:

q0_nodes=`qmgr -c 'p n @d'|grep -w adis|awk '{print "\""$3"\""}'|paste -s -d','`

#################################################### then create a 0q hook for this queue
echo "qmgr -c \"create hook check_and_route_$1_0q event=\"queuejob\"\""
printf "\n\tHook File check_and_route_$1_0q contents:\n\n"
printf "\nPut this is /var/spool/PBS/hooks/check_and_route_$1_0q.py\n"
cat <<EOF
import pbs
import sys
#qmgr -c 'create hook check_and_route_$1_0q event="queuejob"'
#qmgr -c 'import hook check_and_route_$1_0q application/x-python default /var/spool/PBS/hooks/check_and_route_$1_0q.py' 
#qmgr -c 'd h check_and_route_$1_0q'
try:
	e = pbs.event()	
	if e.job.queue:
		if (e.job.queue.name in ["$1_in","$1_0q"]):
			if (e.job.Variable_List["in_queue_credential"] != "1"):
		        	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to this queue!")

			$1_0q_nodes_list = [$q0_nodes]

			for qnode in $1_0q_nodes_list:

				node=pbs.server().vnode(qnode)
				node_ncpu_total = node.resources_available["ncpus"]
				node_ncpu_used = node.resources_assigned["ncpus"]
				node_ncpu_free = node_ncpu_total - node_ncpu_used
				job_ncpus = e.job.Resource_List["ncpus"]

				if ( job_ncpus > node_ncpu_free ):
					pass
				else:
					e.accept()
					break
			next_queue = pbs.server().queue("$1_pq")
			e.job.queue = next_queue	
except SystemExit:
	pass
except :
	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to this queue!")
EOF
print "\n\n"

echo "qmgr -c \"import hook check_and_route_$1_0q application/x-python default /var/spool/PBS/hooks/check_and_route_$1_0q.py\""

###########################################################################################



#then create a original_pq of everything else 
#meaning that it contans all the nodes NOT in original_0q




#finally create the routing queue :
#qmgr -c 'p q adis'|grep -v '^#'|sed s/Execution/Route/g|sed 's/adis/adis_in/g'
##add : 
#echo 'set queue adis_in route_destinations = adis_0q'
#echo 'set queue adis_in route_destinations += power_queue_0q'
#echo 'set queue adis_in route_destinations += adis'

