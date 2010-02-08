#!/bin/bash
#
# by borzole ( jedral.one.pl )
VERSION=2010.01.13-20.35
# ------------------------------------------------------------------------------
# budzik ;)
# można uruchomić podając komentarz jako parametr
# np.
# 		budzik Pora na przekąskę!
#
# Działa podobnie jak skrypt "task:" z tą różnicą, że może być uruchomiona tylko 1 instancja 
# ------------------------------------------------------------------------------
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
lock_script(){
	# gdy chcemy mieć uruchomioną tylko jedną jego kopie
	LOCK_SCRIPT="/tmp/lock_script_${0##*/}.pid"
	if [ -f $LOCK_SCRIPT ] ; then
		# jeśli spróbujemy uruchomić drugą kopię skryptu:
		echo -e "${R}[ wychodzę ]${N} plik blokujący skryptu istnieje: $LOCK_SCRIPT"
		exit 0 
	else
		echo -e "${B}[ uruchamiam ]${N} tworzę plik blokujący skryptu: $LOCK_SCRIPT"
		# zawartość pliku blokującego jest mało istotna, ważne by istniał
		echo $$ > $LOCK_SCRIPT
	fi
}
# ------------------------------------------------------------------------------
unlock_script(){
	# mimo, że jest to jedno polecenie to zróbmy funkcję
	# nieszczęściem by było usunąć niewłaściwy plik
	# a tak minimalizujemy prawdomodobieństwo błędu
	rm -f $LOCK_SCRIPT
	echo -e "${B}[ zakonczono ]${N} usuwam plik blokujący skryptu: $LOCK_SCRIPT" 
}
# ------------------------------------------------------------------------------
lock_script
trap unlock_script EXIT
zenity --info --title="${0##*/}" --width=400 --height=100 --text "<i>Do 100 tysiecy beczek solonych sledzi!</i> \t\[ <b>$(/bin/date +%H:%M:%S)</b> \]
	
	<b><span color='#5A90C5'>$*</span></b>"
# ------------------------------------------------------------------------------
