#!/bin/bash

# reinstall all rpms

#~ rpm -qa --last | sort

#~ rpm -qa mc\* --qf '%{installtime} (%{installtime:date}) %{name}\n' | sort -nu

# tylko root może uruchomić ten skrypt
[ $(id -u) != 0 ] && { echo Uruchom jako root ; exit 1 ; }

# ustawiamy marker czasu
START=/var/log/${0##*/}.date.log
[ ! -f $START ] && date +%s > $START
NOW=$(cat $START)

last(){
	# zwraca 10 najstarszych paczek
	rpm -qa --last | grep -v gpg-pubkey | tail -n 10 | awk '{print $1}'
}

main(){
	N=$(last)

	# ustala czas instalacji najstarszej paczki
	LAST=$(echo -e "$N" | tail -n 1)
	INSTALLTIME=$(rpm -q $LAST --qf '%{installtime}')

	if [ $NOW -lt $INSTALLTIME ] ; then
		echo "Nie ma już nic starego, bye bye"
		exit 0
	else
		echo "Reinstalacja ..."
		yum reinstall $N
		$FUNCNAME
	fi
}

main
