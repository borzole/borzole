#!/bin/bash

# pobiera paczki RPM prosto z http://wiki.fedora.pl/wiki/repo

# autor: borzole (jedral.one.pl)
# licencja: GPLv2+

VERSION=2010.03.06-16:11
# Zmiany: użyj "meld" lub "diff" to się dowiesz ;P
# ------------------------------------------------------------------------------
# domyślny folder pobierania
DIR=$HOME
# ------------------------------------------------------------------------------
# tytuł okien
TITLE="${0##*/} ver.$VERSION"
# ------------------------------------------------------------------------------
#~ export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
usage(){
	echo -e "  ${0##*/} -- pobiera paczki RPM prosto z http://wiki.fedora.pl/wiki/repo

Użycie:
  ${0##*/} [OPCJA...]

Opcje:
  -l, --list                   Wyświetl listę linków bez GUI i zakończ program
                               (umożliwia własne przetwarzanie tych danych)
  -V, --version                Wyświetl informacje o wersji i zakończ program
  -h, --help                   Wyświetla opcje pomocy

Licencja:
  GPLv2+

Autor:
  Łukasz Jędral ( borzole )
  borzole@gmail.com
  http://jedral.one.pl"
}
# ------------------------------------------------------------------------------
usage_gui(){
	# wyświetla pomoc w wersji okienkowej
	usage | zenity --title="$TITLE" --text-info --width=500 --height=350
	menu_function
}
# ------------------------------------------------------------------------------
get_links(){
	# zwraca listę linków do paczek rpm oddzieloną znakiem nowego wiersza
	# informacja jest wyłuskiwana z tej strony
	local thisURL="http://wiki.fedora.pl/index.php?title=repo&action=raw&ctype=text/css"
	# metoda:
	#	- sed: każdą spację, tabulator i "[" zamienić na znak nowej linii
	#		( składnia linków na wiki wymusza tę spację i nawias )
	#	- grep: wylapać tylko linie zaczynające się od:
	#			http://
	#			https://
	#			ftp://
	#			i kończące się na ".rpm"
	#	- sort: posortowanie i usunięcie pustych linii
	curl -s "$thisURL"  \
		| sed -e 's:[\ \t\[]:\n:g' \
		| grep -E '^(http|https|ftp)\:\/\/.*\.rpm$' \
		| sort -u
}
# ------------------------------------------------------------------------------
set_rpmlist(){
	# inicjalizuje listę paczek z repo
	# deskryptor pliku 4 = wejście informacyjne dla paska postępu
	exec 4> >(zenity --progress --pulsate --width=300 --auto-close --auto-kill --title="$TITLE")
	echo "# Pobieram listę paczek ..." >&4
	# załaduj listę linków do jednej tabeli
	unset RPMLIST
	RPMLIST=($(get_links))
	# wysłanie setki wywoła "--auto-close" i pasek zniknie
	echo "100" >&4
	# zamknięcie deskryptora 4
	exec 4>&-
}
# ------------------------------------------------------------------------------
init(){
	while [ $# != 0 ] ; do
		case "$1" in
			-l|--list)
				# pokaż listę rpm i wyjdź
				get_links
				exit 0
				;;
			-V|--version)
				echo $VERSION
				exit 0
				;;
			-h|--help)
				usage
				exit 0
				;;
			*)
				usage
				exit 1
				;;
		esac
	done
}
# ------------------------------------------------------------------------------
requires(){
	# sprawdza zależności skryptu
	local thisSTATUS=OK
	# czcionka: (N)ORMAL, (R)ED
	local N="\e[0m"
	local R="\e[1;31m"

	for APPS in "$@" ; do
		type ${APPS} >/dev/null 2>&1
		if [ $? != 0 ] ; then
			echo -e "${R}[ ERROR ]${N} Nie znaleziono programu '${R}$APPS${N}'" >&2
			thisSTATUS=ERROR
		fi
	done

	# podsumowanie testu
	if [ $thisSTATUS == 'ERROR' ] ; then
		echo -e "a) zainstaluj program:
			\r\tsu -c'yum install aplikacja'
			\rb) lub odszukaj paczkę dostarczającą wymaganą zależność:
			\r\tsu -c'yum provides aplikacja'
			\r\tsu -c'yum provides \\*bin/aplikacja'" >&2
		exit 1;
	fi
}
# ------------------------------------------------------------------------------
main(){
	# główna
	init $@
	requires wget curl xterm zenity notify-send
	set_rpmlist
	update &
	ui
}
# ------------------------------------------------------------------------------
update(){
	# sprawdzanie aktualizacji
	local thisUPDATE_URL="http://dl.dropbox.com/u/409786/pub/bin/zwikirepo"
	UPDATE_FILE=$(mktemp)
	# jeśli coś przerwie skrypt to usuń ten plik
	trap "rm -f $UPDATE_FILE 2>/dev/null" EXIT
	curl -s "$thisUPDATE_URL"  > $UPDATE_FILE
	VERSION_LAST=$(grep -E '^VERSION=' $UPDATE_FILE | cut -d\= -f2)
	[ "$VERSION" != "$VERSION_LAST" ] && update_script
	exit 0
}
# ------------------------------------------------------------------------------
update_save_file(){
	UPDATE_FILE_SAVE=$(zenity --title="Zapisz aktualną wersję jako ..." \
					--file-selection \
					--filename=${0##*/} \
					--save --confirm-overwrite )
	if [ $? != 0 ] ; then
		# w razie nie wybrania niczego
		zenity --question --title="$TITLE" \
				--text "Nie wybrano gdzie zapisać aktualną wersję !\n Chcesz spróbować zapisać jeszcze raz?"
		[ $? == 0 ] && ${FUNCNAME}
	fi
}
# ------------------------------------------------------------------------------
update_script(){
	local thisINFO="Dostępna jest aktualizacja skryptu"
	local thisINFO_LONG="<i>$thisINFO: <big><span color='red'>${0##*/}</span>!</big></i>"

	# dymek
	notify-send --urgency critical --expire-time 4000 "$TITLE" "$thisINFO_LONG"
	# ikona
	zenity --notification --text "$thisINFO '${0##*/}'!"
	# kliknięcie na ikonę
	if [ $? == 0 ] ; then
		zenity --question --title="$TITLE" --width=400 \
			--text "$thisINFO_LONG
			\r$VERSION - lokalna wersja	\n<b>$VERSION_LAST</b> - ostatnia wersja
			\rZapisać ostatnią wersję?"
		[ $? == 0 ] && update_save_file
		[ $? == 0 ] && mv $UPDATE_FILE "$UPDATE_FILE_SAVE"

	fi
}
# ------------------------------------------------------------------------------
ui(){
	menu_rpmlist
}
# ------------------------------------------------------------------------------
set_dir(){
	# ustawienie folderu pobierania
	TMP=$(zenity --file-selection --directory --title="Wybierz katalog")
	[ $? == 0 ] && DIR="$TMP"
	menu_function
}
# ------------------------------------------------------------------------------
download(){
	[ ! -d "$DIR" ] && mkdir -p "$DIR"
	for RPMNR in ${LISTA} ; do
		# usunąłem $TERM na rzecz xterm
		# bo parametr jest ustawiony tylko jeśli program startuje z konsoli
		xterm -e wget -P "$DIR" "$1" "${RPMLIST[${RPMNR}]}"
	done
}
# ------------------------------------------------------------------------------
menu_function_show(){
	# okno z listą funkcji
	zenity 	--title="$TITLE"  --text "Drobne ustawienia i hopa :)" \
		--list  --radiolist --width=400 --height=200 \
		--column="todo" --column "polecenie do wykonania" --column "" \
			TRUE	"Pobierz pakiet(y)"					"download"\
			FALSE	"Pobierz pakiet(y) w drzewo :)" 	"download -x"\
			FALSE	"Zmień folder pobierania: $DIR"		"set_dir"\
			FALSE	"Pomoc"								"usage_gui"\
		--print-column=3 --hide-column=3
}
# ------------------------------------------------------------------------------
menu_function(){
	# obsługa menu poleceń
	# wykonanie poleceń:
	$(menu_function_show)
	# powrót do głównego menu
	menu_rpmlist
}
# ------------------------------------------------------------------------------
menu_rpmlist_table(){
	# tabela wypełniające menu paczek
	for ((i = 0; i < ${#RPMLIST[@]} ; i++)); do
		echo -e " FALSE ${RPMLIST[$i]##*/} $i ${RPMLIST[$i]}"
	done
}
# ------------------------------------------------------------------------------
menu_rpmlist_show() {
	# okno z listą paczek
	zenity --title="$TITLE" \
		--text "Paczki pochodzą wprost ze strony:\t<b>http://wiki.fedora.pl/wiki/repo</b>\nZnaleziono <b>${#RPMLIST[@]}</b> pakiety. Wybierz pakiety do pobrania:" \
		--width=1024 --height=800 \
		--list  --checklist \
		--column="zaznacz" --column "paczka" --column "nr" --column "url" \
		$(menu_rpmlist_table|sort) \
		--separator " "  --multiple \
		--print-column=3 --hide-column=3
}
# ------------------------------------------------------------------------------
menu_rpmlist(){
	# obsługa menu z paczkami
	LISTA=$(menu_rpmlist_show)
	if [ $? != 0 ] ; then
		exit 0
	elif [ ${#LISTA} == 0 ] ; then
		zenity --question --title="$TITLE" \
			--text "Nie zaznaczono żadnych pakietów!" \
			--ok-label="Lista" \
			--cancel-label="Exit"
		[ $? == 0 ] && ${FUNCNAME} || exit 0
	else
		menu_function
	fi
}
# ------------------------------------------------------------------------------
main $@
