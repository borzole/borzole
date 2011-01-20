#!/bin/bash

# alarm z pętlą

sleep ${1:-0}m
msg=${2:-'Jakiś komunikat'}

window(){
	zenity --question --text "$msg\n\n Powtórzyć alarm?" \
		--ok-label="Powtórz alarm za ..." \
		--cancel-label="Quit" \
	&& zenity --scale --title="${0##*/}" --width=300 \
		--text="Za ile minut powtórzyć alarm?" \
		--value=5 --min-value=1 --max-value=30 --step=1
}

x=$(window) || exit 0

"$0" $x "$msg"
