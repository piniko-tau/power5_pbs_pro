import pbs
import sys

try:
# Get the hook event information and parameters
# This will be for the 'queuejob' event type.
	e = pbs.event()
# Get the information for the job being queued
	j = e.job
	if j.interactive:
# Get the “interQ” queue object
		q = pbs.server().queue("live_q")
# Reset the job's destination queue
# parameter for this event
		j.queue = q
# accept the event
		e.accept()
except SystemExit:
	pass
except:
	e.reject("Failed to route job to queue live_q")
