#!/bin/bash

# manr - lista stron man z paczki rpm 
# wersja: 2010.01.22
# by borzole.one.pl
#
# użycie: 
# 		manr --help
# ------------------------------------------------------------------------------
# nazwa programu
NAME="${0##*/}"
# czcionka (E) normalna, (B) bold
E="\e[0m" 
B="\e[1;38m" 
# ------------------------------------------------------------------------------
# jakaś pomoc
usage(){
	echo -e "${B}${NAME}${E} - spis stron man wybranej paczki rpm
${B}PARAMETRY:${E}
	${B}<polecenie>${E}
		po wpisaniu dowolnego polecenia wylistuje wszystkie polecenia z paczki RPM
		a po wybraniu numeru wyświtli stronę man
		${B}UWAGA:${E} nie wszystkie polecenia posiadają stronę man
	${B}-r, --rpm <paczka>${E}	
		po wpisaniu dowolnej paczki RPM wylistuje z niej wszystkie strony man
	${B}-h, --help${E}
		wypisuje tę pomoc
${B}PRZYKŁADY:${E}
	${B}${NAME} cp${E}
	${B}${NAME} fdisk${E}
	${B}${NAME} ldd${E}
	${B}${NAME} -r shadow-utils${E}
	${B}${NAME} -r binutils${E}
	${B}${NAME} --rpm yum-utils${E}
	${B}${NAME} --rpm xorg-x11-server-utils${E}	
	${B}${NAME} --rpm xorg-x11-utils${E}	
	${B}${NAME} --rpm xdg-utils${E}			

ps. takie molochy jak GNOME, KDE zazwyczaj nie używają już stron man :)"
	exit 0
}
# ------------------------------------------------------------------------------
# rysuje linię
_linia(){
	# domyślnie jest "_", ale może rysować linię ze znaku podanego jako parametr
	znak=${1:-_}
	for i in {1..80}; do echo -en ${znak}; done ; echo
}
# ------------------------------------------------------------------------------
# gdy parametrem jest polecenie
_cmd(){
	CMD=$1
	# z tej paczki poczytamy manuale
	RPM=`rpm -qf $(which $CMD)`	
	_cli
}
# ------------------------------------------------------------------------------
# gdy parametrem jest paczka rpm
_rpm(){
	# z tej paczki poczytamy manuale
	RPM=$1
	_cli
}
# ------------------------------------------------------------------------------
# funkcja główna wyświetlająca spis stron man
_cli(){
	#~ clear
	echo -e "Miłego czytania stron man z paczki ${B} $RPM ${E}"
	_linia \~
	PS3=":: ctrl+d :: wybierz stronę man ::"
	select p in $(rpm -ql $RPM |grep bin/ | awk -F"bin/" '{printf $2 "\n"}' | sort -u ) ; do 
	# to samo ale wyświetla pełne ścieżki do poleceń (nie wiem czemu)
	# select p in `rpm -ql $RPM |grep bin/ `; do
		man $p
	done	
}
# ------------------------------------------------------------------------------
# gdy brak parametrów:
[ $# -eq 0 ] && usage
# obsługa parametrów
if [ $# -gt 0 ]; then
	case "$1" in
		--help | -h )
			usage
			;;
		--rpm | -r )
			_rpm $2
			;;
		*)
			_cmd $1
			;;
   esac
fi
# kod wyjścia ostatniego polecenia
exit $?
