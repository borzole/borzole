#!/bin/bash

# -------------------------------------------------------------------
# debugger.sh -- ustawienia debugowania 
# UŻYCIE:
#	-- na początku skryptu wybrać poziom DEBUG i zrobić "source" skryptu
# 	np.:
# 		DEBUG=3
# 		. debugger.sh || DEBUGGER=:
# 	-- wewnątrz funkcji można uzyskać info o jej nazwie jeśli zawiera kod:
# 		$DEBUGGER >&2
# -------------------------------------------------------------------
[ -z "$DEBUG" ] && DEBUG=3
[ -z "$LOGFILE" ] && LOGFILE="$HOME/script_${0##*/}_$(date +%Y.%m.%d-%H.%M.%S).log"
# -------------------------------------------------------------------
debug()
{
	case "$DEBUG" in
		0)
			# formatuj błąd 
			xargs -i echo -e "[ $@ ] {}"
			;;
		1)
			# loguj i wyświetlaj
			tee -ai "$LOGFILE"
			;;
		2)
			# loguj i niewyświetlaj
			tee -ai "$LOGFILE" > /dev/null
			;;
		3)
			# 0+1
			xargs -i echo -e "[ $@ ] {}" | tee -ai "$LOGFILE"
			;;
		4)
			# 0+2
			xargs -i echo -e "[ $@ ] {}" | tee -ai "$LOGFILE"  > /dev/null
			;;
		*)
			cat > /dev/null
			;;
	esac
}
# -------------------------------------------------------------------
# wszystkie błędy sio
ERROR_OUT='exec 2> >( [ -z $FUNCNAME ] && debug ${0##*/} || debug $FUNCNAME )'
DEBUGGER="eval $(echo $ERROR_OUT)"
# po wywołaniu, błąd ląduje na "stdout" i trzeba go znowu zagonić do "stderr"
$DEBUGGER >&2
