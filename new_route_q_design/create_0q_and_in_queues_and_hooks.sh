#!/bin/bash
#
#new queue original_in
#
#route : original_0q -> original_p0q -> original
#
#this script will create a new queue_in :

#1)first create and populate original_0q (0q copy)
#2)then create and populate original_p0q (all-0q copy)
#3)finally create a original_in outing queue 

if [ -z "$1" ] 
then 
printf "\n\n"
echo "please add a queue argument"
echo "exiting"
exit 1
fi

############################ PART 1 #####################################

###################################### check total number of nodes for limit ##################
original_q_ncpu_sum=`count_queue_cores.sh $1|awk '{print $6}'`

################################################## first create a 0q copy of the original queue
printf "\nNew 0q queue setup :\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_0q/g'
#add :
echo "set queue $1_0q from_route_only = True"
echo "set queue $1_0q default_chunk.Qlist = $1_0q"
echo "set queue $1_0q max_queued_res.ncpus = [o:PBS_ALL=$original_q_ncpu_sum]"

printf "\n\n"
###################################### add the nodes to the queue #########################################################
connect_queue_2_nodes_check.sh $1 $1_0q|sed 's/ '$1' / '$1'_0q /g'
printf "\n\n"
#####################################################################################33
#calculate the queue_0q nodes from the original:

q0_nodes=`qmgr -c 'p n @d'|grep -w $1|awk '{print "\""$3"\""}'|paste -s -d','`

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
			next_queue = pbs.server().queue("$1_p0q")
			e.job.queue = next_queue	
except SystemExit:
	pass
except :
	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to this queue!")
EOF
print "\n\n"

echo "qmgr -c \"import hook check_and_route_$1_0q application/x-python default /var/spool/PBS/hooks/check_and_route_$1_0q.py\""

###########################################################################################

################################# PART 2 ###################################################3

#then create a original_p0q of everything else 
#meaning that it contans all the nodes NOT in original_0q

################################################## create a 0q copy of the original queue
printf "\nNew p0q queue setup :\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_p0q/g'
#add :
echo "set queue $1_p0q from_route_only = True"
echo "set queue $1 default_chunk.Qlist = $1_p0q"
printf "\n\n"
###############################################################################################
###################################### add the nodes to the queue #########################################################

#tamir-short and nano are off limits for now
p0q_queue_list=(dieguez inf shokefmem paster gophna shokef amir-express hugemem parallel bigmem short schwartz geos amir-medium sunny phys barkana adis)
p0q_queue_list=(dieguez inf adis)
for queue in ${p0q_queue_list[@]};do
        if [ $queue = "$1" ];then continue;fi
        connect_queue_2_nodes_check.sh $queue $1_p0q|sed 's/ '$queue' / '$1'_p0q /g'
done|grep qmgr|sort -u
printf "\n\n"
############################# add 0q run limit to the queue  ########################################################33
p0q_ncpu_sum=`count_queue_cores.sh $1|awk '{print $6}'`
echo "add this limit to the p0q : "
echo "set queue $1_p0q max_queued_res.ncpus = [o:PBS_ALL=$p0q_ncpu_sum]"
printf "\n\n"

######################################## then create a p0q hook for this queue



#####################################################################################################################

#finally create the routing queue :
#qmgr -c 'p q adis'|grep -v '^#'|sed s/Execution/Route/g|sed 's/adis/adis_in/g'
##add : 
#echo 'set queue adis_in route_destinations = adis_0q'
#echo 'set queue adis_in route_destinations += power_queue_0q'
#echo 'set queue adis_in route_destinations += adis'

