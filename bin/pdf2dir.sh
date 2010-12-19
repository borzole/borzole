#!/bin/bash

# rozwala dokument PDF na pojedyncze strony

usage(){
	echo -e " ${0##*/} -- rozwala dokument PDF na pojedyncze strony

 Użycie:
	${0##*/} file.pdf [ file1.pdf ... ]
	# strony zostaną zapisane do folderu: file.pdf.d
	# ten folder nie może wcześniej istnieć
	"
	exit 0
}

die(){
	echo -e "[ERROR] : $@ " >&2
	exit 1
}

[[ $# == 0 ]] && usage

while [ "$1" ] ; do
	src="$1"
	dir="${src}.d"

	[[ ! -f $src ]] && die nie ma takiego pliku: $src
	echo source file: $src
	file -b "$src" | grep 'PDF document' || die plik $src to nie PDF!

	[[ -d $dir   ]] && die folder $dir już istnieje
	echo output dir: $dir
	mkdir -p "$dir"

	pdftk "$src" burst output "${dir}"/strona%03d.pdf

	echo ------------
	echo result:
	tree "$dir"

	shift
done
