#!/bin/bash

# przykładowy client-serwer przy użyciu potoków nazwanych
# http://www.linuxjournal.com/content/using-named-pipes-fifos-bash


pipe=/tmp/testpipe

if [[ ! -p $pipe ]] ; then
    mkfifo $pipe
    trap "rm -f $pipe" EXIT
fi

while : ; do
    if read line <$pipe; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi
        eval echo $line
    fi
    #~ sleep 1.2 # w cron bez tego może wyskoczyć błąd "interraption"
done

echo "Reader exiting"
