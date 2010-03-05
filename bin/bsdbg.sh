#!/bin/bash

# debugger.sh -- ustawienia debugowania 
# UŻYCIE:
#	na początku skryptu wybrać poziom DEBUG i zrobić "source" skryptu
# 	np.:
# 		DEBUG=0
# 		. debugger.sh
# --------------------------------------------------------------------
[[ -z "$DEBUG" ]] && DEBUG=3
[[ -z "$LOGFILE" ]] && LOGFILE="$HOME/script_${0##*/}_$(date +%Y.%m.%d).log"
# --------------------------------------------------------------------
debug_format(){
	while read line; do
		echo "[ $(date +%Y.%m.%d-%H:%M:%S) ][ ${0##*/} ] $line"
	done 
}
# --------------------------------------------------------------------
debug(){
	case "$DEBUG" in
		0)
			# formatuj błąd 
			debug_format
			;;
		1)
			# loguj i wyświetlaj
			tee -ai "$LOGFILE"
			;;
		2)
			# loguj i niewyświetlaj
			cat >> "$LOGFILE"
			;;
		3)
			# 0+1
			debug_format | tee -ai "$LOGFILE"
			;;
		4)
			# 0+2
			debug_format | cat >> "$LOGFILE"
			;;
		*)
			# błędy sio ( lepiej w ogóle nie włączać debugera ;) )
			cat > /dev/null
			;;
	esac
}
# --------------------------------------------------------------------
exec 2> >( debug )
