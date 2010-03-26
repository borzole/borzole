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
#    * dokładność cięcia co do piksela
# ------------------------------------------------------------------------------
# jeśli odrazu podasz więcej niż nazwę pliku to olejemy GUI
[[ $# -gt 1 ]] && CLI=0
# ------------------------------------------------------------------------------
menu(){
	zenity --title="${0##*/}"  --entry  --entry-text "2 2" \
		--text "Jak posiekać plakat?\n
plik: 		$FILE
wymiary: 	$WIDTH x $HEIGHT\n
wprowadź: 	KOLUMNY  WIERSZE"
}
# ------------------------------------------------------------------------------
error(){
	ERROR="$@"
	if [[ -n $CLI ]] ; then
		echo -e "$ERROR" >&2
	else
		zenity --error --title="${0##*/}" --text="$ERROR" --width=200
	fi
	exit 1
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
ERROR="Nie ma takiego pliku: \n$FILE"
[[ ! -f $FILE ]] && error "$ERROR"
# ------------------------------------------------------------------------------
# nazwa pliku bez rozszerzenia
NAME="${FILE%.*}"
# rozszerzenie pliku
[[ -n ${FILE##*.} ]] && EXT=".${FILE##*.}" || EXT="" 
# ------------------------------------------------------------------------------
# wymiary obrazka
ERROR="Nie udało się pobrać wymirów obrazka: \n$FILE \nplik nie jest obrazem"
WIDTH=$(identify -format "%[fx:w]" "$FILE")  || error "$ERROR"
HEIGHT=$(identify -format "%[fx:h]" "$FILE") || error "$ERROR"
# ------------------------------------------------------------------------------
# ustawienie ilości kolumn i wierszy
if [[ $# -eq 1 ]] ; then
	# z menu
	ENTRY_RAW=$(menu) || exit 0
	COL=$(echo $ENTRY_RAW | awk '{ print $1}')
	[[ -z $COL ]] && error "Nie podano na ile wierszy i kolumn pociąć obrazek"
	ROW=$(echo $ENTRY_RAW | awk '{ print $2}')
else
	# drugi parametr ozn. ilość kolumn (i wierszy)
	COL=$2
	# jeśli podano trzeci parametr to ozn. ilość wierszy
	[[ -n $3 ]] && ROW=$3
fi
# sprawdźmy format wprowadzonych danych
ERROR="parametr musi być liczbą całkowitą i ma sens gdy jest większy od zera"
echo $COL | grep -E '[^0-9]' && error "Podano ilość kolumn: $COL \n$ERROR"
echo $ROW | grep -E '[^0-9]' && error "Podano ilość wierszy: $ROW \n$ERROR"
# jeśli nie podano ilości wierszy, to jest taka sama jak ilość kolumn
[[ -z $ROW ]] && ROW=$COL
# ------------------------------------------------------------------------------
# pasek postępu
[[ -z $CLI ]] && exec 4> >(zenity --title="${0##*/}" --width=300 --progress --pulsate --auto-close --auto-kill )
# po ustawieniu wszystkiego, następuje cięcie!
w=$((${WIDTH}/${COL}))
h=$((${HEIGHT}/${ROW}))
all=$((${COL}*${ROW}))
for (( i=1 ; i <= ${COL} ; i++ )) ; do
	x=$(( (${i}-1)*${w} ))
	for (( j=1 ; j <= ${ROW} ; j++ )) ; do
		y=$(( (${j}-1)*${h} ))
		GEOMETRY=${w}x${h}+${x}+${y}
		OUTPUT="${NAME}-y${j}x${i}${EXT}"
		MSG="Generuje plik $(((${i}-1)*${COL} + ${j})) z $all : $OUTPUT ... "
		[[ -z $CLI ]] && echo "# $MSG" >&4 || echo -n $MSG
		convert -crop $GEOMETRY +repage "$FILE" "$OUTPUT"
		[[ -n $CLI ]] && echo " OK"
	done
done
# zamknięcie paska postępu
[[ -z $CLI ]] && { echo "100" >&4 ; exec 4>&- ; }
