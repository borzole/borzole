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
# ------------------------------------------------------------------------------
geometry(){
	# wyciąga info o wymiarach z obrazka
	# parametr: plik
	# zwraca: width height offset-x offset-y
	identify -verbose "$1" \
		| awk '/Geometry/ { printf $2 "\n"}' \
		| sed -e 's/[x+]/ /g'
}
# ------------------------------------------------------------------------------
convert-crop(){
	# generuje przycięty plik
	# parametr: plik marker
	# zwraca: nazwa_pliku_wyjściowego
	OUTPUT="${1%.*}-${2}${EXT}"
	convert -crop $GEOMETRY +repage "$1" "$OUTPUT"
	echo "$OUTPUT"
}
# ------------------------------------------------------------------------------
# cięcia proste
# ------------------------------------------------------------------------------
#    ustalają wymiary do cięcia i oznaczenie generowanego pliku
#    parametr: width height offset-x offset-y plik
#    zwraca: nazwa_pliku_wyjściowego
# ------------------------------------------------------------------------------
crop_l(){
	GEOMETRY=$((${1}/2))x${2}+${3}+${4}
	convert-crop "$5" left
}
# ------------------------------------------------------------------------------
crop_r(){
	GEOMETRY=$((${1}/2))x${2}+$((${1}/2))+${4}
	convert-crop "$5" right
}
# ------------------------------------------------------------------------------
crop_t(){
	GEOMETRY=${1}x$((${2}/2))+${3}+${4}
	convert-crop "$5" top
}
# ------------------------------------------------------------------------------
crop_b(){
	GEOMETRY=${1}x$((${2}/2))+${3}+$((${2}/2))
	convert-crop "$5" bottom
}
# ------------------------------------------------------------------------------
crop_3l(){
	GEOMETRY=$((${1}/3))x${2}+${3}+${4}
	convert-crop "$5" 3left
}
# ------------------------------------------------------------------------------
crop_3ch(){
	GEOMETRY=$((${1}/3))x${2}+$((${1}/3))+${4}
	convert-crop "$5" 3center_horizon
}
# ------------------------------------------------------------------------------
crop_3r(){
	GEOMETRY=$((${1}/3))x${2}+$((2*${1}/3))+${4}
	convert-crop "$5" 3right
}
# ------------------------------------------------------------------------------
crop_3t(){
	GEOMETRY=${1}x$((${2}/3))+${3}+${4}
	convert-crop "$5" 3top
}
# ------------------------------------------------------------------------------
crop_3cv(){
	GEOMETRY=${1}x$((${2}/3))+${3}+$((${2}/3))
	convert-crop "$5" 3center_vertical
}
# ------------------------------------------------------------------------------
crop_3b(){
	GEOMETRY=${1}x$((${2}/3))+${3}+$((2*${2}/3))
	convert-crop "$5" 3bottom
}
# ------------------------------------------------------------------------------
# cięcia złożone (efekt końcowy)
# ------------------------------------------------------------------------------
crop_2lr(){
	# generuje 2 pliki: część lewą i prawą
	bar_on
	msg "lewy"
	crop_l $(geometry "$FILE") "$FILE" >/dev/null
	msg "prawy"
	crop_r $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_2tb(){
	# generuje 2 pliki: część górną i dolną
	bar_on
	msg "góra"
	crop_t $(geometry "$FILE") "$FILE" >/dev/null
	msg "dół"
	crop_b $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_3lcr(){
	# generuje 3 pliki: część lewą, środkową, prawą
	bar_on
	msg "lewy"
	crop_3r $(geometry "$FILE") "$FILE" >/dev/null
	msg "środek"
	crop_3ch $(geometry "$FILE") "$FILE" >/dev/null
	msg "prawy"
	crop_3l $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_3tcb(){
	# generuje 3 pliki: część górną, środkową, dolną
	bar_on
	msg "góra"
	crop_3t $(geometry "$FILE") "$FILE" >/dev/null
	msg "środek"
	crop_3cv $(geometry "$FILE") "$FILE" >/dev/null
	msg "dół"
	crop_3b $(geometry "$FILE") "$FILE" >/dev/null
	bar_off
}
# ------------------------------------------------------------------------------
crop_4(){
	# generuje 4 pliki: ćwiartki
	bar_on
	msg "góra (tymczasowy)"
	FILE_T=$( crop_t $(geometry "$FILE") "$FILE" )
	msg "dół (tymczasowy)"
	FILE_B=$( crop_b $(geometry "$FILE") "$FILE" )

	msg "góra-lewy"
	crop_l $(geometry "$FILE_T") "$FILE_T" >/dev/null
	msg "góra-prawy"
	crop_r $(geometry "$FILE_T") "$FILE_T" >/dev/null
	msg "dół-lewy"
	crop_l $(geometry "$FILE_B") "$FILE_B" >/dev/null
	msg "dół-prawy"
	crop_r $(geometry "$FILE_B") "$FILE_B" >/dev/null

	msg "usuwam pliki tymczasowe"
	rm -f "$FILE_T" "$FILE_B"
	bar_off
}
# ------------------------------------------------------------------------------
crop_9(){
	# generuje 4 pliki: ćwiartki
	bar_on
	msg "góra (tymczasowy)"
	FILE_T=$( crop_3t $(geometry "$FILE") "$FILE" )
	msg "środek (tymczasowy)"
	FILE_C=$( crop_3cv $(geometry "$FILE") "$FILE" )
	msg "dół (tymczasowy)"
	FILE_B=$( crop_3b $(geometry "$FILE") "$FILE" )

	msg "góra-lewy"
	crop_3l $(geometry "$FILE_T") "$FILE_T" >/dev/null
	msg "góra-środek"
	crop_3ch $(geometry "$FILE_T") "$FILE_T" >/dev/null
	msg "góra-prawy"
	crop_3r $(geometry "$FILE_T") "$FILE_T" >/dev/null

	msg "środek-lewy"
	crop_3l $(geometry "$FILE_C") "$FILE_C" >/dev/null
	msg "środek-środek"
	crop_3ch $(geometry "$FILE_C") "$FILE_C" >/dev/null
	msg "środek-prawy"
	crop_3r $(geometry "$FILE_C") "$FILE_C" >/dev/null

	msg "dół-lewy"
	crop_3l $(geometry "$FILE_B") "$FILE_B" >/dev/null
	msg "dół-środek"
	crop_3ch $(geometry "$FILE_B") "$FILE_B" >/dev/null
	msg "dół-prawy"
	crop_3r $(geometry "$FILE_B") "$FILE_B" >/dev/null

	msg "usuwam pliki tymczasowe"
	rm -f "$FILE_T" "$FILE_C" "$FILE_B"
	bar_off
}
# ------------------------------------------------------------------------------
# pasek postępu
# ------------------------------------------------------------------------------
bar_on(){
	# włącza pasek postępu zenity, a dane pobiera z deskryptor pliku 4
	exec 4> >(zenity --title="${0##*/}" --width=300 \
		--progress --pulsate --auto-close --auto-kill )
}
# ------------------------------------------------------------------------------
bar_off(){
	# wyłącza pasek postępu i zamyka deskryptor pliku 4
	echo "100" >&4
	exec 4>&-
}
# ------------------------------------------------------------------------------
msg(){
	# ustawia opis paska postępu
	# paramtr: 
	echo "# Przycinam: $@ ..." >&4
}
# ------------------------------------------------------------------------------
# wybór pliku
# ------------------------------------------------------------------------------
get_file(){
	# wybiera plik
	# zwraca: nazwa_pliku
	zenity --file-selection --title="Wybierz plik: plakat do pocięcia"
}
# ------------------------------------------------------------------------------
# podaj plik jako parametr w konsoli lub z zaznaczenia w nautilus-scripts
# jeśli plik nie został podany jako parametr to wyświetli się okienko
FILE="${1:-${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS:-$(get_file)}}"
# Sprawdzamy, czy to plik 
if [[ ! -f $FILE ]] ; then
	ERROR="Nie ma takiego pliku: \n$FILE"
	zenity --error --title="${0##*/}" --text="$ERROR" --width=200
	echo -e "$ERROR" >&2
	exit 1
fi
# ------------------------------------------------------------------------------
# określenie rozszerzenia pliku
# ------------------------------------------------------------------------------
if [[ -n ${FILE##*.} ]] ; then
	EXT=".${FILE##*.}"
else
	EXT=""
fi
# ------------------------------------------------------------------------------
# main
# ------------------------------------------------------------------------------
menu_crop(){
	# okno z listą funkcji
	zenity 	--title="${0##*/}"  --text "<b>${FILE}</b>" \
		--list  --radiolist --width=250 --height=240 \
		--column="todo" --column "Jak posiekać plakat?" --column "" \
			FALSE	"2: lewy/prawy"			crop_2lr \
			FALSE	"2: góra/dół" 			crop_2tb \
			FALSE	"3: lewy/środek/prawy" 	crop_3lcr \
			FALSE	"3: góra/środek/dół" 	crop_3tcb \
			FALSE	"4: na krzyż" 			crop_4 \
			FALSE	"9: kółko i krzyżyk"	crop_9 \
		--print-column=3 --hide-column=3
}
# ------------------------------------------------------------------------------
$(menu_crop)
