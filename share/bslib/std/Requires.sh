#!/bin/bash

Requires(){
	# sprawdza zależności skryptu 
	# np.
	# 		wymaga wget zenity notify-send
	for thisAPPS in "$@" ; do
		which ${thisAPPS} >/dev/null 2>&1
		if [ $? != 0 ] ; then
			Error "Nie znaleziono programu '$thisAPPS'"
			Verbose "\tSpróbuj zainstalować:
		su -c'yum install $thishAPPS'
	jeśli zawiedzie, to spróbuj odnaleźć paczkę dostarczającą wymaganą zależność:
		su -c'yum provides \\*bin/$thishAPPS'"
			exit 1;
		fi
	done
}
