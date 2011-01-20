#!/bin/bash

# cpu hot plug

ICON=/usr/share/pixmaps/fedora-logo-sprite.svg
# ------------------------------------------------------------------------------
set_list(){
	unset bool
	unset name
	for p in /sys/devices/system/cpu/cpu[1-9]*/online ; do
		bool[${#bool[*]}]=$([ `cat $p` == 1 ] && echo TRUE || echo FALSE)
		p=${p#/sys/devices/system/cpu/}
		p=${p%/online}
		name[${#name[*]}]=$p
	done
	LIST_LENGTH=${#bool[*]}
}
# ------------------------------------------------------------------------------
get_list(){
	for (( i=0 ; i < $LIST_LENGTH ; i++ )) ; do
		echo -e "${bool[$i]} $i ${name[$i]} "
	done
}
# ------------------------------------------------------------------------------
set_list_false(){
	for (( i=0 ; i < $LIST_LENGTH ; i++ )) ; do
		bool[$i]=FALSE
	done
}
# ------------------------------------------------------------------------------
get_scaling_governor(){
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
}
# ------------------------------------------------------------------------------
set_scaling_governor(){
	# dla każdego rdzenia
	for p in /sys/devices/system/cpu/cpu[0-9]*
	do
		# ustaw zarządcę
		( echo $1 >  $p/cpufreq/scaling_governor ) 2>/dev/null
		# jeśli dany rdzeń jest wyłączony to wyjście może zawierać śmieci stąd /dev/null
	done
}
# ------------------------------------------------------------------------------
set_cpu_from_list(){
	for (( i=0 ; i < $LIST_LENGTH ; i++ )) ; do
		cpu=/sys/devices/system/cpu/${name[$i]}/online
		if [ ${bool[$i]} == TRUE ] ; then
			[ `cat $cpu` != 1 ] && echo 1 > $cpu
		else
			[ `cat $cpu` != 0 ] && echo 0 > $cpu
		fi
	done
	# przeładować usługę skalowania procesora
	(service cpuspeed restart) &>/dev/null
	# ponownie sprawdzić ustawienia: cpufreq/scaling_governor
	set_scaling_governor `get_scaling_governor`
}
# ------------------------------------------------------------------------------
menu_text(){
	echo -e "Włącz / Wyłącz procesory (rdzenie)\n"
	echo -e " <b>[x]</b> <i>cpu0 (domyślnie nie można go wyłączyć)</i>"
}
# ------------------------------------------------------------------------------
menu(){
	zenity --title "${0##*/}" --window-icon "$ICON" \
		--text "$(menu_text)" \
		--width 250 \
		--list --checklist \
		--column '' --column '' --column '' \
		$(get_list) \
		--print-column 2 --hide-column 2 --hide-header --multiple --separator " "
}
# ------------------------------------------------------------------------------
main(){
	set_list
	SELECT=$(menu) || exit 0
	set_list_false

	for p in $SELECT ; do
		bool[$p]=TRUE
	done

	set_cpu_from_list
	$FUNCNAME
}
# ------------------------------------------------------------------------------
# run_as_root
if [ `id -u` != 0 ] ; then
	abs_path="$(readlink -f `dirname $0`)/$(basename $0)"
	echo "[su -] uruchaminie jako root"
	su -c"/bin/bash $abs_path $@"
else
	main $@
fi
