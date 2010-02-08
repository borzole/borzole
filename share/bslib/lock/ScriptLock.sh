#!/bin/bash

ScriptLock(){
	# gdy chcemy mieć uruchomioną tylko jedną jego kopie
	export SCRIPT_LOCK="/tmp/script_lock_${0##*/}.pid"
	if [ -f "$SCRIPT_LOCK" ] ; then
		# jeśli spróbujemy uruchomić drugą kopię skryptu:
		Verbose "${R}[ wychodzę ]${N} plik blokujący skryptu istnieje: $SCRIPT_LOCK"
		exit 0 
	else
		Verbose "${B}[ uruchamiam ]${N} tworzę plik blokujący skryptu: $SCRIPT_LOCK"
		# zawartość pliku blokującego jest mało istotna, ważne by istniał
		echo $$ > "$SCRIPT_LOCK"
	fi
}
