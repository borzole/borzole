#!/bin/bash

# find-in-path - ...samo opis
# by borzole.one.pl

usage(){
	echo -e "${0##*/} -- wyszukaj polecenia w ścieżce
INFO
	Wyszukuje w ścieżce systemowej \$PATH polecenia według wzoru z parametru
	Przyjmuje argumenty polecenia 'grep'
	by borzole (jedral.one.pl)
PRZYKŁAD:"
	# przykładowe polecenie
	CMD="$0 '^p.$'"
	# parametr CMD jest wyświetlany
	echo -e "\t${CMD##*/}"
	# parametr CMD jest wykonywany
	eval $CMD
	exit 0
}
# przy braku parametrów, wyświetl pomoc
[ $# == 0 ] && usage
# zmień znak rozdzielający pola
IFS=':'
# wylistuj polecenia i wyłap tylko te pasujące do wzorca
ls -1 $PATH | grep --color=always $@ | sort -u
