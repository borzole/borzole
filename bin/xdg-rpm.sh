#!/bin/bash

# szybki podgląd plików z paczki rpm

usage(){
	echo -e "${0##*/} <paczka>

INFO:
	-- Szybki podgląd plików z paczki rpm
	Używa xdg-open, aby otworzyć/wykonać plik z paczki

PRZYKŁAD:
	-- wszystkie pliki z paczki
	${0##*/} yum
	-- z rozszerzeniem 'py'
	${0##*/} yum py

by jedral.one.pl
"
	exit 0
}
[ $# = 0 ] && usage
# ------------------------------------------------------------------------------
APPS=$1
TYPE=$2

format(){
	[ -z "$TYPE" ] && FILES=$(rpm -ql $APPS) || FILES=$(rpm -ql $APPS | grep "\.$TYPE$" )

	for p in $FILES; do
		echo "FALSE $p"
	done
}
menu() {
	zenity --title="${0##*/}" --text "Wybierz plik z <b>$APPS</b>" \
		--width=600 --height=800 \
		--list  --checklist \
		--column="zaznacz" --column "plik" \
		$(format) \
		--separator " "  --multiple \
		--print-column=2
}

for plik in $(menu) ; do
	xdg-open $plik
done
