#!/bin/bash

SPID=$(cat /tmp/server.pid)

[ $# -eq 0 ] && kill -s 36 $SPID
[[ $1 == "off" ]] && kill -s 35 $SPID

