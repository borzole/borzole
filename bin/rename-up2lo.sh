#!/bin/bash

# zmienia nazwy plików i folderów na małe litery, rekursywnie w całym drzewie
# UWAGA! może nadpisywać pliki!

# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# enable **
shopt -s globstar
# enable ** for dotfiles
shopt -s dotglob

# root dir
r="${1:-$PWD}"

chmod +rw -R "$r"/*

up2lo(){
	obj="$1"
	echo -n "."
	mv "$obj" "${obj%/*}/$(echo ${obj##*/} | tr '[:upper:]' '[:lower:]')" 2>/dev/null
}
unset LIST
for p in "$r"/** ; do
	# pliki można zmienić od razu
	[[ -f $p ]] && up2lo "$p"
	# kolejność folderów należy najpierw odwrócić
	[[ -d $p ]] && LIST[${#LIST[*]}]="$p"
done

# wykonaj w odwrotnej kolejności tablicę, czyli od najgłębiej zagnieżdzonych
for (( i=(${#LIST[@]}-1) ; i >= 0  ; i-- )) ; do
	up2lo "${LIST[$i]}"
done
echo
