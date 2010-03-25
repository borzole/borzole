#!/bin/bash

# gilotyna.sh -- sieka plakat (obraz) na części
# autor: borzole (jedral.one.pl)
# wymaga: ImageMagick zenity
#
# Użycie:
#    * wrzucić do folderu $HOME/.gnome2/nautilus-scripts/
#      i mieć w GNOME pod myszą
#    * wrzucić do folderu /usr/local/bin/
#      i uruchamiać z parametrami lub bez np.:
#        $ gilotyna.sh
#        $ gilotyna.sh plik.png
#        $ gilotyna.sh plik.png 3    # sieka 3x3
#        $ gilotyna.sh plik.png 3 4  # sieka 3x4
#      czego mu zabraknie to się upomni
# Uwaga!
#    * skrypt nie sprawdza czy dany plik nadaje się do pocięcia przez ImageMagick
#    * dokładność cięcia co do piksela
# ------------------------------------------------------------------------------
menu(){
	zenity --title="${0##*/}"  --entry  --entry-text "2 2" \
		--text "Jak posiekać plakat?\n
plik: 		$FILE
wymiary: 	$WIDTH x $HEIGHT\n
wprowadź: 	KOLUMNY  WIERSZE"
}
# ------------------------------------------------------------------------------
get_file(){
	zenity --file-selection --title="Wybierz plik: plakat do pocięcia"
}
# ------------------------------------------------------------------------------
# podaj plik jako parametr w konsoli lub z zaznaczenia w nautilus-scripts
# jeśli plik nie został podany jako parametr to wyświetli się okienko
FILE="${1:-${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-$(get_file)}}" || exit 0
# sprawdzamy, czy to rzeczywiście plik 
if [[ ! -f $FILE ]] ; then
	ERROR="Nie ma takiego pliku: \n$FILE"
	zenity --error --title="${0##*/}" --text="$ERROR" --width=200
	echo -e "$ERROR" >&2
	exit 1
fi
# ------------------------------------------------------------------------------
# nazwa pliku bez rozszerzenia
NAME="${FILE%.*}"
# rozszerzenie pliku
[[ -n ${FILE##*.} ]] && EXT=".${FILE##*.}" || EXT="" 
# ------------------------------------------------------------------------------
# wymiary obrazka
WIDTH=$(identify -format "%[fx:w]" "$FILE")
HEIGHT=$(identify -format "%[fx:h]" "$FILE")
# ------------------------------------------------------------------------------
# ustawienie ilości kolumn i wierszy
if [[ -z $2 ]] ; then
	# z menu
	ENTRY_RAW=$(menu) || exit 0
	COL=$( echo $ENTRY_RAW | cut -d' ' -f1 )
	ROW=$( echo $ENTRY_RAW | cut -d' ' -f2 )
else
	# w konsoli, drugi parametr ozn. ilość kolumn (i wierszy)
	COL=$2
	# jeśli podano trzeci parametr to ozn. ilość wierszy
	[[ -n $3 ]] && ROW=$3 || ROW=$COL
fi
# ------------------------------------------------------------------------------
# pasek postępu
exec 4> >(zenity --title="${0##*/}" --width=300 --progress --pulsate --auto-close --auto-kill )
# po ustawieniu wszystkiego, następuje cięcie!
w=$((${WIDTH}/${COL}))  || exit 1 # wyjdź jeśli COL nie jest liczbą całkowitą 
h=$((${HEIGHT}/${ROW})) || exit 1 # wyjdź jeśli ROW nie jest liczbą całkowitą 
for (( i=1 ; i <= ${COL} ; i++ )) ; do
	x=$(( (${i}-1)*${w} ))
	for (( j=1 ; j <= ${ROW} ; j++ )) ; do
		y=$(( (${j}-1)*${h} ))
		GEOMETRY=${w}x${h}+${x}+${y}
		OUTPUT="${NAME}-y${j}x${i}${EXT}"
		echo "# Generuje plik: $OUTPUT ..." >&4
		convert -crop $GEOMETRY +repage "$FILE" "$OUTPUT"
	done
done
# zamknięcie paska postępu
echo "100" >&4
exec 4>&-
