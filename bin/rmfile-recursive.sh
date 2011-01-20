#!/bin/bash

# rmfile-recursive.sh - usuwa puste pliki rekursywnie

# Użycie:
#	# tutaj (PWD)
#	rmfile-recursive
#	# z parametru
#	rmfile-recursive /jakis/folder
# by jedral.one.pl

# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# włącz **
shopt -s globstar
# włącz wykrywanie ukrytych plików
shopt -s dotglob
# folder bieżący lub z parametru (korzeń przeszukiwania)
# root dir
r="${1:-$PWD}"

# rekursywnie znajdź pliki
for p in "$r"/**/* ; do
	# -s - prawda jeśli plik istnieje i ma rozmiar większy niż 0
	# negacja nie bierze pod uwagę katalogów
	[[ ! -s $p ]] && rm -f "$p"
done
