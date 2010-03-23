#!/bin/bash

# źródło: http://www.linuxjournal.com/content/creating-bash-spinner
logfile=$HOME/my.log

echo >$logfile
trap "rm -f $logfile" EXIT

log_msg(){
	# Output message to log file.
    echo "$*" >>$logfile
}

# Start spinner
spinner.sh &

# Perform really long task.
i=0
log_msg "Starting a really long job"
while [[ $i -lt 100 ]] ; do
    sleep 1
    let i+=5
    log_msg "$i% complete"
done

sleep 1
echo
