#!/bin/bash

# przykład ubijania forka z tła

echo PPID: $PPID
echo PID: $$

zenity --info --text "Jestem $$, czy $!
nie klikaj, zaraz mnie zabije: $PPID" \
	1> ~/myscript.out.log 2> ~/myscript.err.log &
TLO=$!
sleep 2
echo TLO: $TLO
kill -TERM $TLO
# lub
# kill -s SIGTERM $TLO
