#!/bin/bash

r="${NAUTILUS_SCRIPT_CURRENT_URI#file://}"
r="$1"
# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# enable **
shopt -s globstar
# enable ** for dotfiles
shopt -s dotglob

for p in "$r"/** ; do
	if [[ -d $p ]] ; then
		gvfs-set-attribute "$p" metadata::nautilus-icon-view-auto-layout true
		gvfs-set-attribute "$p" metadata::nautilus-icon-view-tighter-layout false
		gvfs-set-attribute "$p" metadata::nautilus-icon-view-zoom-level 3
		gvfs-set-attribute "$p" metadata::nautilus-default-view OAFIID:Nautilus_File_Manager_Icon_View
		gvfs-set-attribute "$p" -t stringv metadata::annotation
		#@TODO działa jak się wejdzie poraz drugi do katalogu, ustawiany jest jeszcze jakiś parametr ?!
	fi
done
