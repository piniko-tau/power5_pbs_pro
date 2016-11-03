import pbs
import sys

#qmgr -c 'create hook check_fair_share_q event="queuejob"';qmgr -c 's h check_fair_share_q debug=True'
#qmgr -c 'import hook check_fair_share_q application/x-python default /var/spool/PBS/hooks/check_fair_share_q.py' 
#qmgr -c 'd h check_fair_share_q'
try:
	
	e = pbs.event()
	
	if e.job.queue:
		
		target_qname = e.job.queue.name
		
		if (target_qname in ["fair_test"]):
		
			pbs.server().job()			
		        e.accept()
	
#			adisq = pbs.server().queue("adis")
#			adis_used_ncpus = adisq.resources_assigned["ncpus"]
			
#			if (adis_used_ncpus >= 2):
#				e.job.queue = adisq
			
	
	# accept the event
except:
#	e.reject("Failed to route job to queue adis_0q")
	e.accept()
