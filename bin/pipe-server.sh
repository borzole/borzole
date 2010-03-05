#!/bin/bash

# http://www.linuxjournal.com/content/using-named-pipes-fifos-bash
VERBOSE=1
. bslib.sh || exit 1

script_lock

TrapEXIT(){
	rm -f $pipe
	script_unlock
}

pipe=/tmp/testpipe

trap "TrapEXIT" EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
fi

while true
do
    if read line <$pipe; then
        if [[ "$line" == 'quit' ]]; then
            break
        fi
        eval $line
    fi
    #~ sleep 1.2
done

echo "Reader exiting"
