#!/bin/bash

# nakładka zenity na yum

PAKIET="$1"
# ------------------------------------------------------------------------------
terminal(){
	if tty -s
	then
		# uruchomiono interaktywnie, więc korzystamy z dobrodziejstw terminala
		"$@"
	else
		# brak terminala, więc otwieramy nowy
		#~ xterm -hold -e "$@ ; echo można już zamknąć terminal "
		xterm -title "$TITLE"  -b 2 \
			-bg '#FFFFFF' -fg '#000000' -cr '#FF0000' \
			-u8 -fa "Monospace:size=9" \
			-hold -e "$@"
	fi
}
# ------------------------------------------------------------------------------
# is_root
if [ $(id -u) != 0 ] ; then
	#~ terminal su -c "$0 $@"
	r="$(readlink -f `dirname $0`)/$(basename $0)"
	terminal sudo $r $@
	exit 0
fi
# ------------------------------------------------------------------------------
if [ $# -eq 0 ] ; then
	# get_pakiet
	PAKIET=$(zenity --title "${0##*/}" --entry --text "pakiet: ")
fi
# ------------------------------------------------------------------------------
is_rpm(){
	rpm -q $1 &>/dev/null
}
# ------------------------------------------------------------------------------
set_list(){
	unset bool
	unset name
	unset info
	local LINE
	local RPM_NAME

	exec 4> >(zenity --progress --pulsate --width=300 --auto-close --auto-kill )
	echo "# Sprawdzam dostępność pluginów ..." >&4

	while read -r LINE ; do
		echo "# $LINE" >&4
		# ładujemy do tablicy 3xN
		RPM_NAME=`cut -d. -f1 <<< $LINE`
		name[${#name[*]}]=${RPM_NAME}
		bool[${#bool[*]}]=`is_rpm $RPM_NAME && echo TRUE || echo FALSE`
		info[${#info[*]}]=`cut -d: -f2- <<< $LINE`
	# dlaczego taka konstrukcja:
	# http://forum.fedora.pl/index.php?showtopic=23033
	done < <( yum -q search $PAKIET | grep -v ^= )
	LIST_LENGTH=${#bool[*]}
	echo "100" >&4
	exec 4>&-
}
# ------------------------------------------------------------------------------
get_list(){
	local i
	for (( i=0 ; i < $LIST_LENGTH ; i++ )) ; do
		echo -ne "${bool[$i]}|$i|${name[$i]}|${info[$i]}|"
	done
}
# ------------------------------------------------------------------------------
menu(){
	local IFS="|"
	zenity --text "$(autoinfo $0)" \
		--width 600 --height 400 \
		--list  --checklist \
		--column '' --column 'i' --column 'pakiet'  --column 'opis' \
		$(get_list) \
		--separator=' ' --multiple \
		--print-column=2 --hide-column=2
}
# ------------------------------------------------------------------------------
output_full(){
	# ponieważ zenity zwraca tylko opcje zaznaczone jako TRUE,
	# to nie wiadomo jak to się ma do ich poprzedniego statusu
	# return: pola tablicy, które zostały zmienione, wraz z 'kierunkiem' zmiany
	local i
	local p
	local s=':'    # separator opcji
	local S='|'    # separator list true/false
	local FALSE='' # lista true/false
	local TRUE=''  # lista true/false
	for (( i=0 ; i < $LIST_LENGTH ; i++ )) ; do
		STATUS=FALSE
		# numerki z $OUTPUT mają status TRUE
		for p in $OUTPUT ; do
			if [ $i == $p ] ; then
				STATUS=TRUE
				break
			fi
		done
		# jeśli status się zmienił
		if [ $STATUS != ${bool[$i]} ] ; then
			# to jest trochę przekombinowane, żeby yum
			[ $STATUS == FALSE ] && echo REMOVE ${name[$i]}
			[ $STATUS == TRUE  ] && echo INSTALL ${name[$i]}
		fi
	done
}
# ------------------------------------------------------------------------------
main(){
	set_list
	OUTPUT=$(menu) || exit

	ACTION=$(output_full)
	if [[ $ACTION != "" ]] ; then
		# For example, false | true will be considered to have succeeded.
		# If you would like this to fail, then you can use:
		set -o pipefail
		# nie, nie można tego zastąpić awk bo to jest test przy użyciu 'grep'
		# a awk nawet jak nie znajdzie linii to zwroci '0'
		REMOVE=$(grep ^REMOVE <<<"${ACTION}" | sed 's:REMOVE::g') && terminal yum -C remove $REMOVE
		INSTALL=$(grep ^INSTALL <<<"${ACTION}" | sed 's:INSTALL::g') && terminal yum install $INSTALL
		set +o pipefail
	fi

	$FUNCNAME
}
# ------------------------------------------------------------------------------
main
