import pbs
import sys

#qmgr -c 'create hook check_and_route_power_0qa1 event="queuejob"'
#qmgr -c 'import hook check_and_route_power_0qa1 application/x-python default /var/spool/PBS/hooks/check_and_route_power_0qa1.py' 
#qmgr -c 'd h check_and_route_power_0qa1'

try:
	
	e = pbs.event()	
	
	if e.job.queue:
	
		if (e.job.queue.name in ["adis_in","power_0qa1"]):
		
			if (e.job.Variable_List["in_queue_credential"] != "1"):
				
		        	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to the queue!")
			
			power_0qa1_nodes_list = ['compute-0-166.power5','compute-0-167.power5']
			
			for qnode in power_0qa1_nodes_list:
			
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
	
			adisq = pbs.server().queue("adis")
			e.job.queue = adisq	

except SystemExit:
	pass
except :
	e.reject("Error, Make sure you use --> qsub_in <-- command to submit to the queue!")
