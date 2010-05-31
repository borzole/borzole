#!/bin/bash

# ------------------------------------------------------------------------------
# wikirepo - pobiera paczki RPM prosto z http://wiki.fedora.pl/wiki/repo
# wersja CLI

# by borzole.one.pl
# VERSION=2010.02.25-01:06
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
BASE="$0"
BASENAME="${0##*/}"
# na potrzeby wewnętrznych funkcji
ARGS="${@}"
VERBOSE=TRUE
DEBUG=FALSE
VERSION_LOCAL=$(grep -E '^#\ *VERSION\ *='  ${0} | cut -d\= -f2)
PS3=':: ctrl+d :: wybierz nr:: '
# ------------------------------------------------------------------------------
# czcionka: (N)ORMAL, (X)BOLD, (R)ED, (G)REEN, (B)LUE
N="\e[0m"
X="\e[1;38m"
r="\e[0;31m"
R="\e[1;31m"
g="\e[0;32m"
G="\e[1;32m"
b="\e[0;34m"
B="\e[1;34m"
# ------------------------------------------------------------------------------
# domyślny folder pobierania
DIR=$HOME
# ------------------------------------------------------------------------------
get_links(){
	# zwraca listę linków do paczek rpm oddzieloną znakiem nowego wiersza
	# informacja jest wyłuskiwana z tej strony
	local thisURL="http://wiki.fedora.pl/index.php?title=repo&action=raw&ctype=text/css"
	# metoda:
	#	- sed: każdą "spację" i "[" zamienić na znak nowej linii
	#		( składnia linków na wiki wymusza tę spację i nawias )
	#	- grep: wylapać tylko linie zaczynające się od:
	#			http://
	#			https://
	#			ftp://
	#			i kończące się na ".rpm"
	#	- sort: posortowanie i usunięcie pustych linii
	curl -s "$thisURL"  \
		| sed -e 's/\ \ */\n/g ; s/\[/\n/g' \
		| grep -E '^(http|https|ftp)\:\/\/.*\.rpm$' \
		| sort -u
}
# ------------------------------------------------------------------------------
set_rpmlist(){
	# załaduj listę linków do jednej tabeli
	unset RPMLIST
	RPMLIST=( $(get_links))
}
# ------------------------------------------------------------------------------
wymaga(){
	# sprawdza zależności skryptu
	# np.
	# 		wymaga wget zenity notify-send
	for apps in "$@" ; do
		which ${apps} >/dev/null 2>&1
		if [ $? != 0 ] ; then
			echo -e "${R}[ ERROR ] Nie znaleziono programu \"$apps\""
			echo -e "${G}Spróbuj zainstalować:"
			echo -e "\tsu -c'yum install $apps'"
			echo -e "a jeśli zawiedzie, to spróbuj odnaleźć paczkę dostarczającą wymaganą zależność:"
			echo -e "\tsu -c'yum provides \\*bin/$apps'"
			exit 1;
		fi
	done
}
# ------------------------------------------------------------------------------
press_any_key(){
	echo -e "${G}Naciśnij dowolny klawisz${N}"
	local x=''
	read -sn 1 x
	return $?
}
# ------------------------------------------------------------------------------
UPDATE_URL="http://dl.dropbox.com/u/409786/pub/bin/wikirepo"
# ------------------------------------------------------------------------------
main(){
	wymaga wget curl
	echo -e "Sprawdzam aktualizacje..."
	check_script_update
	echo -e "Pobieram listę paczek..."
	set_rpmlist
	ui
}
# ------------------------------------------------------------------------------
about(){
	echo -e ":: ${B}wikirepo ver.$VERSION_LOCAL${N} :: paczki RPM prosto z http://wiki.fedora.pl/wiki/repo"
	echo -e ":: skrypt by ${G}borzole${N}\n"
}
# ------------------------------------------------------------------------------
ui(){
	about
	show_menu_rpmlist
}
# ------------------------------------------------------------------------------
check_script_update(){
	UPDATE_FILE=$(mktemp)
	trap "rm -f $UPDATE_FILE 2>/dev/null" EXIT
	curl -s "$UPDATE_URL"  > $UPDATE_FILE
	# jeśli coś przerwie skrypt to usuń ten plik

	VERSION_LAST=$(grep -E '^#\ *VERSION\ *='  $UPDATE_FILE | cut -d\= -f2)

	[ "$VERSION_LOCAL" != "$VERSION_LAST" ] && show_script_update
}
# ------------------------------------------------------------------------------
show_script_update(){
	echo -e "${R}Dostępna jest aktualizacja${N}"
	echo -e "$VERSION_LOCAL lokalna wersja"
	echo -e "${B}$VERSION_LAST${N} ostatnia wersja"
	mv $UPDATE_FILE /tmp/wikirepo_ostatnia_wersja
	echo -e "aktualny skrypt został zapisany tu: ${B}/tmp/wikirepo_ostatnia_wersja${B}"
	press_any_key
}
# ------------------------------------------------------------------------------
show_menu_rpmlist(){
	select opt in "${RPMLIST[@]##*/}" ; do
		let "REPLY--"
		RPMNR=$REPLY
		echo
		echo -e ":: ${R}pakiet${N} = ${B}${RPMLIST[$RPMNR]##*/}${N}"
		echo -e ":: ${R}url${N}:: ${G}${RPMLIST[$RPMNR]}${N}"
		echo
		# submenu
		show_menu_function
	done
}
# ------------------------------------------------------------------------------
set_dir(){
	echo -e "Wybierz scieżką dla folderu pobierania\n$DIR"
	TMP="$DIR"
	read DIR
	if [ ${#DIR} == 0 ] ; then
		DIR="$TMP"
		echo -e "${R}SKASOWAŁEŚ !!${B} $DIR\n${G}odtworzony z kopi${N}"
		set_dir
	else
		echo -e "${R}Nowy folder:${B} $DIR\n${G}ale w menu się nie odświerza :)${N}"
	fi
}
# ------------------------------------------------------------------------------
set_opt(){
	#ciekawy sposób na automatyczne numerowanie tej tablicy
	fun[${#fun[*]}]="$1"
	opis[${#opis[*]}]="$2"
}
# ------------------------------------------------------------------------------
unset_opt(){
	unset fun
	unset opis
}
# ------------------------------------------------------------------------------
set_menu_function(){
	unset_opt
	set_opt download "Pobierz pakiet: ${RPMLIST[$RPMNR]##*/}"
	set_opt "download -x" "Pobierz pakiet: z wymuszeniem tworzenia katalogów"
	set_opt set_dir "Zmień folder pobierania: $DIR"
}
# ------------------------------------------------------------------------------
show_menu_function(){
	set_menu_function
	select m in "${opis[@]}" ; do
		echo
		echo -e "${R}$REPLY) $m${N}"
		echo
		let "REPLY--"
		${fun[$REPLY]}
	done
}
# ------------------------------------------------------------------------------
download(){
	mkdir -p "$DIR" 2>/dev/null
	wget -P "$DIR" "$1" "${RPMLIST[${RPMNR}]}"
}
# ------------------------------------------------------------------------------
# uruchomienie funkcji głównej lub z parametru
if [ -n "$1" ] ; then
	"${ARGS}"
else
	main
fi
# wyjście z przekazaniem kodu wyjścia ostatniego polecenia
exit $?
# ------------------------------------------------------------------------------
