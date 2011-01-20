#!/bin/bash

# składa folder dokumentów PDF w jeden

usage(){
	echo -e " ${0##*/} -- składa folder dokumentów PDF w jeden

 Użycie:
	${0##*/} dir [ dir ... ]
	# dokument zostanie zapisany obok folderu: dir.pdf
	# ten dokument nie może wcześniej istnieć
	"
	exit 0
}

die(){
	echo -e "[ERROR] : $@ " >&2
	exit 1
}

[[ $# == 0 ]] && usage

while [ "$1" ] ; do
	dir="${1%/}"
	out="${dir/%.d/.pdf}"
	out="${out/%.pdf.pdf/.pdf}"

	[[ ! -d $dir ]] && die nie ma takiego katalogu: $dir
	echo source dir: $dir

	[[ -f $out   ]] && die już istnieje plik: $out
	echo output file: $out

	pdftk "$dir"/*.[pP][dD][fF] cat output "$out" verbose

	echo ------------
	echo result:
	du -h "$out"

	shift
done
