#!/bin/bash

# http://jedral.one.pl/2010/12/znajdz-mnie-nim-przepadne.html

srcdb=$HOME/.mozilla/firefox/profil.lucas/places.sqlite
db=/dev/shm/places.sqlite # /dev/shm/ to RAM
[ -f $db ] && rm -f $db
cp $srcdb $db || exit 1
# ------------------------------------------------
usage(){
	echo "${0##*/} { b, bookmarks | h, history} [ -u,--url | -t,--title ]"
	exit $1
}
# ------------------------------------------------
get_history(){
	sqlite3 $db <<!
		SELECT $select
		FROM moz_places p, moz_historyvisits h
		WHERE p.hidden=0 AND p.id = h.place_id
		;
!
}
# ------------------------------------------------
get_bookmarks(){
	sqlite3 $db <<!
		SELECT $select
		FROM moz_places p, moz_bookmarks b
		WHERE p.hidden=0 AND p.id = b.fk
		;
!
}
# ------------------------------------------------
# wybieramy co wyświetlić: url, tytuł, wszystko
select='p.url , p.title'
[[ $2 ]] && {
	case "$2" in
		-u|--url)   select='p.url' ;;
		-t|--title) select='p.title' ;;
		*)          usage 1 ;;
	esac
}
# ------------------------------------------------
# wybieramy źródło: zakładki, historia
[[ $1 ]] && {
	case "$1" in
		h|history)   get_history ;;
		b|bookmarks) get_bookmarks ;;
		*)          usage 1 ;;
	esac
} || usage
