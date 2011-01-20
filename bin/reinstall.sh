#!/bin/bash

# reinstall -- yum reinstall przez yum shell

[[ $@ ]] && {
	# spr. czy argumentami są zainstalowane pakiety
	rpm -q $@ || exit 1
	# reinstalacja
	echo -e "remove $@ \n install $@ \n run\n quit" | yum -y shell
} || echo Użycie: ${0##*/} pakiet1 pakiet2 pakiet3 ...
