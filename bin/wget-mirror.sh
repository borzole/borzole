#!/bin/bash

# prosty mirror strony

usage(){
	echo -e "${0##*/} -- prosty mirror strony
UŻYCIE:
	${0##*/} <www.przykład.pl>
	# pobranie jednego poziomu
	${0##*/} -l 1 <www.przykład.pl>
"
	exit 1
}

[ $# -eq 0 ] && usage

wget -mk -w 2 -p $@

# -m = mirror
# -k = konwertuj linki na lokalne odwołania
# -w 2 = czekaj 2s między pobraniami (zmniejszaj obciążenie serwera)
# -p = get all required elements for the page to load correctly
# -l = Maximum recursion depth (inf or 0 for infinite).
