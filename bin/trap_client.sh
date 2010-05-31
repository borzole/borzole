#!/bin/bash

# trap_client.sh -- Client > Server "man 7 signal"

SPID=$(cat /tmp/server.pid)

# uruchomienie bez parametrów
[ $# -eq 0 ] && kill -s 36 $SPID
# uruchomienie z parametrem "off"
[[ $1 == "off" ]] && kill -s 35 $SPID

