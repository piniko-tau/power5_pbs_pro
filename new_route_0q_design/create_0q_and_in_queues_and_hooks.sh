#!/bin/bash
#
#new queue originalQ_in
#
#route : originalQ_0q -> originalQ_p0q -> originalQ
#
#this script will create a new queue_in :

#1)first create and populate originalQ_0q (0q copy)
#2)then create and populate originalQ_p0q (all-0q copy)
#3)finally create a originalQ_in,originalQ_p0qr,originalQ_0q routing queues
## originalQ_in - regular_in routing queue
## originalQ_0qr - 0q -> originalQ
## originalQ_p0qr - p0q -> originalQ
# the qsub_in script will send the job to the right place


if [ -z "$1" ] 
then 
printf "\n\n"
echo "please add a queue argument"
echo "exiting"
exit 1
fi

echo "#######################################################################################################################"
echo "################################### IN QUEUE CONFIGS START ############################################################"
echo "#######################################################################################################################"


########################################################################################
echo "########################### PART 1 #####################################"

###################################### check total number of nodes for limit ##################
original_q_ncpu_sum=`count_queue_cores.sh $1|awk '{print $6}'`

################################################## first create a 0q copy of the original queue
printf "\nNew 0q queue setup :\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_0q/g'|sed 's/Priority = 200/Priority = 100/g'
#add :
echo "set queue $1_0q max_queued_res.ncpus = [o:PBS_ALL=$original_q_ncpu_sum]"
echo "set queue $1_0q queued_jobs_threshold = [o:PBS_ALL = 5]"

printf "\n\n"
##################################################################################################################
echo "###################################### add the nodes to the queue #########################################################"
connect_queue_2_nodes_check.sh $1 $1_0q|sed 's/ '$1' / '$1'_0q /g'
printf "\n\n"
#####################################################################################33
#calculate the queue_0q nodes from the original:

q0_nodes=`qmgr -c 'p n @d'|grep -w $1|awk '{print "\""$3"\""}'|paste -s -d','`

########################################################################################3
echo "#################################################### then create a 0q hook for this queue"
printf "\n\n"
echo "qmgr -c \"create hook check_and_route_$1_in event=\"queuejob\"\""
printf "\n\tHook File check_and_route_$1_in contents:\n\n"
printf "\nPut this is /var/spool/PBS/hooks/check_and_route_$1_in.py\n"
cat <<EOF
import pbs
import sys
#qmgr -c 'create hook check_and_route_$1_in event="queuejob"'
#qmgr -c 'import hook check_and_route_$1_in application/x-python default /var/spool/PBS/hooks/check_and_route_$1_in.py' 
#qmgr -c 'd h check_and_route_$1_in'
try:
	e = pbs.event()	
	if e.job.queue:
		if (e.job.queue.name in ["$1_in"]):
			if (e.job.Variable_List["in_queue_credential"] != "1"):
		        	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to this queue!")

except SystemExit:
	pass
except :
	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to this queue!")
EOF
printf "\n\n"

echo "qmgr -c \"import hook check_and_route_$1_in application/x-python default /var/spool/PBS/hooks/check_and_route_$1_in.py\""
printf "\n\n"

###########################################################################################

echo "################################# PART 2 ###################################################"

#then create a original_p0q of everything else 
#meaning that it contans all the nodes NOT in original_0q

#########################################################################################################
echo "################################################## create a 0q copy of the original queue"
printf "\nNew p0q queue setup :\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/'"$1"'/'"$1"'_p0q/g'|sed 's/Priority = 200/Priority = 100/g'
#add :
echo "set queue $1_p0q queued_jobs_threshold = [o:PBS_ALL = 1]"
printf "\n\n"
###############################################################################################
echo "###################################### add the nodes to the queue #########################################################"
printf "\n\n Calculating _p0q nodes... \n\n" 
#tamir-short and nano are off limits for now
p0q_queue_list=(dieguez inf shokefmem paster gophna shokef amir-express hugemem parallel bigmem short schwartz geos amir-medium sunny phys barkana adis)
for queue in ${p0q_queue_list[@]};do
        if [ $queue = "$1" ];then continue;fi
        connect_queue_2_nodes_check.sh $queue $1_p0q|sed 's/ '$queue' / '$1'_p0q /g'
done|grep qmgr|sort -u
printf "\n\n"

echo "Please run the suggested commands , only then press [ENTER]:"
read ans

printf "\n\n"
#############################################################################################################################
echo "############################# add 0q run limit to the queue  ########################################################"
p0q_ncpu_sum=`count_queue_cores.sh $1_p0q|awk '{print $6}'`
echo "add this limit to the p0q : "
echo "set queue $1_p0q max_queued_res.ncpus = [o:PBS_ALL=$p0q_ncpu_sum]"
printf "\n\n"

###########################################################################################
echo "################# PART 3 #############################################################################"
echo "######################## Routing queues  #############################################################################################"
printf "\n\n"
echo "Create the routing queue $_in:"
printf "\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/Execution/Route/g'|sed 's/'"$1"'/'"$1"'_in/g'|grep -v 'default_chunk'
echo "set queue $1_in route_destinations = $1_0q"
echo "set queue $1_in route_destinations += $1_p0q"
echo "set queue $1_in route_destinations += $1"
echo ""
echo "repeat if needed : set queue $1_in enabled = True"

printf "\n\n"

echo "Create the routing queue $_0qr:"
printf "\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/Execution/Route/g'|sed 's/'"$1"'/'"$1"'_0qr/g'|grep -v 'default_chunk'
echo "set queue $1_0qr route_destinations = $1_0q"
echo "set queue $1_0qr route_destinations += $1"
echo ""
echo "repeat if needed : set queue $1_0qr enabled = True"

printf "\n\n"
echo "Create the routing queue $_p0qr:"
printf "\n\n"
qmgr -c "p q $1"|grep -v '^#'|sed 's/Execution/Route/g'|sed 's/'"$1"'/'"$1"'_p0qr/g'|grep -v 'default_chunk'
echo "set queue $1_p0qr route_destinations += $1_p0q"
echo "set queue $1_p0qr route_destinations += $1"
echo ""
echo "repeat if needed : set queue $1_p0qr enabled = True"

printf "\n\n"


echo "#######################################################################################################################"
echo "################################### IN QUEUE CONFIGS END ##############################################################"
echo "#######################################################################################################################"


printf "\n\n"
echo "#################################### HOW TO DELETE THESE CONFIGS : #####################################################"
printf "\n\n"
echo "qmgr -c \"d h check_and_route_$1_in\""
echo "qmgr -c \"d q $1_0q\""
echo "qmgr -c \"d q $1_p0q\""
echo "qmgr -c \"d q $1_0qr\""
echo "qmgr -c \"d q $1_p0qr\""
echo "qmgr -c \"d q $1_in\""
echo "qmgr -c \"p n @d\"|grep "adis_"|sed 's/+/-/g'"
printf "\n\n"
echo "#################################### END OF DELETE CONFIGS SECTION  #####################################################"

