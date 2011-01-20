#!/bin/bash

table=moz_bookmarks
date=$(date +%s)
db=$HOME/.mozilla/firefox/profil.lucas/places.sqlite
cp $db ${db}.${date}
#~ db=${db}.${date}
# ------------------------------------------------------------------------------
get_id(){
	sqlite3 $db <<!
	SELECT id
	FROM $table
	WHERE type ='2' AND title = '$1'
	;
!
}
# ------------------------------------------------------------------------------
set_id(){
	sqlite3 $db <<!
	UPDATE $table
	SET parent = '$1'
	WHERE id = '$2'
	;
!
}
# ------------------------------------------------------------------------------
[[ $@ ]] && {
	dir="$1"
	link="$2"
	id_dir=`get_id "$dir"`
	id_link=`get_id "$link"`
	[[ ${#id_dir}  == 0 ]] && { echo "Docelowy folder nie istnieje" ; exit 1 ; }
	[[ ${#id_link} == 0 ]] && { echo "Źródłowy link nie istnieje" ; exit 1 ; }
	[[ `echo -e "$id_dir"  | wc -l` != 1 ]] && { echo "Docelowych folderów jest kilka" ; exit 1 ; }
	[[ $3 != '-f' ]] && \
		[[ `echo -e "$id_link" | wc -l` != 1 ]] && { echo "Źródłowych linków jest kilka" ; exit 1 ; }
	[[ $id_link == $id_dir ]] && { echo "Docelowy i Źródłowych to ten sam link" ; exit 1 ; }
	set_id $id_dir $id_link
	echo new db: $db
} || echo Użycie: ${0##*/} new_dir name
