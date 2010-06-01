#!/bin/bash

# usuń aktualnie odtwarzany plik do kosza

# wersja: 2010.02.10
# autor: borzole (jedral.one.pl)

# aktualnie grana piosenka jest przenoszona do kosza (GNOME)
TRASH=$HOME/.local/share/Trash/files
TITLE="--title=${0##*/}"
# ------------------------------------------------------------------------------
delete_current_song(){
	# zapisz pozycję piosenki na liście
	local NR=$(audtool2 playlist-position)
	# przejdź do następnego utworu
	audacious2 -f
	# usuń piosenkę z playlisty
	audtool2 playlist-delete $NR
	# utwórz w koszu kopię ścieżki katalogów
	# uwaga: bez "/" pomiędzy, bo $SONG jest ścieżką absolutną
	local DIR="${TRASH}${SONG%/*}"
	[ ! -d "$DIR" ] && mkdir -p "$DIR"
	# przenieś piosenkę do kosza
	mv "$SONG" "${TRASH}${SONG}"
}
# ------------------------------------------------------------------------------
SONG="$(audtool2 current-song-filename)"

# warunek: czy audacious jest uruchomiony?
if [[ $SONG == 'No song playing.' ]] ; then
	zenity --error "$TITLE" \
		--text="Nie można przenieść piosenki do kosza!
			\r<b><span color='#A52A2A'>$SONG</span></b>"
	exit 1;
else
	# jeśli jest uruchomiony, odpytaj o usunięcie aktualnej piosenki
	zenity --question "$TITLE" \
		--text="Przenieść do kosza piosenkę ?!
			\r<b>${SONG%/*}\r<span color='#A52A2A'>${SONG##*/}</span></b>" \
		--width=450 \
		--ok-label="Usuń"
	# jeśli kliknięto "Usuń"
	[ $? -eq 0 ] && delete_current_song
fi
