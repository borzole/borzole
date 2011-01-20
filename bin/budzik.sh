#!/bin/bash

# budzik można uruchomić podając komentarz jako parametr

# np.
#    budzik Pora na przekąskę!
#
# Działa podobnie jak skrypt "task:" z tą różnicą, że może być uruchomiona tylko 1 instancja

# by borzole ( jedral.one.pl )


lock=/tmp/${0##*/}-${USER}.pid
[ -f $lock ] && exit || echo $$ > $lock
trap "rm -f $lock" EXIT

zenity --info --title="${0##*/}" --width=400 --height=100 --text \
"<i>Do 100 tysiecy beczek solonych sledzi!</i> \t\[ <b>$(/bin/date +%H:%M:%S)</b> \]

	<b><span color='#5A90C5'>$*</span></b>"
