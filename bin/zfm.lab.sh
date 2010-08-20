#!/bin/bash

# Zenity File Manager :P

VERSION=2010.05.31-22:41
[[ -z $DIR ]] && export DIR=$HOME

list(){
	for i in "$DIR"/* ; do
		[[ -d $i ]] && echo -n "$i|+|${i##*/}|"
		[[ -f $i ]] && echo -n "$i|-|${i##*/}|"
	done
}

menu(){
	local IFS="|"
	zenity --title="Zenity File Manager" \
		--text "Zaznacz plik/folder, które chcesz obejrzeć" \
		--width=600 --height=600 \
		--list \
		--column "path" --column "o" --column "script" \
		$(list) \
		--separator "\n" \
		--print-column=1 --hide-column=1
}

TMP="$(menu)"

[[ -d $TMP ]] && { DIR="$TMP"; $0 ; }
[[ -f $TMP ]] && xdg-open "$TMP"

