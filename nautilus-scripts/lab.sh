#!/bin/bash

# przekieruj wyjście do logu, jeśli nie uruchomiono z terminala
if ! tty -s ; then
	exec &> ~/log
fi

# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# enable **
shopt -s globstar
# enable ** for dotfiles
shopt -s dotglob

# sprawdźmy zależności
id3info -V || exit 1

r=${1:-${NAUTILUS_SCRIPT_CURRENT_URI#file://}}

get_tag(){
	echo -e "$raw" | awk -F": " '$1 ~ /'"$@"'/ {print $2}'
}

set_path(){
	while [[ $@ ]] ; do
		[ ${#1} != 0 ] && echo -n ${1}/
		shift
	done
}

for f in "$r"/** ; do
	raw=$(id3info -n "$f" | grep === )
	path=$(set_path $(get_tag Soloist) $(get_tag Year) $(get_tag Album))
	[ ${#path} != 0 ] && mkdir -p "$r/$path" && mv "$f" "$r/$path"/"${f##*/}"
done
