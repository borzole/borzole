#!/bin/bash

# Red Erorrs
exec 2> >( grep --color=always \. )
# ------------------------------------------------------------------------------
TITLE="Revision Control System (RCS)"
ICON=/usr/share/pixmaps/apple-red.png
# ------------------------------------------------------------------------------
zenity(){
	$(type -P zenity) --title "$TITLE" --window-icon "$ICON" "$@"
}
# ------------------------------------------------------------------------------
fs(){
	local i
	let i=$1+1
	awk 'BEGIN { FS="----------------------------\n"; RS=""; i=0 } { if (i == 0) print $'$i'; i++ }' <<<"$CORE"
}
# ------------------------------------------------------------------------------
rm_empty_lines(){
	egrep -v '^[[:space:]]*$'
}
# ------------------------------------------------------------------------------
rm_header(){
	egrep -v '^([[:space:]]*$|RCS file: |Working file:|head:|branch:|locks:|access list:|symbolic names:|keyword substitution:|total revisions:)'
}
# ------------------------------------------------------------------------------
rm_revision(){
	egrep -v '^([[:space:]]*$|revision|date:)'
}
# ------------------------------------------------------------------------------
is_rcs_init(){
	rlog "$FILE" &>/dev/null
}
# ------------------------------------------------------------------------------
is_empty(){
	[ -z "$1" ]
}
# ------------------------------------------------------------------------------
is_not_empty(){
	[ ! -z "$1" ]
}
# ------------------------------------------------------------------------------
get_msg(){
	zenity --entry --text "$@" --width 500
}
# ------------------------------------------------------------------------------
rcs_init(){
	local MSG
	MSG=$(get_msg "Podaj krótki opis pliku: \n$FILE" ) || exit 0 # anuluj ozn. wyjście z programu
	is_empty "$MSG" && MSG="Hello World"
	ci -l -t-"$MSG" "$FILE"
}
# ------------------------------------------------------------------------------
rcs_add(){
	local MSG
	MSG=$(get_msg "Podaj krótki opis wprowadzonych zmian dla pliku: \n$FILE") || return 1 # anuluj ozn. powrót do menu
	is_empty "$MSG" && MSG="New log"
	ci -l -m"$MSG" "$FILE"
}
# ------------------------------------------------------------------------------
chmod_w(){
	local NAME="${FILE##*/}"
	local DIR="${FILE%/*}"
	chmod +w "$FILE"
	chmod +w "${FILE},v"
	chmod +w "${FILE%,v}"
	chmod +w "${DIR}/RCS/${NAME}"
	chmod +w "${DIR}/RCS/${NAME},v"
}
# ------------------------------------------------------------------------------
rcs_restore(){
	co -f -r"$REV" "$FILE"
	chmod_w &>/dev/null
}
# ------------------------------------------------------------------------------
rcs_diff(){
	#~ rcsdiff -r"$REV" "$FILE"
	co -p -q -r"$REV" "$FILE" > $FILE_REV
	meld "$FILE" $FILE_REV
}
# ------------------------------------------------------------------------------
menu_main_show(){
	zenity --text "Co chcesz zrobić na pliku \n<b>$FILE</b>\n<i>$DESCRIPTION</i>" \
		--list  --radiolist \
		--column "" --column "cmd" --column "info" \
		TRUE rcs_add "Aktualizuj archiwum"  \
		FALSE menu_revision "Zobacz wersje i porównaj"  \
		--print-column 2 --hide-column 2
}
# ------------------------------------------------------------------------------
menu_main(){
	local CMD
	CMD=$(menu_main_show)
	if is_not_empty $CMD ; then
		$CMD
		$FUNCNAME
	fi
	return 0
}
# ------------------------------------------------------------------------------
menu_revision_table(){
	local i
	for (( i=1 ; i <= $FIELDS_COUNT ; i++ )) ; do
		INFO=$(fs $i | rm_empty_lines |rm_revision)
		DATE=$(fs $i | grep ^date: | cut -d' ' -f2,3 | cut -d';' -f1 )
		REVISION=$(fs $i | grep ^revision| awk '{print $2}')
		echo -ne "FALSE|$REVISION|$DATE|$INFO|"
	done | sed '1s/FALSE/TRUE/'
}
# ------------------------------------------------------------------------------
menu_revision_show(){
	# IFS jest zmieniony lokalnie, aby można było generować elementy menu ze spacją
	# generowana lista musi być ciągłą linią (bez enterów), czyli 'echo' z opcją '-n'
	local IFS="|"
	zenity --text "$HEADER" \
		--width 500 \
		--height 400 \
		--list  --radiolist \
		--column "" --column "revision" --column "date"  --column "info" \
		$(menu_revision_table) \
		--print-column 2 #--hide-column 2,3
}
# ------------------------------------------------------------------------------
menu_revision(){
	set_fields # refresh
	local REV
	REV=$(menu_revision_show)
	if is_not_empty $REV ; then
		echo $REV
		menu_action $REV
		$FUNCNAME
	fi
}
# ------------------------------------------------------------------------------
menu_action_show(){
	zenity --text "plik: <b>$FILE</b>\nwersja: <span color='red'>$REV</span>" \
		--list  --radiolist \
		--column "" --column "cmd" --column "info" \
		TRUE rcs_diff "Porównaj plik z tą wersją"  \
		FALSE rcs_restore "Przywróć tę wersję"  \
		--print-column 2 --hide-column 2
}
# ------------------------------------------------------------------------------
menu_action(){
	local CMD
	CMD=$(menu_action_show)
	if is_not_empty $CMD ; then
		$CMD
		$FUNCNAME
	fi
}
# ------------------------------------------------------------------------------
set_fields(){
	CORE=$(rlog $FILE | grep -v ^=)
	FIELDS_COUNT=$(grep ^- <<<"$CORE" | wc -l)
	HEADER=$(fs 0 | rm_empty_lines | sed -e 's/^\([[:print:]]*:\)/<i><span color="red">\1<\/span><\/i>/g')
	DESCRIPTION=$(fs 0 | rm_empty_lines | rm_header | sed -n -e '/^description:/,//p' | egrep -v ^description:)
}
# ------------------------------------------------------------------------------
set_files(){
	FILE=$(echo -e "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1)
	if is_empty "$FILE" ; then
		zenity --question --text "Nie zaznaczono żadnego pliku, chcesz wybrać plik teraz ?"
		if [ $? = 0 ] ; then
			FILE=$(zenity --file-selection) || exit 0
		else
			exit 0
		fi
	fi
	# Temp file
	FILE_REV=$(mktemp)
	trap "rm -f $FILE_REV" EXIT
}
# ------------------------------------------------------------------------------
ui(){
	if is_rcs_init ; then
		set_fields
		menu_main
		exit 0
	else
		rcs_init
		$FUNCNAME
	fi
}
# ------------------------------------------------------------------------------
main(){
	set_files
	ui
}
# ------------------------------------------------------------------------------
main
