#!/bin/bash

# gnome-background -- ustawia losową tapetę z katalogu
# źródło: http://www.webupd8.org/2009/11/3-lines-script-to-automatically-change.html
# zmiany na potrzeby cron: borzole (jedral.one.pl)
# wersja: 2010.02.07

# folder z obrazkami
if [ $# -eq 0 ] ; then
	DIR=/usr/share/backgrounds/images
else
	DIR="$@"
fi

# losuje z pośród plików jpg, png, svg (wielkość liter dowolna)
PIC="$(
for p in [jJ][pP][gG] [pP][nN][gG] [sS][vV][gG] ; do
	ls $DIR/*.$p
done 2>/dev/null | shuf -n1
)"

# w Cron parametr DBUS_SESSION_BUS_ADDRESS nie istnieje, 
# dlatego trzeba go wyciągnąć z bierzącej sesji
# źródło: https://bugs.launchpad.net/ubuntu/+source/gconf/+bug/285937
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
	TMP=~/.dbus/session-bus
	export $(grep -h DBUS_SESSION_BUS_ADDRESS= $TMP/$(ls -1t $TMP | head -n 1))
fi

gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$PIC"
