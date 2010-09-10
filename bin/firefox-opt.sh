#!/bin/bash

# komunikaty

killall firefox 2>>$LOG
find $HOME/.mozilla/ -iname \*.sqlite -exec sqlite3  '{}' "VACUUM" \; \
	| zenity --progress --pulsate --auto-close --auto-kill

firefox &
