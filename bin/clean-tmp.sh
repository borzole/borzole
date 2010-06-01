#!/bin/bash

# czyści /tmp z plików starszych niż 'uptime'

# liczymy uptime na minuty
UPTIME=$(cat /proc/uptime | cut -d\. -f1)
let UPTIME=$(($UPTIME/60+1))
# usuń pliki starsze niż uptime
find /tmp -cmin +$UPTIME -exec rm -rf '{}' 2>/dev/null \;
