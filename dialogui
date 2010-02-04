#!/bin/bash

# by borzole.one.pl

# if [ $(whoami) != "root" ] ; then
	# zenity --error --text="Musisz być zalogowany jako root, aby uruchomić ten skrypt"
	# exit 1
# fi

# plugins
p=/usr/local/bin

_menu()
{
	zenity --title="Skrypt konfiguracyjny Fedory" \
		--text "Zaznacz operacje do wykonania:" \
		--width=400 --height=800 \
		--list  --checklist \
		--column="zaznacz" --column "polecenie" \
		$(for i in $p/*; do echo " FALSE ${i##*/} "; done) \
		--separator " "  --multiple \
		--print-column=2
}	
#echo $(_menu) 2>&1 | zenity --text-info --title="Debuger" --width=700 --height=500
for s in $(_menu) ; do ${p}/$s ;done

