#!/bin/bash

PressEnterKey(){
	echo -e "${G}Naciśnij klawisz ${R}[ ENTER ]${N}"
	local thisKEY=''
	read thisKEY
	return $?
}
