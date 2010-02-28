#!/bin/bash

DIR=$HOME/.mozilla/firefox/profil.lucas/

RAM=/dev/shm/firefox-ram
[ ! -d "$RAM" ] && mkdir -p "$RAM"

synchronizacja(){
	exec 4> >(zenity --progress --pulsate --width=300 --auto-close --auto-kill --title=${0##*/})
	echo "# Synchronizuje profil: $3 ..." >&4
	rsync -a $1/ $2
	echo "100" >&4
	exec 4>&-
}

synchronizacja $DIR $RAM 'HD >> RAM'
trap "synchronizacja $RAM $DIR 'RAM >> HD'" EXIT

firefox -P ram $@
