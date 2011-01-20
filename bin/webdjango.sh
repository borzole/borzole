#!/bin/bash

# server Django

# server root
root=$HOME/studio/python/django.dev.null/mysite
# log
log=~/.log/${0##*/}.log
# ------------------------------------------------------------------------------
. /etc/init.d/functions # ładne ok/error :P

get_pid(){
	ps -P `pgrep python` | grep '/usr/bin/python manage.py runserver' | awk '{print $1}'
}
is_pid(){
	ps -P `pgrep python` | grep '/usr/bin/python manage.py runserver' &>/dev/null
}

start(){
	echo -n $"Starting ${0##*/}: "
	mkdir -p ${log%/*}
	cd $root && (
		# nie wystarczy przekierować wyjście jednego polecenia
		# ponieważ przy ubijaniu powłoka informuje o zakończeniu procesu w tle
		# exec w subshell załatwia sprawę
		exec &> $log
		python manage.py runserver ${1:-9999} &
	)
	sleep 1
	is_pid && success || failure
	echo
}

stop(){
	echo -n $"Stopping ${0##*/}: "
	is_pid && {
		kill -n 9 $(get_pid) &>/dev/null && success
	} || failure
	echo
}

if is_pid
then
	stop
else
	start $@
fi
