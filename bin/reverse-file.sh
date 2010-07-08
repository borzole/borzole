#!/bin/bash

if [ $# -eq 0 ] ; then
	echo -e " reverse-file - odwraca kolejność linii w pliku

Podaj plik tekstowy jako parametr
Użycie:
	reverse-file dane.log
	reverse-file dane.log > rezultat.log
	reverse-file dane.log | tee -ai rezultat.log
Ciekawostka:
	reverse-file dane.log | rev

by jedral.one.pl
"
	exit 0
fi

INPUT="$1"
for (( i=1 ; i <= $(wc -l < "$INPUT") ; i++ )) ; do
	tail -n $i "$INPUT" | head -n 1 
done
