#!/bin/bash

# Załóżmy, że chcemy ściągnąć wykłady zapisane w plikach PDF i PPT
# rozmieszczone w odpowiednich katalogach (np. z podziałem na lata).

[ $# -eq 0 ] && { echo -e "${0##*/} http://example.com/page/subpage.html txt,png,itd" ; exit 1 ; }

HOST="$1"
EXT="$2"

wget -r -H -l 2 -A doc,pdf,ppt,gz,zip,${EXT} -np "$HOST"

# gdzie:
# 	-r oznacza oczywiście ściąganie rekurencyjne,
# 	-H zabranie przechodzenia między hostami w trakcie podążania przez wget między odnośnikami,
# 	-l 2 określa 2 poziom podążania przez wget między odnośnikami,
# 	-A pdf,ppt określa tylko jakie pliki chcemy ściągnąć,
# 	-np zabrania przechodzenia do wyższych poziomów hierarchii plików niż ta startowa
