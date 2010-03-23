#!/bin/bash

lock_file=$HOME/trwa_instalacja

sprawdz(){
	# może lepiej by było, aby lock_file pochodził z $1 wówczas funkcja byla by bardziej uniwersalna
	clear
	if [[ -f $lock_file ]] ; then
		printf " \r instaluje wirusa" && sleep 1
		for i in {1..5} ; do
			[ ! -f $lock_file ] && break_loop
			printf " * " && sleep 1
		done
		sprawdz
	else
		break_loop
	fi
}

break_loop(){
	clear
	printf "\n [ $(date) ] \$ Skynet zyskuje świadomość \n"
	exit 0
}

set_lock(){
	printf " tworzę plik blokujący: $lock_file"
	touch $lock_file
}

rm_lock(){
	printf " usuwam plik blokujący: $lock_file"
	rm -f $lock_file
}

set_lock
# sprawdzanie w tle
sprawdz &
# demo jakiegoś procesu trwającego 20s 
sleep 12
rm_lock

