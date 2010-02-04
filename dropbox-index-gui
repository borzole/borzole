#!/bin/bash

# by borzole.one.pl

_start(){
	dropbox start -i
}
_stop(){
	dropbox stop
}
_restart(){
	_stop
	sleep 1
	_start
}

_index_a(){
	(
		echo "# Updating Dropbox index"
		dropbox-index all	
	)| zenity --progress --pulsate 	--auto-close --auto-kill --title="Update Dropbox-Index"
	[ "$?" != 0 ] && zenity --error --text="Update canceled."
	
	return 0
}

_index_c(){
	(
		echo "# Deleting Dropbox index"
		dropbox-index clean
	)| zenity --progress --pulsate 	--auto-close --auto-kill --title="Deleting Dropbox-Index"
	[ "$?" != 0 ] && zenity --error --text="Deleting canceled."
	
	return 0
}

_menu(){
	# funkcja zwraca drugą kolumnę 
	# UWAGA na spacje/tabulatory po "\"
	zenity --title="Dropbox"  --text "On / Off <b>Dropbox</b>" \
		--list  --radiolist --width=300 --height=220 \
		--column="radiolist" --column "wybierz" --column "polecenie do wykonania" \
			FALSE		"Dropbox ON" 											"_start"\
			TRUE		"Dropbox OFF" 										"_stop"\
			FALSE		"Dropbox RESTART" 									"_restart"\
 			FALSE		"Zindeksuj zawartość Dropbox/Public" 		"_index_a"\
			FALSE		"Usuń indeksy z Dropbox/Public" 				"_index_c"\
		--print-column=3 --hide-column=3
}
#echo 
$(_menu)

[ "$?" == 0 ] && "${0}"

# 2>&1 | zenity --text-info --title="Debuger" --width=700 --height=500
