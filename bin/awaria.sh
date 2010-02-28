#!/bin/bash

TEST=FALSE

# liczymy uptime na minuty
UPTIME=$(cat /proc/uptime | cut -d\. -f1)
let UPTIME=$(($UPTIME/60+1))
 echo "$UPTIME min = $(uptime)"

# operacja na plikach starszych niż uptime
# if [ "$TEST" == "FALSE" ] ; then
	# usuń pliki
	#~ find /tmp -cmin +$UPTIME -exec rm -Rf '{}' 2>/dev/null \;
#	find /tmp -cmin +$UPTIME -exec rm -Rf '{}' 2>/dev/null \;
#else
	# wyświetl pliki
	#~ find /tmp -cmin +$UPTIME -exec ls -la '{}' 2>/dev/null \;
#	find /tmp -cmin +$UPTIME -exec ls -la '{}' \;
#fi
