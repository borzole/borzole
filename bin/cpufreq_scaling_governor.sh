#!/bin/bash

# skalowanie pracy procesora
# http://forum.fedora.pl/index.php?showtopic=22310
# + włączona usługa cpuspeed

# ------------------------------------------------------------------------------
load_scaling_mod(){
	for p in $(ls /lib/modules/`uname -r`/kernel/drivers/cpufreq/) ; do
		/sbin/lsmod | grep ${p%.ko} &>/dev/null || /sbin/modprobe ${p%.ko}
	done
}
# ------------------------------------------------------------------------------
scaling_available_governors(){
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
}
# ------------------------------------------------------------------------------
is_scaling_available_governors(){
	for p in `scaling_available_governors` ; do
		[[ $p == $1 ]] && return 0
	done
	return 1
}
# ------------------------------------------------------------------------------
get_scaling_governor(){
	cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
}
# ------------------------------------------------------------------------------
set_scaling_governor(){
	if is_scaling_available_governors $1 ; then
		# dla każdego rdzenia
		for p in /sys/devices/system/cpu/cpu[0-9]*
		do
			echo $1 >  $p/cpufreq/scaling_governor
		done
	fi
}
# ------------------------------------------------------------------------------
get_cpuinfo_cur_freq(){
	cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
}
# ------------------------------------------------------------------------------
menu_table(){
	for p in `scaling_available_governors` ; do
		[ "$p" == `get_scaling_governor` ] && echo -n TRUE || echo -n FALSE
		echo " $p"
	done
}
menu(){
	zenity --text "Częstotliwość procesora: `get_cpuinfo_cur_freq` Hz \nZarządca skalowania:     `get_scaling_governor`" \
		--width 250 --height 220 \
		--list --radiolist \
		--column '' --column '' \
		$(menu_table) \
		--print-column 2 --hide-header
}
# ------------------------------------------------------------------------------
main(){
	load_scaling_mod
	gov=$(menu)
	if [ "$gov" != '' ] ; then
		set_scaling_governor $gov
		gov=''
		$FUNCNAME
	fi
}
# ------------------------------------------------------------------------------
if [ `id -u` != 0 ] ; then
	r="$(readlink -f `dirname $0`)/$(basename $0)"
	sudo $r $@
	exit $?
else
	main $@
fi
