#!/bin/bash

# gilotyna.sh -- sieka plakat (obraz) na części
# autor: borzole (jedral.one.pl)
# wymaga: ImageMagick zenity
#
# skrypt można uruchomić
#    * z plikiem jako parametrem (opcjonalnie parametr cięcia)
#    * wrzucić do folderu $HOME/.gnome2/nautilus-scripts/
#      i mieć w GNOME pod myszą
#    * bez parametru i wówczas otworzy się okienko do wyznaczenia pliku
# ------------------------------------------------------------------------------
crop(){
	exec 4> >(zenity --title="${0##*/}" --width=300 --progress --pulsate --auto-close --auto-kill )

	w=$((${WIDTH}/${COL}))
	h=$((${HEIGHT}/${ROW}))
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

	echo "100" >&4
	exec 4>&-
}
# ------------------------------------------------------------------------------
menu(){
	zenity 	--title="${0##*/}"  --text "Jak posiekać plakat?
	
plik: 		$FILE
wymiary: 	$WIDTH x $HEIGHT
wprowadź: 	kolumny wiersze" \
		--entry  --entry-text "2 2"
}
# ------------------------------------------------------------------------------
get_file(){
	zenity --file-selection --title="Wybierz plik: plakat do pocięcia"
}
# ------------------------------------------------------------------------------
# podaj plik jako parametr w konsoli lub z zaznaczenia w nautilus-scripts
# jeśli plik nie został podany jako parametr to wyświetli się okienko
FILE="${1:-${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-$(get_file)}}"
[ $? != 0 ] && exit 0
# sprawdzamy, czy to plik 
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
if [[ -n ${FILE##*.} ]] ; then
	EXT=".${FILE##*.}"
else
	EXT=""
fi
# ------------------------------------------------------------------------------
# wymiary obrazka
WIDTH=$(identify -format "%[fx:w]" "$FILE")
HEIGHT=$(identify -format "%[fx:h]" "$FILE")

if [[ -z $2 ]] ; then
	ENTRY_RAW=$(menu)
		[ $? != 0 ] && exit 0
	COL=$( echo $ENTRY_RAW | cut -d' ' -f1 )
	ROW=$( echo $ENTRY_RAW | cut -d' ' -f2 )
else
	# w konsoli drugi parametr ozn. ilość kolumn (i wierszy)
	COL=$2
	# jeśli podano trzeci to ozn. ilość wierszy
	if [[ -z $3 ]] ; then
		ROW=$3
	else
		ROW=$COL
	fi
fi
# po ustawieniu wszystkiego, następuje cięcie!
crop
