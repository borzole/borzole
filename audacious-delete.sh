#!/bin/bash

# audacious-delete.sh -- usuń aktualnie odtwarzany plik z listy
# wersja: 2010.02.07
# autor: borzole (jedral.one.pl)

# aktualnie grana piosenka jest przenoszona do kosza
TRASH=$HOME/.local/share/Trash/files

SONG="$(audtool2 current-song-filename)"

zenity --question --title="${0##*/}" --width=500 \
	--text "Przenieść do kosza piosenkę ?!\n\n<b>$SONG</b>" \
	--ok-label="Usuń"

if [ $? -eq 0 ] ; then
	mkdir -p "${TRASH}${SONG%/*}" 2>/dev/null
	mv "$SONG" "${TRASH}${SONG}"
	# usuń piosenkę z playlisty
	audtool2 playlist-delete $(audtool2 playlist-position)
	# przejdź do następnego utworu
	audacious2 -f
	# play
	audacious2 -p
fi
