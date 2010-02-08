#!/bin/bash

YesNo(){
	# @parametr: krótki opis wyboru
	# @return: 0|1
	# np:	yesno "Zainstalować nowy kernel?"
	echo -e "${R}[ yes/no ]${N} $@"
	local x=''
	while true ; do
		read x
		case "$x" in 
			[tT] | [tT][aA][kK] | [yY] | [yY][eE][sS] )
				return 0 ;;
			[nN] | [nN][iI][eE] | [nN][oO] )
				return 1 ;;
			* )
				echo " Wybierz yes/no" ;;
		esac
	done
}
