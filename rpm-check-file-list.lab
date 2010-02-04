#!/bin/bash
#
# by borzole ( jedral.one.pl )
VERSION=2010.01.13-17.27
# ------------------------------------------------------------------------------
# rpm-check-file-list -  - skanuje i uzupełnia brakujące pliki na podstawie bazy RPM
# ------------------------------------------------------------------------------
BASE="$0"
NAME="${0##*/}"
ARGS="${@}"
VERBOSE=TRUE
DEBUG=FALSE
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
usage(){ 
	echo -e "${B}$NAME${N} - skanuje i uzupełnia brakujące pliki na podstawie bazy RPM 
	
	Skrypt nie naprawia uszkodzonych plików/linków, a jedynie przeinstalowuje paczki.
	Reinstalacja nie jest domyślna, a uruchomienia bez prarametrów jedynie wyświetla info o stanie.
${G}UŻYCIE:${N}
	${X}yum${N}
		wykonaj reinstalację pakietu, gdy nieznaleziono pliku
	${X}-y, --yes${N}
		automatyczne potwierdzenie operacji typu: 	yum reinstall -y pakiet.rpm
	${X}-l, --log [ file ]${N}
		loguje zdarzenia do pliku
	${X}-q, --quiet${N}		
		wyświetlaj minimum komunikatów
	${X}-h, --help${N}
		wyświetlenie pomocy i wyjście
	${X}-v, --version${N}
		wersja: ${VERSION}
${G}PRZYKŁAD:${N}
	${B}$NAME${N} --log /tmp/czego_brak.log
	${B}$NAME${N} yum -q
	${B}$NAME${N} yum -y --log /tmp/czego_brak.log"
	autor
}
# ------------------------------------------------------------------------------
autor(){
	echo -e "${G}AUTOR:${N}
	Łukasz Jędral ( borzole )
	borzole@gmail.com
	http://jedral.one.pl	"
}
# ------------------------------------------------------------------------------
help(){
	echo -e "${G}Opcje pomocy:${N}
	${X}$NAME${N} -h, --help"
	exit 0
}
# ------------------------------------------------------------------------------
verbose(){
	if [ "$VERBOSE" == "TRUE" ] ; then	
		echo -e "$@"
	fi
}
# ------------------------------------------------------------------------------
logfile(){
	# spr. czy podano ścieżkę do pliku w istniejącym katalogu
	if [ "$1" != "" ] && [ -d "${1%/*}" ] ; then
		LOG="$1"
	else
		echo "Błąd: parametr '--log' wymaga podania ścieżki do pliku w istniejącym katalogu"
		exit 1
	fi
}
# ------------------------------------------------------------------------------
requires(){
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
is_root(){
	# tylko root może uruchomić ten skrypt
	if [ $(whoami) != root ] ; then
		echo "brak dostępu : musisz mieć prawa 'root' ( su - , sudo ) "
		exit 0
	fi
}
# ------------------------------------------------------------------------------
run(){
	# (robot) ładny bezpiecznik do skryptów składających się z samych funkcji
	if [ -n "$1" ] ; then 
		if [ "$1" == "$" ] ; then 
			# uruchom dowolną funkcję ze skryptu pomijając menu
			# np:	skrypt.sh $ funkcja2 
			shift
			"$@"
		else 
			# uruchom 
			menu "$@"
		fi
	else
		# przy braku parametrów
		main
	fi
}
# ------------------------------------------------------------------------------
main(){
	# zależności
	requires rpm yum
	# czy user ma prawo uruchomić skrypt
	is_root
	
	verbose " -- ładuję listę paczek"
	RPMQA=$(rpm -qa)
	ILOSC=$(echo $RPMQA | wc -w)
	verbose " -- znaleziono $ILOSC pakietów"
	# licznik
	NR=0
	# wykonaj dla każdej paczki w systemie
	for paczka in ${RPMQA} ; do
		let NR=( $NR+1 )
		verbose "sprawdzam (${NR}/${ILOSC}) :  $paczka"
		# wykonaj dla każdego pliku w paczce
		for plik in `rpm -ql $paczka | grep -v '(' ` ; do
			# sprawdź czy plik/katalog istnieje
			if [ ! -f $plik ] && [ ! -d $plik ] ; then 
				# objekt nieistnieje lub szczegóły o popsuciu :)
				file $plik
				verbose " -- reinstall : $paczka"
				# reinstalacja paczki
				if [ "$YUM_REINSTALL" == "TRUE" ] ; then
					yum $YUM_QUIET reinstall $YUM_YES $paczka
				fi
				# log zdarzenia
				if [ "$LOG" != "" ] ; then
					echo "$paczka : $plik" >> $LOG
				fi					
				
				# przerwanie pętli, by nie sprawdzać reszty pakietów z tej paczki
				break
			fi
		done
	done
}
# ------------------------------------------------------------------------------
menu(){
	if [ $# == 0 ] ; then
		# po obsłużeniu wszystkich opcji przechodzimy do głównej funkcji
		main
	else
		case "$1" in
			yum)
				YUM_REINSTALL=TRUE
				shift ; menu "$@"
				;;
			-y|--yes)
				YUM_YES="-y"
				shift ; menu "$@"
				;;
			-l|--log)
				logfile "$2"
				shift 2 ; menu "$@"
				;;
			# opcje ogólne
			-h|--help)
				usage
				exit 0
				;;
			-q|--quiet)
				VERBOSE=FALSE
				YUM_QUIET="-q"
				shift ; menu "$@"
				;;
			-v|--version)
				echo $VERSION
				exit 0
				;;
			*)
				help
				;;
		esac
	fi
}
# uruchomienie
run "$@"
# ------------------------------------------------------------------------------
