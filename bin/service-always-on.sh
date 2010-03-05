#!/bin/bash

SERVICE=${1:-httpd}

service $SERVICE status | grep "uruchomiony..." >/dev/null
#~ ps aux | grep -v "grep $SERVICE" | grep $SERVICE >/dev/null
RC=$?

if [ $RC -ne 0 ] ; then
	echo "$SERVICE nie działa, uruchamiam"
	service $SERVICE start
fi
