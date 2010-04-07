#!/bin/bash

# pdf2png.sh -- konwertuje PDF>PNG z ustaleniem jakości
# autor: borzole (jedral.one.pl)
# wymaga: ImageMagick zenity
#
# skrypt można uruchomić
#    * z plikiem jako parametrem
#    * wrzucić do folderu $HOME/.gnome2/nautilus-scripts/
#      i mieć w GNOME pod myszą
#    * bez parametru i wówczas otworzy się okienko do wyznaczenia pliku

# ------------------------------------------------------------------------------
# wybór jakości
# ------------------------------------------------------------------------------
get_density(){
	zenity --scale --title="${0##*/}" --width=300 \
  --text="Ustaw jakość pliku wyjściowego" \
  --value=300 --min-value=50 --max-value=500 --step=50
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
# konwersja
# ------------------------------------------------------------------------------
DENSITY=$(get_density)
exec 4> >(zenity --title="${0##*/}" --width=300 --progress --pulsate --auto-close --auto-kill )
echo "# Konwertuje: PDF >> PNG $@ ..." >&4
convert -density $DENSITY "$FILE" "${FILE%.pdf}.png"
echo "100" >&4
exec 4>&-
