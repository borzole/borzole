#!/bin/bash

press_enter_key(){
	echo -e "${G}Naciśnij klawisz ${R}[ ENTER ]${N}"
	local thisKEY=''
	read thisKEY
	return $?
}
