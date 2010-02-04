#!/bin/bash

# find-in-path - ...samo opis
# by borzole.one.pl

usage(){
	echo -e "${0##*/} -- wyszukaj polecenia w ścieżce
INFO
	Wyszukuje w ścieżce systemowej \$PATH polecenia według wzoru z parametru
	Przyjmuje argumenty polecenia 'grep'
	by borzole.one.pl
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
# załaduj do tablicy wszystkie ścieżki
BIN=( `echo $PATH | sed -e 's/:/\ /g'` )
# dla każdej ścieżki
for bin in ${BIN[@]} ; do 
	# wylistuj polecenia i wyłap tylko te pasujące do wzorca
	ls -1 $bin | grep $@
# sortuj wyniki z całej pętli for
done | sort -u
