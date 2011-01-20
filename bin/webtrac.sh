#!/bin/bash

# server trac

# server root
root=$HOME/studio/trac.dev.null
# log
log=~/.log/${0##*/}.log
# ------------------------------------------------------------------------------
. /etc/init.d/functions # ładne ok/error :P

get_pid(){
	ps -P `pgrep tracd` | grep $root
}
is_pid(){
	get_pid &>/dev/null
}
start(){
	echo -n $"Starting ${0##*/}: "
	mkdir -p ${log%/*}
	cd $root && (
		# nie wystarczy przekierować wyjście jednego polecenia
		# ponieważ przy ubijaniu powłoka informuje o zakończeniu procesu w tle
		# exec w subshell załatwia sprawę
		exec &> $log
		tracd -s --port  ${1:-8888} $root &
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
