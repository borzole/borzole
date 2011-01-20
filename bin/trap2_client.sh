#!/bin/bash

# trap_client.sh -- Client > Server "man 7 signal"

SPID=$(cat /tmp/server.pid)

[[ $1 == "off" ]] && kill -s SIGUSR2 $SPID || kill -s SIGUSR1 $SPID
