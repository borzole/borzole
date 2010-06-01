#!/bin/bash

# Terminal Desktop Environment ;P

get_cmd(){
	dialog --backtitle "Terminal Desktop Environment" \
		--title "Narzędzia" \
		--ok-label run \
		--cancel-label exit \
		--begin 5 20 \
		--menu "Uruchom aplikację:" 30 45 50 \
			mc "" \
			htop "" \
			vim "" \
			'emacs -nw' "" \
			mutt "" \
			ekg2 "" \
			'. yum check-update' "" \
			'. sudo yum install' "" \
			'nmap localhost | less' "" \
			'tail -f ~/.xsession-errors' "" \
			'watch df -h' "" \
			'pinfo coreutils' "" \
			'pinfo bash' "" \
			'. man -k' ""  \
			'w3m google.com' "" \
			'. sudo iptraf' "" \
			powertop "" \
			glxgears "" \
			mocp "" \
			"_config_" "" \
			--stdout
}
# ------------------------------------------------------------------------------
.(){
	clear
	echo -ne "\e[0;32m \$ $@ \e[0m"
	read x
	eval $@ $x
	echo -e "\e[0;31m -- Naciśnij dowolny klawisz --\e[0m"
	read -sn 1 x
}
# ------------------------------------------------------------------------------
_config_(){
	mcedit $0 && {
	    $0
	    exit
	    }
}
# ------------------------------------------------------------------------------
while : ; do
	cmd=$(get_cmd)
	if [[ $? == 0 ]] ; then
	    eval $cmd
	else
	    exit
	fi
done

