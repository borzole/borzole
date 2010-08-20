#!/bin/bash

# zabawka utrzymuje tyle instancji aplikacji ile masz rdzeni
# jak tylko zamkniesz jedną to uruchomi się następna
# dobre jak chcesz obciążyć wszystkie rdzenia, ale nie przedobrzyć

run=xterm
trap exit EXIT

if [ `pgrep $run | wc -l` -lt `grep processor /proc/cpuinfo | wc -l` ]
then
	$run &
else
	sleep 1
fi
$0
