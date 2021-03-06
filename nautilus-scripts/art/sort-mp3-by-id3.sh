#!/bin/bash

# sortuje mp3 na podstawie tagów do drzewa folderów
# source: http://borzole.googlecode.com/hg/nautilus-scripts/art/sort-mp3-by-id3.sh
#  autor: http://jedral.one.pl
#
# Użycie:
#    - jako nautilus-scripts, wówczas wystarczy kliknąć w folderze (nie na plikach)
#    - z konsoli, podając folder jako argument

# przekieruj wyjście do logu, jeśli nie uruchomiono z terminala
if ! tty -s ; then
	exec &> ~/${0##*/}.log
fi

# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# enable **
shopt -s globstar
# enable ** for dotfiles
shopt -s dotglob

# ------------------------------------------------------------------------------
# sortuj według tagów ID3

# sprawdźmy zależności
id3info -V || exit 1

r=$( echo ${1:-${NAUTILUS_SCRIPT_CURRENT_URI#file://}} | sed 's:%20: :g')

get_tag(){
	echo -e "$raw" | awk -F": " '$1 ~ /'"$@"'/ {print $2}'
}

set_path(){
	while [[ $@ ]] ; do
		[ ${#1} != 0 ] && echo -n ${1}/
		shift
	done
}

echo root: $r | sed 's:%20: :g'
for f in "$r"/** ; do
	echo file: $f
	raw=$(id3info -n "$f" | grep === )
	path=$(set_path "$(get_tag Soloist)" "$(get_tag Year)" "$(get_tag Album)")
	[ ${#path} != 0 ] && mkdir -p "$r/$path" && {
		core="$r/$path/${f##*/}"
		# zabezpieczenie przed duplikatem nazwy
		while [ -f "$core"$n ] ; do ((n++)) ; done
		new="$core"$n && n=''
		mv "$f" "$new"
	}
done

# ------------------------------------------------------------------------------
# posprzątaj po sobie i usuń puste katalogi

# rekursywnie znajdź katalogi i załaduj do tablicy
unset LIST
for p in "$r"/** ; do
	[[ -d $p ]] && LIST[${#LIST[*]}]="$p"
done

# wykonaj w odwrotnej kolejności tablicę, czyli od najgłębiej zagnieżdzonych
for (( i=(${#LIST[@]}-1) ; i >= 0  ; i-- )) ; do
	# magia tego polecenia polega na tym, że usuwa tylko puste katalogi ;)
	rmdir --ignore-fail-on-non-empty "${LIST[$i]}"
done
