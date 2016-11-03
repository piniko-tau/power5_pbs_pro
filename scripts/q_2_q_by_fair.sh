#!/bin/bash -l

if [ -z "$1" ] || [ -z "$2" ]
then 
printf "\n\n"
echo "please add source queue and a destination queue arguments: q_2_q_by_fair.sh source_Q destination_Q"
echo "exiting"
exit 1
fi


	s_q=$1
	d_q=$2
	
        s_q_queued="`qstat -w -n -1 $s_q|grep -w Q |awk '{s+=$7}END{print s}'`"
        if [[ -z $s_q_queued ]];then
        exit 0
        fi
	

	queue_procs_n=`count_queue_cores.sh $2|awk '{print $6}'`
	d_q_queued="`qstat -w -n -1 $2|grep -w Q |awk '{s+=$7}END{print s}'`"
	if [[ -z $d_q_queued ]];then d_q_queued=0;fi
	if [[ $d_q_queued -gt $queue_procs_n ]];then 
	exit 0
	fi
	
	d_q_run="`qstat -w -n -1 $2|grep -w R |awk '{s+=$7}END{print s}'`"
	
	#set t_avail as the job proc available amount in dest q	
	let "t_avail = queue_procs_n - d_q_run"
	if [[ $t_avail -le 0 ]];then
	exit 0
	fi
	
	
	
	
	dest_user_list="/tmp/d_u_l"
	src_user_list="/tmp/s_u_l"
	fairshare_list="/tmp/f_l"
	
	#create dest q user list
	qmgr -c "p q $d_q"|grep acl_users|awk '{print $6}'|paste -d " ">$dest_user_list
	#get only jobs with users in dest and source
	qstat $s_q|grep -w Q|awk '{print $3}'|grep -v '^-\|Name'|sort|uniq -c|grep -wf $dest_user_list|awk '{print $2}'>$src_user_list
	
	#loop over fairshare dest q members
	pbsfs |grep -v 'Usage: 0\|Fairshare\|TREEROOT\|unknown'|sed 's/ \+/#/g'|sed 's/#:#/:#/g'|cut -d"#" -f1,9|sed 's/#/ /g'|sort -k 2 -n|grep -wf $src_user_list|sed 's/: /:#/g'>$fairshare_list
	
	#calculate fair share members sum
	f_sum=`cat $fairshare_list|sed 's/#/ /g'|awk '{sum+=$2}END{print sum}'`
	
	#go over the fair share to user list
	for f_s in `cat $fairshare_list`: 
	do 
		user_name=`echo $f_s|sed 's/#/ /g'|sed 's/://g'|awk '{print $1}'`
		user_f=`echo $f_s|sed 's/#/ /g'|sed 's/://g'|awk '{print $2}'`
		
		user_f_relative=`echo "1-($user_f/$f_sum)"|bc -l`
		user_procs_to_send=`echo "$t_avail*$user_f_relative"|bc -l|sed 's/\..*//g'`
		
		#get users queued list 
		user_queued_list="/tmp/u_q_l"
		qstat -w -n -1 -u $user_name fair_test|grep -w Q>$user_queued_list
	
		 #test which of the user's jobs can enter the queue by fifo and ncpu size
		
			#go over the users's queued jobs and try to qmove them
			while read queue_job_line
			do
		                        if [[ $user_procs_to_send -lt 0 ]];then break ;fi 
	
					job_proc_req=`echo $queue_job_line|awk '{print $7}'`
		                        job_id=`echo $queue_job_line|awk '{print $1}'|sed 's/\..*//g'`
		
					if [[ $job_proc_req -gt $user_procs_to_send ]];then continue ;fi
					
				        let "user_procs_to_send=user_procs_to_send-job_proc_req"
					
	                                qmove $d_q $job_id
					
					user_job_proc_req=0
	
	       		done<$user_queued_list #user avail procs on queue loop
	
	done #fs loop
