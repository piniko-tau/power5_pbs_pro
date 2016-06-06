import pbs
import sys

e = pbs.event()

# Ignore requests from scheduler or server
#if e.requestor in ["PBS_Server", "Scheduler"]:
#	e.accept()
if e.job.queue:
	
	target_qname = e.job.queue.name
	
	if (target_qname in ["adisR","adisE"]):
	
		e.job.project = "adis_guest_job_project"
	else:	
		e.job.project = "general_guest_job_project"

else:

                e.job.project = "general_guest_job_project"

	
#	e.reject("Failed to set job to project guest_job_project , queue :" + j.queue.name)

