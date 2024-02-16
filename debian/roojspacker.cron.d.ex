#
# Regular cron jobs for the roojspacker package.
#
0 4	* * *	root	[ -x /usr/bin/roojspacker_maintenance ] && /usr/bin/roojspacker_maintenance
