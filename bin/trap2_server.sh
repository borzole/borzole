#!/bin/bash

# trap_server.sh -- Client > Server

cmd(){
	echo -n " puk puk "
}

main(){
	# typowe zajęcie demona
	echo -n .
}

demon(){
	while : ; do
		main
		sleep 0.1
	done
}

echo $$ > /tmp/server.pid
# przypisanie poleceń do przerwań

trap 'cmd' SIGUSR1
trap 'exit 0' SIGUSR2

# "man 7 signal"
# SIGUSR1   30,10,16   Term    Sygnał 1 użytkownika
# SIGUSR2   31,12,17   Term    Sygnał 2 użytkownika

demon
