#!/bin/bash

# komunikaty
LOG=$HOME/${0##/}.$(date +'%y-%m-%d').log

_info(){
	cat $LOG | zenity --text-info --width 530	
}

_ok(){
	zenity --info --text="OK Operacja zakończona pomyślnie"
}
_er(){
	zenity --question --text="ERROR ...hymm pewnie coś poszło nie tak, \nChcesz zobaczyć log ?" 
	[ $? == 0 ] && _info || exit $?
	
}

# silnik skryptu
_main(){
	killall firefox 2>>$LOG
	find $HOME/.mozilla/ -iname \*.sqlite -exec sqlite3  '{}' "vacuum" \; 2>>$LOG \
		| zenity --progress --pulsate --auto-close --auto-kill
	
	[ $? == 0 ] && _ok || _er
	
	firefox
}

# START
zenity --question --text="Optymalizujemy sqlite firefoxa ?" 
[ $? == 0 ] && _main || _er
