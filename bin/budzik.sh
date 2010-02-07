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
. bslib.sh
ScriptUnlock
ScriptLock
trap ScriptUnlock EXIT
zenity --info --title="${0##*/}" --width=400 --height=100 --text \
"<i>Do 100 tysiecy beczek solonych sledzi!</i> \t\[ <b>$(/bin/date +%H:%M:%S)</b> \]
	
	<b><span color='#5A90C5'>$*</span></b>"
