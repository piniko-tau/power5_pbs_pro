import pbs
import sys

#qmgr -c 'create hook check_and_route_adis_0q event="queuejob"';qmgr -c 's h check_and_route_adis_0q debug=True'
#qmgr -c 'import hook check_and_route_adis_0q application/x-python default /var/spool/PBS/hooks/check_and_route_adis_0q.py' 
#qmgr -c 'd h check_and_route_adis_0q'
try:
	
	e = pbs.event()
	
	if e.job.queue:
		
		target_qname = e.job.queue.name
		
		if (target_qname in ["adis_0q"]):
		
			adisq = pbs.server().queue("adis")
			adis_used_ncpus = adisq.resources_assigned["ncpus"]
			
			if (adis_used_ncpus >= 2):
				e.job.queue = adisq
			
	
	# accept the event
				e.accept()
except:
#	e.reject("Failed to route job to queue adis_0q")
	e.accept("Failed to route job to queue adis_0q")
