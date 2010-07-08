#!/bin/bash

# zmienia kodowanie z windowsa na utf-8

# by jedral.one.pl
# wersja alfa, na 1 poziom
_dir1run(){
	for p in $(ls-arg d) ; do
		cd $p
		for q in $(ls-arg f) ; do
			win2utf $q
		done
		cd ..
	done
}

# kopia drzewa katalogów pełnego kodu z helion.pl


debug=
#"echo -e"


# kodowanie
from=cp1250
to=utf-8

outdir="_$to"

# robi kopię struktury katalogów
find . -xtype d -printf "$outdir/%P\n" | xargs -i $debug mkdir -p '{}'

# konwersja plików
find . -xtype f -exec $debug iconv -f $from -t $to -o ./"$outdir"/'{}' '{}' 2>/dev/null \;
