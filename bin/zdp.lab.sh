#!/bin/bash
#
# To nie działa, choć działało przed zmianami w kodzie DP, zostawię dla ciekawostki
#
# by jedral.one.pl
# VERSION = 2009.12.20 17:54
# ------------------------------------------------------------------------------
# zdp - czytnik komentarzy z dobreprogramy.pl
#
# dodać do autostartu (uruchomić w tle):
#	zdp &
# ------------------------------------------------------------------------------
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
TITLE="Czytnik komentarzy DP" 
FILEDB=~/.zdp.sqlite
# ikona zminimalizowanego czytnika
ICON=/usr/share/pixmaps/gnome-irc.png
# ikona w czasie sprawdzania nowych komentarzy
ICON_CHECK=/usr/share/icons/gnome/32x32/actions/gtk-refresh.png
# ------------------------------------------------------------------------------
verbose(){
	if [ "$VERBOSE" == "TRUE" ] ; then	
		echo -e "$@"
	fi
}
# ------------------------------------------------------------------------------
debug(){
	if [ "$DEBUG" == "TRUE" ] ; then	
		echo -e "${R}[ DEBUG ]${B} $@${N}"
	fi
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
db_init(){
	
	sqlite3 $FILEDB 'VACUUM'
	
	sqlite3 $FILEDB <<_create_
CREATE TABLE IF NOT EXISTS "komentarze" (
	"id_www" INTEGER NOT NULL , 
	"nr" INTEGER NOT NULL , 
	"nr_local" INTEGER NOT NULL , 
	"autor" TEXT NOT NULL , 
	"data" TEXT NOT NULL  , 
	"tresc" TEXT NOT NULL ,
	"status" TEXT 
	);
_create_
	sqlite3 $FILEDB <<_create_
CREATE TABLE IF NOT EXISTS "www" (
	"id_www" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
	"adres" TEXT NOT NULL  check(typeof("adres") = 'text') 
	);
_create_
}
# ------------------------------------------------------------------------------
id_www(){
	sqlite3 $FILEDB <<_create_
SELECT id_www
	FROM www
	WHERE adres = '$1';
_create_
}
# ------------------------------------------------------------------------------
db_add_url(){
	isInDB=$( sqlite3 $FILEDB <<_create_
SELECT adres
	FROM www
	WHERE adres = '$1';
_create_
)
	if [ "$isInDB" == '' ] ; then
	sqlite3 $FILEDB <<_create_
INSERT INTO www (adres) VALUES ('$1');
_create_
		zenity --info --title "$TITLE" --text "Dodano do bazy adres:\n$1"
	else
		zenity --warning --title "$TITLE" --text "Już jest w bazie adres:\n$1"
	fi
}
# ------------------------------------------------------------------------------
db_add_comment(){
	# db_add_comment adres nr nr_local autor data tresc
	ID_WWW=$(id_www "$1")
	sqlite3 $FILEDB <<_create_
INSERT INTO "komentarze" (id_www, nr, nr_local, autor, data, tresc, status) 
	VALUES ('$ID_WWW','$2','$3','$4','$5','$6','$7');
_create_
}
# ------------------------------------------------------------------------------
db_is_comment_exist(){
	# db_add_comment adres nr nr_local autor data tresc
	ID_WWW=$( sqlite3 $FILEDB <<_create_
SELECT nr
	FROM komentarze
	WHERE nr = '$1' ;
_create_
)
	if [ "$ID_WWW" == "$1" ] ; then
		return 0
	else
		return 1
	fi
}
# ------------------------------------------------------------------------------
db_minus_url(){
	
	isInDB=$( sqlite3 $FILEDB <<_create_
SELECT adres
	FROM www
	WHERE adres = '$1';
_create_
)
	
	if [ "$isInDB" != '' ] ; then
		ID_WWW=$(id_www "$1")
		zenity --question --title "$TITLE" --text "Czy aby napewno usunąć z bazy adres:\n$1"
		if [ $? == 0 ] ; then
			# najpierw tablica komentarzy (bo ID)
			sqlite3 $FILEDB <<_create_
DELETE FROM komentarze
	WHERE id_www = '$ID_WWW';
_create_
			# teraz właściwa
			sqlite3 $FILEDB <<_create_
DELETE FROM www
	WHERE adres = '$1';
_create_
		zenity --info --title "$TITLE" --text "Usunięto z bazy adres:\n$1"
		fi
	fi
}
# ------------------------------------------------------------------------------
db_get_all_comment_nr(){
	sqlite3 $FILEDB <<_create_
SELECT nr
	FROM komentarze 
	WHERE status = 'readed';
_create_
}
# ------------------------------------------------------------------------------
db_get_all_uncomment_nr(){
	sqlite3 $FILEDB <<_create_
SELECT nr
	FROM komentarze 
	WHERE status = 'unreaded';
_create_
}
# ------------------------------------------------------------------------------
db_get_comment_nr_from_url(){
	ID_WWW=$(id_www "$1")
	sqlite3 $FILEDB <<_create_
SELECT nr
	FROM komentarze 
	WHERE id_www = '$ID_WWW' AND status = 'unreaded';
_create_
}
# ------------------------------------------------------------------------------
db_get_from_nr(){
	sqlite3 $FILEDB <<_create_
SELECT $2
	FROM komentarze
	WHERE nr = '$1';
_create_
}
# ------------------------------------------------------------------------------
db_set_readed(){
	sqlite3 $FILEDB <<_create_
UPDATE komentarze
	SET tresc = 'null'
	WHERE nr = '$1';
_create_
	sqlite3 $FILEDB <<_create_
UPDATE komentarze
	SET status = 'readed'
	WHERE nr = '$1';
_create_
}
# ------------------------------------------------------------------------------
db_get_all_url(){
	sqlite3 $FILEDB <<_create_
SELECT adres
	FROM www ;
_create_
}
# ------------------------------------------------------------------------------
add_url(){
	ADD_URL=$(zenity	--title="$TITLE" --width=250 --text="Dodaj adress:" --entry --entry-text "http://")
	if [ "$ADD_URL" != '' ] ; then
		if [ "$ADD_URL" != "http://" ] ; then
			db_add_url "$ADD_URL"
		fi
	fi
	show_menu
}
# ------------------------------------------------------------------------------
minus_url(){
	TEXT_LIST_URL="<span color=\"#FF0000\"><b>Wymarz świadectwo istnienia tej strony ;P</b></span>"
	durl=$(list_url)
	if [ $? == 0 ] ; then
		# oj! potrzebny ten warunek
		if [ "$durl" != '' ] ; then
			db_minus_url "$durl"
			minus_url
		fi
	fi
	show_menu
}
# ------------------------------------------------------------------------------
list_url(){
	zenity --title="$TITLE"  --text "$TEXT_LIST_URL" \
		--list --width=600 --height=300 \
		--column " -- by jedral.one.pl -- " --column="ile" \
		$( for www in $(db_get_all_url) ; do echo -e "$www	$(db_get_comment_nr_from_url $www | wc -l)" ; done ) \
		--separator=" " --print-column=1
}
# ------------------------------------------------------------------------------
list_comment_format(){
	for nr in $(db_get_comment_nr_from_url "$1") ; do  
		autor=$( db_get_from_nr $nr autor | sed -e 's:\ \ *:\_:g')
		data=$( db_get_from_nr $nr data | sed -e 's:^\ *::g' | sed -e 's:\ \ *:\.:g')
		nr_local=$( db_get_from_nr $nr nr_local)
		echo -e "$nr	$nr_local	$autor	$data "
	done 
}
# ------------------------------------------------------------------------------
list_comment(){
	zenity --title="$TITLE"  --text "Komentrze na stronie:
<span color=\"#1E90FF\"><b>$rurl</b></span>" \
		--list  --width=400 --height=400 \
		--column " nr " --column="#nr" --column=" autor " --column=" data " \
		$( list_comment_format $1) \
		--separator=" " --print-column=1 --hide-column=1
}
# ------------------------------------------------------------------------------
min_icon(){
	zenity --notification --window-icon "$ICON" --text "$TITLE"
	[ $? == 0 ] && show_menu
}
# ------------------------------------------------------------------------------
show_comment(){
	TEXT_COMMENT="#$( db_get_from_nr $cnr nr_local) | $( db_get_from_nr $cnr autor) | $( db_get_from_nr $cnr data) 
$( db_get_from_nr $cnr tresc)
 ------------------------------------------------------------------------------
[ OK ] / <ENTER> - usuń jako przeczytany 
<ESC> - zostaw nieprzeczytany"
	echo "$TEXT_COMMENT" | zenity --text-info --title="$rurl"  --width=500 --height=350 
	[ $? == 0 ] && db_set_readed $cnr 	
	show_comment_list	
}
# ------------------------------------------------------------------------------
show_comment_list(){
	cnr=$(list_comment "$rurl")
	[ $? == 0 ] && show_comment || index_com
}
# ------------------------------------------------------------------------------
index_com(){
	TEXT_LIST_URL="Wybierz stronę do przeczytania"
	rurl=$(list_url)
	[ $? == 0 ] && show_comment_list || show_menu
}
# ------------------------------------------------------------------------------
menu_check_update(){
	if [ -e $semafor ] ; then
		zenity --info --text " Akurat teraz musisz, jak demon sprawdza nowe komentarze! \n poczekaj na demona"
		sleep 1
		show_menu
	else
		touch $semafor
		check_update
		rm -f $semafor
	fi
	show_menu
}
# ------------------------------------------------------------------------------
menu(){
	zenity --title="$TITLE"  --text "Komentrze na <span color=\"#4A97B1\"><b>dobreprogramy.pl</b></span>" \
		--list  --width=300 --height=220 \
		--column " -- by jedral.one.pl -- " --column "" \
 		"Nowych komentarzy: ($(db_get_all_uncomment_nr | wc -l))" 		"index_com"\
 		"Sprawdź teraz" 											"menu_check_update" \
		"Dodaj adres do czytnika" 							"add_url" \
		"Usuń adres z listy obserwowanych" 			"minus_url" \
 		"Wyłącz czytnik" 											"killall ${0##*/}" \
		--print-column=2 --hide-column=2
}
# ------------------------------------------------------------------------------
show_menu(){
	$(menu)
	[ $? != 0 ]  && min_icon || show_menu 
}
# ------------------------------------------------------------------------------
get_nr(){
	awk -F"<div class=\"item\" id=\"komentarz_" ' { print $2 }' $tmpfile	| cut -d\" -f1 | uniq -u
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
		db_is_comment_exist	$nr
		if [ $? != 0 ] ; then
			NRLISTNEW["${#NRLISTNEW[@]}"]=$nr
		fi
	done
}
# ------------------------------------------------------------------------------
get_comment(){
	for nr in "${NRLISTNEW[@]}" ; do
		COMMENT=$(sed -n -e "/komentarz_$nr/,/commentText/p" $tmpfile )
		# nick
		AUTOR=$(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\> -f3 | cut -d\< -f1 )
		AUTOR+=$(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\> -f4 | cut -d\< -f1 )
		# data
		DATA=$(echo "$COMMENT" | grep "class=\"nick\"" | cut -d\| -f2 | cut -d\< -f1 )
		# nr komentarza
		NR_LOCAL=$(echo "$COMMENT" | grep "class=\"numer\"" | cut -d\# -f2- | cut -d\< -f1 )
		# text
		TRESC=$(echo "$COMMENT" | grep "commentText" | cut -d\> -f2- | sed -e 's/<br\ *\/>/\n/g'  | sed -e 's/<\/p>/\n\t/g' | sed -e "s:':\":g")
		# db_add_comment adres nr nr_local autor data tresc
		db_add_comment "$url" "$nr" "$NR_LOCAL" "$AUTOR" "$DATA" "$TRESC" "unreaded"
	done
}
# ------------------------------------------------------------------------------
check_update(){
	exec 4> >(zenity --notification --listen --window-icon "$ICON_CHECK" --text "$TITLE")
	for url in $(db_get_all_url) ; do
		echo "tooltip:sprawdzam $url" >&4
		curl -s "$url" >$tmpfile 2>/dev/null
		set_nrlist
		check_diff
		# powiadomienie
		if [ "${#NRLISTNEW[@]}" != '' ] ; then
			echo "tooltip:są nowe komentarze na stronie $url" >&4
			get_comment
		fi
	done	
	exec 4>&-
}
# ------------------------------------------------------------------------------
main(){
	wymaga zenity sqlite3
	# tymczasowy plik na stronę z DP
	tmpfile=$(mktemp)
	semafor=/tmp/script_${0##*/}_db_access.lock
	# wykonaj przy wyjściu (również w razie przerwania)
	trap "rm -f $tmpfile ; rm -f $semafor " EXIT
	db_init
	min_icon &
	sleep 15
	demon
}
# ------------------------------------------------------------------------------
demon(){
	if [ -e $semafor ] ; then
		# echo " [ demon ] oczekuje "
		sleep 5
		demon
	else
		#echo " [ demon ] tworzę blokadę "
		touch $semafor
		check_update
		#echo " [ demon ] usuwam blokadę "
		rm -f $semafor
		#echo " [ demon ] ide pcia "
		sleep 600
		demon
	fi
}
# ------------------------------------------------------------------------------
main
# ------------------------------------------------------------------------------
