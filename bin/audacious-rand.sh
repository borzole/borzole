#!/bin/bash

# audacious-rand.sh -- losuje piosenki do playlisty
# wersja:2010.05.26-15:16
# autor: borzole (jedral.one.pl)

# ------------------------------------------------------------------------------
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1
shopt -s globstar

# folder z obrazkami: domyślny lub z parametru
if [ $# -eq 0 ] ; then
	. $HOME/.config/user-dirs.dirs 2>/dev/null
	DIR="$XDG_MUSIC_DIR"
else
	DIR="$@"
fi
[[ ! -d $DIR ]] && {
	zenity --error --title="${0##*/}" --text "<b><span color='#FF0000'>Nie istnieje folder:</span></b>\n${DIR}"
	exit 1
}
# ------------------------------------------------------------------------------
get_nr(){
	# "OK" - zwraca ile piosenek będzie losowane
	# "Anuluj" - koniec skryptu
	zenity --scale --title="${0##*/}" --width=300 \
		--text="Ile piosenek wylosować panie?" \
		--value=100 --min-value=5 --max-value=500 --step=5
}
# ------------------------------------------------------------------------------
get_files(){
	# zwraca wylosowaną listę
	for p in $DIR/**/*.mp3 ; do
		echo $p
	done 2>/dev/null | shuf -n$NR
}
# ------------------------------------------------------------------------------
daemon(){
	# włączy odtwarzanie jak tylko znajdzie coś na liście,
	# więc nie trzeba czekać na załadowanie całej listy.
	while : ; do
		if [ $(audtool2 playlist-length) -gt 0 ] ; then
			audacious2 -p &
			exit $?
		else
			sleep 0.1
			$FUNCNAME
		fi
	done
}
# ------------------------------------------------------------------------------
NR=$(get_nr) || exit 0
# sprawdzamy czy działa audacious2, jeśli nie to uruchamiamy
# bez tego nie działają narzędzia "audtool2"
pidof audacious2 >/dev/null 2>&1 || {
	audacious2 &
	# wymagane jest drobne opóźnienie
	sleep 0.1
}
# aktywujemy UI ?
audtool2 activate
# wyczyść playlistę
audtool2 playlist-clear
# włącz demona
daemon &
# powolne zapełnianie playlisty
get_files | while read -r LINE ; do
	audtool2 playlist-addurl "file://${LINE}"
	sleep 0.05 # a tak, co by nie przemęczać systemu
done


# ------------------------------------------------------------------------------
