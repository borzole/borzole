#!/bin/bash

# ustawia zarządce skalowania pracy procesora
# + wymaga włączonej usługi "cpuspeed"

# update:2010.08.25-18:36
# http://jedral.one.pl/2010/08/cpufreq-scaling-governor.html

ICON=/usr/share/pixmaps/fedora-logo-sprite.svg
# ------------------------------------------------------------------------------
load_scaling_modules(){
	for p in $(ls /lib/modules/`uname -r`/kernel/drivers/cpufreq/) ; do
		/sbin/lsmod | grep ${p%.ko} &>/dev/null || /sbin/modprobe ${p%.ko}
	done
}
# ------------------------------------------------------------------------------
unload_scaling_modules(){
	# usuwa wszystkie moduły od skalowania cpu
	# bezpieczne, bo kernel nie pozwoli usunąć tych, które są w użyciu
	for p in $(ls /lib/modules/`uname -r`/kernel/drivers/cpufreq/) ; do
		/sbin/rmmod ${p%.ko} &>/dev/null
	done
	return 0
}
# ------------------------------------------------------------------------------
scaling_available_governors(){
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
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
get_cur_freq(){
	echo "scale=3; $(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)/1000000" | bc
}
# ------------------------------------------------------------------------------
menu_text(){
	echo "<i>częstotliwość procesora:</i> <b>$(get_cur_freq) MHz</b>"
	echo "<i>zarządca skalowania:</i>     <b>$(get_scaling_governor)</b>"
	echo "<i>opis trybów:</i>             <a href='http://google.pl/search?q=cpufreq+site:fedoraproject.org'>docs.fedoraproject.org</a>"
}
# ------------------------------------------------------------------------------
menu_table(){
	for p in `scaling_available_governors` ; do
		[ "$p" == `get_scaling_governor` ] && echo -n TRUE || echo -n FALSE
		echo " $p"
	done | sort -k 2
}
# ------------------------------------------------------------------------------
menu(){
	zenity --title "${0##*/}" --window-icon "$ICON" \
		--text "$(menu_text)" \
		--width 250 --height 220 \
		--list --radiolist \
		--column '' --column '' \
		$(menu_table) \
		--print-column 2 --hide-header
}
# ------------------------------------------------------------------------------
main(){
	load_scaling_modules
	governor=$(menu)
	if [ "$governor" != '' ] ; then
		set_scaling_governor $governor
		governor=''
		$FUNCNAME
	fi
	unload_scaling_modules
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
