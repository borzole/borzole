#!/bin/bash
#
# by borzole ( jedral.one.pl )
VERSION=2010.01.12-14.17
# ------------------------------------------------------------------------------
# dp - sprawdza komentarze w dobreprogramy.pl
# ------------------------------------------------------------------------------
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
# plik bazy danych o komenarzach
FILE_DB=~/.dp.db
# kontrola opcji, czy ustawiono sposób powiadomienia
IS_MSG_SET=FALSE
# ------------------------------------------------------------------------------
usage(){ 
	echo -e "${B}$BASENAME${N} - sprawdza komentarze w newsach/blogach z http://www.dobreprogramy.pl
${G}UŻYCIE:${N}
	${X}+ [ url ]${N}
		dodanie strony do obserwowanych np:
		$BASENAME + http://www.dobreprogramy.pl/Gmail-w-wersji-offline-wychodzi-z-bety,Aktualnosc,15668.html
	${X}-, --${N}
		menu do usuwania stron z bazy
	${X}-l, --list${N}
		lista obserwowanych stron
	${X}-t, --terminal${N}
		sprawdzenie nowych komentarzy i wyświetlenie wyników w terminalu
	${X}-m, --mail [ e-mail ]${N}
		wysłanie wyników na maila
	${X}-q, --quiet${N}		
		wyświetlaj minimum komunikatów
	${X}-h, --help${N}
		wyświetlenie pomocy i wyjście
	${X}-v, --version${N}
		wersja: ${VERSION}
${G}PRZYKŁAD:${N}
	powiadomienie na maila i w terminalu bez komunikatów
	$BASENAME -t --mail mymail@sth.com -q 
"
}
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
verbose(){
	if [ "$VERBOSE" == "TRUE" ] ; then	
		echo -e "$@"
	fi
}
# ------------------------------------------------------------------------------
help(){
	echo -e "${G}Opcje pomocy:${N}
	${X}$BASENAME${N} -h, --help"
	exit 0
}
# ------------------------------------------------------------------------------
yes_or_no(){
	# @parametr: krótki opis wyboru
	# @return: 0|1
	# np:	yesno "Zainstalować nowy kernel?"
	echo -e "${R}[ yes/no ]${N} $@"
	local x=''
	while true ; do
		read x
		case "$x" in 
			[tT] | [tT][aA][kK] | [yY] | [yY][eE][sS] )
				return 0 ;;
			[nN] | [nN][iI][eE] | [nN][oO] )
				return 1 ;;
			* )
				echo " Wybierz yes/no" ;;
		esac
	done
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
msg_terminal(){		
	verbose "${G}[ $BASENAME ] wysyłam na terminal${N}"
	# lokalnie
	echo "$GET_COMMENT"
}
# ------------------------------------------------------------------------------
msg_mail(){
	wymaga mutt
	verbose "${G}[ $BASENAME ] wysyłam e-mail do "$MYMAIL"${N}"
	# email
	echo "$GET_COMMENT" | mutt -s "[ $BASENAME ] ${url##*/}"  ${MYMAIL} 
}			
# ------------------------------------------------------------------------------
get_nr(){
	awk -F"<div class=\"item\" id=\"komentarz_" ' { print $2 }' $FILE_TMP	\
		| cut -d\" -f1 \
		| uniq -u
}
# ------------------------------------------------------------------------------
set_nrlist(){
	unset NRLIST
	NRLIST=($(get_nr))
}
# ------------------------------------------------------------------------------
check_diff(){
	unset NRLISTNEW
	
	for nr in "${NRLIST[@]}" ; do
		grep "$url" $FILE_DB | cut -d\| -f2 | grep $nr >/dev/null 2>&1
		if [ $? != 0 ] ; then
			NRLISTNEW["${#NRLISTNEW[@]}"]=$nr
		fi
	done
}
# ------------------------------------------------------------------------------
get_comment(){
	for nr in "${NRLISTNEW[@]}" ; do
		echo -e "--------------------------------------------------------------------------------"
		echo -e "[ ${url}#komentarz_${nr} ]"
		COMMENT=$(sed -n -e "/komentarz_$nr/,/commentText/p" $FILE_TMP )
		# nick
		echo -n $(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\> -f3 | cut -d\< -f1) 
		echo -n $(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\> -f4 | cut -d\< -f1) 
		
		# data
		echo -n " [ "$(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\| -f2 | cut -d\< -f1) " ] "
		# nr komentarza
		echo -e "#" $(echo "$COMMENT" | grep "class=\"numer\"" | cut -d\# -f2- | cut -d\< -f1)
		# text
		echo "$COMMENT" | grep "commentText" | cut -d\> -f2- | sed -e 's/<br\ *\/>/\n/g'  | sed -e 's/<\/p>/\n\t/g'
	done
}
# ------------------------------------------------------------------------------
minus_url(){
	grep -v "$url" $FILE_DB >$FILE_TMP 2>/dev/null
	cp $FILE_TMP $FILE_DB 2>/dev/null
}
# ------------------------------------------------------------------------------
minus_url_select(){
	PS3=':: ctrl+d :: usuń nr:: '
	FILE_TMP=$(mktemp)
	trap "rm -f $FILE_TMP" EXIT
	select url in $(list_url) ; do
		minus_url
		break
	done
	
	yes_or_no "usunąć jeszcze coś?"
	[ $? == 0 ] && minus_url_select
}	
# ------------------------------------------------------------------------------
add_url(){
	echo -e "$url | ${NRLIST[@]}" >>$FILE_DB 2>/dev/null
	sort -o $FILE_DB $FILE_DB
}
# ------------------------------------------------------------------------------
list_url(){
	cat $FILE_DB | cut -d\| -f1
}
# ------------------------------------------------------------------------------
save_nrlist(){
	minus_url
	add_url
}
# ------------------------------------------------------------------------------
main(){
	# czy istnieje plik bazy
	[ ! -f $FILE_DB ] && help 
	# czy ustawiono sposób powiadomienia
	[ "$IS_MSG_SET" != "TRUE" ] && help
	# tymczasowy plik na obrabianą stronę z dobreprogramy.pl
	FILE_TMP=$(mktemp)
	# wykonaj przy wyjściu
	trap "rm -f $FILE_TMP" EXIT
	# dla każdej strony z bazy wykonaj:
	for url in $(grep dobreprogramy.pl $FILE_DB | cut -d'|' -f1) ; do
		verbose "${B}[ $BASENAME ]${N} sprawdzam: ${url##*/} \c"
		curl -s "$url" >$FILE_TMP 2>/dev/null
		set_nrlist
		check_diff
		# powiadomienie
		if [ ${#NRLISTNEW[@]} != 0 ] ; then
			verbose "\n${R}[ $BASENAME ] zmiany: ${url##*/}${N}"
			GET_COMMENT=$(get_comment)
			[ "$TERMINAL" == "TRUE" ] && msg_terminal
			[ "$EMAIL" == "TRUE" ] && msg_mail			
		else
			verbose "${G} nic nowego${N}"
		fi
		save_nrlist
	done	
}
# ------------------------------------------------------------------------------
menu(){
	if [ $# = 0 ] ; then
		# po obsłużeniu wszystkich opcji przechodzimy do głównej funkcji
		main
	else
		case "$1" in
			+)
				# dodaj url do obserwowanych
				shift
				url="$@"
				add_url
				verbose "${B}dodano do bazy: ${N}$@"
				exit $?
				;;
			-|--)
				# usuń url z obserwowanych
				verbose "${R}usuwanie z bazy: ${N}"
				minus_url_select
				exit $?
				;;
			-l|--list)
				# pokaż listę stron w bazie
				list_url
				;;
			# opcje powiadomienia
			-t|--terminal)
				IS_MSG_SET=TRUE
				TERMINAL=TRUE
				shift ; menu "$@"
				;;
			-m|--email)
				IS_MSG_SET=TRUE
				EMAIL=TRUE
				MYMAIL=$2
				shift 2 ; menu "$@"
				;;
			# opcje ogólne
			-h|--help)
				usage
				exit $?
				;;
			-q|--quiet)
				VERBOSE=FALSE
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
