#!/bin/bash

yes_no(){
	# @parametr: krótki opis wyboru
	# @return: 0|1
	# np:	yesno "Zainstalować nowy kernel?"
	echo -e "[ yes/no ] $@"
	local x=''
	while : ; do
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
