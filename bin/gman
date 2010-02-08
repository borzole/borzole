#!/bin/bash

# gman - GUI w GTK do czytania stron man 
#
# wymaga: zenity, gxmessage (ostatecznie xmessage, ale jest wówczas brzydkie)
#
# Początkowo był to skrypt Rafała Haładuda <rh1985@wp.pl> oparty w całości o zenity. 
# Przebudowany przez borzole (jedral.one.pl) na bazie gxmessage.

# nazwa programu z parametru
APPS=$1
# lub z okienka zenity
if [ -z "$APPS" ]; then
	APPS=$(zenity --title ${0##*/} --width=400 --entry --text "strona man: ")
	[ -z "$APPS" ] && exit 0
fi
# sformatowana treść strony
MAN=$(man $APPS | col -b)
[ -z "$MAN" ] && MAN="Nie ma strony podręcznika dla $APPS"
# wyświetlenie strony
gxmessage -title "man $APPS" \
	-geometry 620x800 -center \
	-fg "#FFFFFF" -bg "#4D4D4D" \
	-font "monospace 9" \
	-buttons "Exit:0,Nowa strona:9" \
	-default Exit \
	"$MAN"
# jeśli kod wyjścia ostatniego polecenia jest "9" to powtórz skrypt
if [ $? = 9 ] ; then
	# "zerujemy" parametry
	APPS=''
	MAN=''
	# ponowne uruchomienie skryptu
	$0
fi
# uwaga: klawisz ESC zwraca kod "1"
exit 0
