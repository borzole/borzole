#!/bin/bash

file_log(){
	local thisDIR
	local thisFILE

	# spr. czy podano parametr: nazwę logu do utworzenia
	if [ $# == 0 ] ; then
		# tworzymy domyślny log w domyślnym katalogu
		thisDIR=~/.log
		thisFILE=script_${0##*/}_$(marker).log
	else
		thisDIR="${1%/*}"
		thisFILE="${1##*/}"
	fi

	# spr. czy podano ścieżkę do istniejącego katalogu
	if [ ! -d "$thisDIR" ] ; then
		# skoro katalogu nie ma, to go utworzymy
#@TODO powinna być możliwość decyzji: przerwij/oczekuj potwierdzenia/ yes na wszystko
		mkdir -p "$thisDIR" ; RC=$?
		if [ $RC != 0 ] ; then
			echo -e "Nie udało się utworzyć katalogu: $thisDIR" >&2
			verbose "Zamieniam '$thisDIR' na /tmp"
			thisDIR=/tmp
		fi
	fi

	# ostatecznie mamy log
	FILE_LOG="$thisDIR"/"$thisFILE"
	verbose "Ustawiono FILE_LOG: $FILE_LOG"
}