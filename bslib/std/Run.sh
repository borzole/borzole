#!/bin/bash

Run(){
	# (robot) ładny bezpiecznik do skryptów składających się z samych funkcji
	if [ -n "$1" ] ; then 
		if [ "$1" == "$" ] ; then 
			# uruchom dowolną funkcję ze skryptu pomijając menu
			# np:	skrypt.sh $ funkcja2 
			shift
			"$@"
		else 
			# uruchom 
			Menu "$@"
		fi
	else
		# przy braku parametrów
		Main
	fi
}
