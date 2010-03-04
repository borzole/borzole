#!/bin/bash

requires(){
	# sprawdza zależności skryptu
	local thisSTATUS=OK
	# czcionka: (N)ORMAL, (R)ED
	local N="\e[0m" 
	local R="\e[1;31m"

	for APPS in "$@" ; do
		type ${APPS} >/dev/null 2>&1
		if [ $? != 0 ] ; then
			echo -e "${R}[ ERROR ]${N} Nie znaleziono programu '${R}$APPS${N}'" >&2
			thisSTATUS=ERROR
		fi
	done
	
	# podsumowanie testu
	if [ $thisSTATUS == 'ERROR' ] ; then
		echo -e "a) zainstaluj program:
			\r\tsu -c'yum install aplikacja'
			\rb) lub odszukaj paczkę dostarczającą wymaganą zależność:
			\r\tsu -c'yum provides aplikacja'
			\r\tsu -c'yum provides \\*bin/aplikacja'" >&2
		exit 1;
	fi
}
