#!/bin/bash

# otwiera stronę man w domyślnym edytorze

get_man_page(){
	zenity --title "${0##*/}" --entry --text "man: "
}
# -------------------------------------------------------------------
# TEST: czy jest taka strona man
is_page(){
	man $1 $MAN_PAGE > /dev/null 2>&1
	[ $? -eq 0 ] && echo "TRUE $1" || echo "FALSE $1"
}
# -------------------------------------------------------------------
menu(){
	zenity --title "${0##*/}" \
		--text "Patrz Ziutek co znalzałem dla <b>$MAN_PAGE</b>?\n(Mietek zaznaczył tylko te co znalazł)" \
		--width=400 --height=300 \
		--list  --checklist \
		--column="wybierz" --column="strona" --column "opis" \
		$(is_page 1) 'Komendy ogólne' \
		$(is_page 2) 'Wywołania systemowe' \
		$(is_page 3) 'Funkcje biblioteki C' \
		$(is_page 4) 'Pliki specjalne' \
		$(is_page 5) 'Formaty plików' \
		$(is_page 6) 'Gry komputerowe i wygaszacze ekranu' \
		$(is_page 7) 'Różne' \
		$(is_page 8) 'Administracja systemem i daemony' \
		--separator " " --multiple \
		--print-column=2
}
# -------------------------------------------------------------------
# TEST: czy są X-y (w końcu to graficzna aplikacja :P)
[ -z "$DISPLAY" ] && exit 1
# -------------------------------------------------------------------
# pobieranie nazwy strony jako parametru
MAN_PAGE="$@"
# jeśli nazwa strony nie została podana jako parametr to wyświetli się okienko
if [ -z "$MAN_PAGE" ] ; then
	MAN_PAGE=$(get_man_page)
	# jeśli nic nie wpisano, to żegnamy się grzecznie bez słowa
	[ -z "$MAN_PAGE" ] && exit 0
fi
# -------------------------------------------------------------------
# TEST: czy istnieje jakikolwiek rozdział strony man
ISPAGE=1
for p in {1..8} ; do
	man $p $MAN_PAGE > /dev/null 2>&1
	if [ $? -eq 0 ] ; then
		# jeśli jakaś strona się znalazła to zmieniamy status i przerywamy test
		ISPAGE=0
		break
	fi
done
# jeśli po całym teście nic nie znaleziono to trzeba się pożegnać
if [ $ISPAGE -ne 0 ] ; then
	MSG="Ej fraglesie!\nNie ma żadnej strony:\n\n\t$MAN_PAGE"
	zenity --title ${0##*/} --error --text "$MSG"
	echo "$MSG" >&2
	exit 1
fi
# -------------------------------------------------------------------
# generowanie stron wybranych z menu
for p in $(menu) ; do
	MAN_FILE="${HOME}/${MAN_PAGE}(${p}).man"
	# TEST: czy jest taka strona man
	man $p $MAN_PAGE > /dev/null
	if [ $? == 0 ] ; then
		man $p $MAN_PAGE | col -b > $MAN_FILE
		xdg-open $MAN_FILE
	else
		MSG="Ej fraglesie!\nNie ma takiej strony:\n\n\t$MAN_PAGE($p)"
		zenity --title ${0##*/} --error --text "$MSG"
		echo "$MSG" >&2
	fi
done
