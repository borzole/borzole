#!/bin/bash

# gilotyna.sh -- sieka plakat (obraz) na części
# autor: borzole (jedral.one.pl)
# wymaga: ImageMagick zenity
#
# skrypt można uruchomić
#    * z plikiem jako parametrem
#    * wrzucić do folderu $HOME/.gnome2/nautilus-scripts/
#      i mieć w GNOME pod myszą
#    * bez parametru i wówczas otworzy się okienko do wyznaczenia pliku
#
#@TODO: siekanie na 3 w pionie i poziomi oraz na 9
# ------------------------------------------------------------------------------
geometry(){
	# parametr: plik
	# zwraca: width height offset-x offset-y
	identify -verbose "$1" \
		| awk '/Geometry/ { printf $2 "\n"}' \
		| sed -e 's/[x+]/ /g'
}
# ------------------------------------------------------------------------------
convert-crop(){
	# silnik z ImageMagick
	convert -crop $GEOMETRY +repage "$1" "$OUTPUT" 
}
# ------------------------------------------------------------------------------
# cięcia proste
# ------------------------------------------------------------------------------
crop_l(){
	GEOMETRY=$((${1}/2))x${2}+${3}+${4}
	OUTPUT="${5%.*}-left.${5##*.}"
	convert-crop "$5"
	echo "$OUTPUT"
}
# ------------------------------------------------------------------------------
crop_r(){
	GEOMETRY=$((${1}/2))x${2}+$((${1}/2))+${4}
	OUTPUT="${5%.*}-right.${5##*.}"
	convert-crop "$5"
	echo "$OUTPUT"
}
# ------------------------------------------------------------------------------
crop_t(){
	GEOMETRY=${1}x$((${2}/2))+${3}+${4}
	OUTPUT="${5%.*}-top.${5##*.}"
	convert-crop "$5"
	echo "$OUTPUT"
}
# ------------------------------------------------------------------------------
crop_b(){
	GEOMETRY=${1}x$((${2}/2))+${3}+$((${2}/2))
	OUTPUT="${5%.*}-bottom.${5##*.}"
	convert-crop "$5"
	echo "$OUTPUT"
}
# ------------------------------------------------------------------------------
# cięcia złożone
# ------------------------------------------------------------------------------
crop_2lr(){
	bar_on
	msg "lewy"
	crop_l $(geometry "$FILE") "$FILE" >/dev/null
	msg "prawy"
	crop_r $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_2tb(){
	bar_on
	msg "góra"
	crop_t $(geometry "$FILE") "$FILE" >/dev/null
	msg "dół"
	crop_b $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_4(){
	bar_on
	msg "góra (tymczasowy)"
	FILE_T=$( crop_t $(geometry "$FILE") "$FILE" )
	msg "dół (tymczasowy)"
	FILE_B=$( crop_b $(geometry "$FILE") "$FILE" )
	msg "góra-lewy"
	FILE_TL=$( crop_l $(geometry "$FILE_T") "$FILE_T" )
	msg "góra-prawy"
	FILE_TR=$( crop_r $(geometry "$FILE_T") "$FILE_T" )
	msg "dół-lewy"
	FILE_BL=$( crop_l $(geometry "$FILE_B") "$FILE_B" )
	msg "dół-prawy"
	FILE_BR=$( crop_r $(geometry "$FILE_B") "$FILE_B" )
	msg "usuwam pliki tymczasowe"
	rm -f "$FILE_T" "$FILE_B"
	bar_off
}
# ------------------------------------------------------------------------------
# pasek postępu
# ------------------------------------------------------------------------------
bar_on(){
	exec 4> >(zenity --title="${0##*/}" --width=300 \
		--progress --pulsate --auto-close --auto-kill )
}
# ------------------------------------------------------------------------------
bar_off(){
	echo "100" >&4
	exec 4>&-
}
# ------------------------------------------------------------------------------
msg(){
	echo "# Przycinam: $@ ..." >&4
}
# ------------------------------------------------------------------------------
# wybór pliku
# ------------------------------------------------------------------------------
get_file(){
	zenity --file-selection --title="Wybierz plik: plakat do pocięcia"
}
# ------------------------------------------------------------------------------
# podaj plik jako parametr w konsoli lub z zaznaczenia w nautilus-scripts
# jeśli plik nie został podany jako parametr to wyświetli się okienko
FILE="${1:-${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-$(get_file)}}"
# Sprawdzamy, czy to plik
if [[ ! -f $FILE ]] ; then
	echo "Nie ma takiego pliku" >&2
	exit 1
fi
# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
menu_crop(){
	# okno z listą funkcji
	zenity 	--title="${0##*/}"  --text "<b>${FILE}</b>" \
		--list  --radiolist --width=400 --height=200 \
		--column="todo" --column "Jak posiekać plakat?" --column "" \
			FALSE	"2: lewy/prawy"		crop_2lr \
			FALSE	"2: góra/dół" 		crop_2tb \
			FALSE	"4: na krzyż" 		crop_4 \
		--print-column=3 --hide-column=3
}
# ------------------------------------------------------------------------------
$(menu_crop)
