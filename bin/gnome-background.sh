#!/bin/bash

# gnome-background.sh -- ustawia losową tapetę z katalogu

# użycie:
# 	gnome-background.sh                     # losuje z domyślnego folderu
# 	gnome-background.sh ./                  # losuje z bieżącego folderu
# 	gnome-background.sh /path/to/folder     # losuje z folderu

# autor: borzole (jedral.one.pl)
# wersja: 2010.07.12
# źródło: http://borzole.googlecode.com/hg/bin/gnome-background.sh
# pierwowzór: http://www.webupd8.org/2009/11/3-lines-script-to-automatically-change.html

# ------------------------------------------------------------------------------
random_picture(){
	# losuje tapetę z pośród określonych typów plików (wielkość liter dowolna)
	find "$DIR" -xtype f \( \
				-iname "*.jpg" \
			-or -iname "*.png" \
			-or -iname "*.svg" \
			-or -iname "*.gif" \
			-or -iname "*.xml" \
			\) 2>/dev/null | shuf -n1
	# info: http://www.cyberciti.biz/faq/find-command-exclude-ignore-files/
}
# ------------------------------------------------------------------------------
# folder z obrazkami
if [ $# -eq 0 ] ; then
	DIR=/usr/share/backgrounds/images
	ORG=DIR
else
	# rozwiń na pełną ścieżkę
	DIR=$(readlink -f "$@")
	ORG="$@"
fi
# TEST: czy istnieje taki folder?
[ ! -d "$DIR" ] && { echo "Nie ma takiego folderu: $ORG" ; exit 1 ; }
# ------------------------------------------------------------------------------
PICTURE="$(random_picture)"
# TEST: czy wylosowano choć jedną tapetę?
[ -z "$PICTURE" ] && { echo "Folder '$DIR' nie zawiera tapet" ; exit 1 ; }
# ------------------------------------------------------------------------------
# w Cron parametr DBUS_SESSION_BUS_ADDRESS nie istnieje,
# dlatego trzeba go wyciągnąć z bierzącej sesji
# źródło: https://bugs.launchpad.net/ubuntu/+source/gconf/+bug/285937
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] ; then
	TMP=~/.dbus/session-bus
	export $(grep -h DBUS_SESSION_BUS_ADDRESS= $TMP/$(ls -1t $TMP | head -n 1))
fi
# ------------------------------------------------------------------------------
gconftool-2 -t string -s /desktop/gnome/background/picture_filename "$(random_picture)"
