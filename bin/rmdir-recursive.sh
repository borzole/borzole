#!/bin/bash 

# rmdir-recursive.sh - usuwa puste katalogi rekursywnie
# Użycie:
#	# tutaj (PWD)
#	rmdir-recursive
#	# z parametru
#	rmdir-recursive /jakis/folder
# by borzole.one.pl

# minimum Bash 4 
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# włącz **
shopt -s globstar
# włącz wykrywanie ukrytych plików
shopt -s dotglob
# folder bieżący lub z parametru (korzeń przeszukiwania)
r="${PWD:-$1}"

# rekursywnie znajdź katalogi i załaduj do tablicy
unset LIST
for p in "$r"/**/* ; do
	[[ -d $p ]] && LIST[${#LIST[*]}]="$p"
done

# wykonaj w odwrotnej kolejności tablicę, czyli od najgłębiej zagnieżdzonych
for (( i=(${#LIST[@]}-1) ; i >= 0  ; i-- )) ; do
	# magia tego polecenia polega na tym, że usuwa tylko puste katalogi ;)
	rmdir --ignore-fail-on-non-empty "${LIST[$i]}"
done

