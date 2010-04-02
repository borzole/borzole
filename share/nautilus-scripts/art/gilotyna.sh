#!/bin/bash

# gilotyna.sh -- sieka plakat (obraz) na części
#
# wymaga:           ImageMagick, zenity
# licencja:         GPLv2+
# autor:            Łukasz Jędral, borzole@gmail.com, http://jedral.one.pl
# ------------------------------------------------------------------------------
VERSION=2010.04.02-20:19
# ------------------------------------------------------------------------------
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
# parametry globalne
declare ERROR
declare FILE
declare NAME
declare EXT
# -i: integer
declare -i WIDTH
declare -i HEIGHT
declare -i COL
declare -i ROW
declare -i COUNT
# ------------------------------------------------------------------------------
usage(){
	echo -e "  ${0##*/} -- sieka plakat (obraz) na części
Info:
  Skrypt sieka plakat (obraz) na części, aby łatwo można było go wydrukować.
    * dokładność cięcia co do piksela
    * domyślnie działa jako aplikacją z GUI (w tym jako nautilus-scripts)
    * można uruchomić jako aplikację z CLI (całkowicie bez X-ów)
Użycie:
  ${0##*/} [OPCJA...]
  * wrzuć skrypt do folderu $HOME/.gnome2/nautilus-scripts/
    i masz go w GNOME pod myszą
  * wrzuć do folderu /usr/local/bin/
    i uruchomiaj z GUI lub z CLI
Opcje:
  -c, --cli  <plik> <col> <row>
                    Command-Line Interface np.:
                        $ ${0##*/} -c plik.png 3 4     # sieka 3x4
                        $ ${0##*/} --cli plik.png 3    # sieka 3x3
  -V, --version     Wyświetl informacje o wersji i zakończ program
  -h, --help        Wyświetla pomoc

Wymaga:             ImageMagick, zenity
Licencja:           GPLv2+
Autor:              Łukasz Jędral, borzole@gmail.com, http://jedral.one.pl
"
}
# ------------------------------------------------------------------------------
# API
# ------------------------------------------------------------------------------
error(){
	# każdy błąd jest pokolorowany i wysłany na stderr
	echo -e "\n[ $(date +%Y.%m.%d-%H:%M:%S) ][ ${0##*/} ] \n$@" >&2
	exit 1
}
# ------------------------------------------------------------------------------
set_file(){
	# ustaw plik i sprawdź jego poprawność

	# TEST: parametry funkcji
	ERROR="${FUNCNAME}: Brak parametru: nazwa_pliku "
	[[ $# != 1 ]] && error "$ERROR"

	FILE="$1"

	# TEST: czy to rzeczywiście plik 
	ERROR="${FUNCNAME}: Nie ma takiego pliku: \n$FILE"
	[[ ! -f $FILE ]] && error "$ERROR"
	# TEST: czy plik jest obrazek
	ERROR="${FUNCNAME}: Plik nie jest obrazem: \n$FILE"
	file -b --mime-type "${FILE}" | grep '^image/' >/dev/null || error "$ERROR"
	# TEST: wykluczenie obrazów SVG
	ERROR="${FUNCNAME}: Nie można pociąć obrazu typu SVG: \n$FILE"
	file -b --mime-type "${FILE}" | grep '^image/svg+xml' >/dev/null && error "$ERROR"

	# nazwa pliku bez rozszerzenia
	NAME="${FILE%.*}"
	# rozszerzenie pliku
	[[ -n ${FILE##*.} ]] && EXT=".${FILE##*.}" || EXT=""
}
# ------------------------------------------------------------------------------
get_geometry(){
	# wymiary obrazka
	ERROR="${FUNCNAME}: Nie udało się pobrać wymirów obrazka: \n$FILE"
	 WIDTH=$(identify -format "%[fx:w]" "$FILE") || error "$ERROR"
	HEIGHT=$(identify -format "%[fx:h]" "$FILE") || error "$ERROR"
}
# ------------------------------------------------------------------------------
set_table(){
	# Funkcja ustawia ilość kolumn i wierszy cięcia
	
	# TEST: czy pole COL (1 parametr) jest puste (ROW może być puste)
	ERROR="${FUNCNAME}: Nie podano na ile wierszy i kolumn pociąć obrazek"
	[[ $# -eq 0 ]] && error "$ERROR"

	# TEST: format wprowadzonych danych
	ERROR="${FUNCNAME}: Parametr WIERSZE/KOLUMNY musi być liczbą całkowitą większą od zera"
	grep -E '[^0-9 ]' <<<$@ >/dev/null && error "$ERROR"

	# ilość kolumn i wierszy cięcia
	COL=$1
	# jeśli nie podano ilości wierszy, to jest taka sama jak ilość kolumn
	[[ $# -eq 1 ]] && ROW=$COL || ROW="$2"
	# TEST: różne od zera 
	[[ $COL -eq 0 ]] && error "$ERROR"
	[[ $ROW -eq 0 ]] && error "$ERROR"
	COUNT=$((${COL}*${ROW}))
}
# ------------------------------------------------------------------------------
crop(){
	# po ustawieniu wszystkiego, następuje cięcie!
	#@TODO: sprawdzanie czy te wszystkie parametry są ustawione?!
	local -i w=$((${WIDTH}/${COL}))
	local -i h=$((${HEIGHT}/${ROW}))
	local -i x
	local -i y
	local FILE_OUT
	for (( j=1 ; j <= ${ROW} ; j++ )) ; do
		y=$(( (${j}-1)*${h} ))                          # offset y
		for (( i=1 ; i <= ${COL} ; i++ )) ; do
			x=$(( (${i}-1)*${w} ))                      # offset x
			FILE_OUT="${NAME}-y${j}x${i}${EXT}"
			echo -ne "$(( ((${j}-1)*${COL}) + ${i} ))"  # nr pliku
			echo -e "|$FILE_OUT"                        # nazwa pliku
			convert -crop ${w}x${h}+${x}+${y} +repage "$FILE" "$FILE_OUT"
		done
	done
}
# ------------------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------------------
cli_main(){
	#~ exec 3>&2 # przekierowanie błędów z 3 na domyślny deskryptor 2
	[[ $# -lt 2 ]] && { usage; exit 1; }
	set_file "$1"
	get_geometry
	set_table ${@:2}

	# progress_cli
	# ustawienie separatora pola IFS
	IFS_OLD="$IFS"
	IFS="|"
	# każda linia wychodząca z funkcji "crop" zostanie podzielona na pola i sformatowana
	local LINE
	local f1
	local f2
	crop | while read -r LINE ; do
		read -r f1 f2 <<<"$LINE"
		echo -e "$f1/${COUNT} | Generuję plik: $f2 "
	done
	# przywrócenie IFS
	IFS="$IFS_OLD"
}
# ------------------------------------------------------------------------------
# GUI
# ------------------------------------------------------------------------------
gui_error(){
	local LINE
	local ALL=""              # status, czy była wiadomość błędu
	local ERROR="<b>Wystąpił błąd!</b>\n"
	while read -r LINE ; do
		ALL+=$LINE
		ERROR+="$LINE\n"
	done
	[[ -n $ALL ]] && zenity --error --title="${0##*/}" --width=200 --text="$ERROR" 2>/dev/null
}
# ------------------------------------------------------------------------------
gui_menu(){
	zenity --title="${0##*/}"  --entry  --entry-text "2 2" \
		--text "Jak posiekać plakat?\n
plik: 		$FILE
wymiary: 	$WIDTH x $HEIGHT\n
wprowadź: 	KOLUMNY  WIERSZE (lub tylko jeden wymiar)" 2>/dev/null
}
# ------------------------------------------------------------------------------
gui_get_file(){
	zenity --file-selection --title="Wybierz plik: plakat do pocięcia" 2>/dev/null
}
# ------------------------------------------------------------------------------
gui_main(){
	exec 2> >(gui_error) # przekierowanie błędów
	# podaj plik jako parametr w konsoli lub z zaznaczenia w nautilus-scripts
	# jeśli plik nie został podany jako parametr to wyświetli się okienko
	local FILE
	if [[ -n $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS ]] ; then
		FILE="${NAUTILUS_SCRIPT_SELECTED_FILE_PATHS%?}"
	else
		FILE=$(gui_get_file) || exit 0
	fi
	set_file "$FILE"
	get_geometry
	# ustawienie ilości kolumn i wierszy
	local ENTRY_RAW
	ENTRY_RAW=$(gui_menu) || exit 0
	local COL=$(echo $ENTRY_RAW | awk '{ print $1}')
	local ROW=$(echo $ENTRY_RAW | awk '{ print $2}')
	set_table $COL $ROW

	# progress_gui
	# ustawienie separatora pola IFS
	IFS_OLD="$IFS"
	IFS="|"
	# każda linia wychodząca z funkcji "crop"
	# zostanie podzielona na pola i sformatowana
	local LINE
	local f1
	local f2
	exec 4> >(zenity --title="${0##*/}" --width=300 --progress --auto-close --auto-kill 2>/dev/null )
	crop | while read -r LINE ; do
		read -r f1 f2 <<<"$LINE"
		bar=$(( ( 100 * ${f1}) / ${COUNT} ))
		echo -e "# $bar % | $f1/${COUNT} | Generuję plik: $f2 " >&4
		echo "$bar" >&4
	done
	# zamknięcie paska postępu
	echo "100" >&4
	exec 4>&-
	# przywrócenie IFS
	IFS="$IFS_OLD"
}
# ------------------------------------------------------------------------------
# MAIN
# ------------------------------------------------------------------------------
init(){
	# CLI: jeśli są parametry
	while [ $# != 0 ] ; do
		case "$1" in
			-c|--cli)      shift; cli_main $@     ; break  ;;
			-V|--version)  echo $VERSION          ; exit 0 ;;
			-h|--help)     usage                  ; exit 0 ;;
			*)             usage                  ; exit 1 ;;
		esac
	done
}
# ------------------------------------------------------------------------------
main(){
	# GUI: przy braku parametrów
	[[ $# == 0 ]] || [[ -n $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS ]] && gui_main || init $@

	#@TODO: LOG=$HOME/.xsession-errors # [[ -n $LOG ]] && exec 2> >(log_error) # przekierowanie błędów
}
# ------------------------------------------------------------------------------
main $@
