#!/bin/bash

press_any_key(){
	echo -e "Naciśnij dowolny klawisz"
	local thisKEY=''
	read -sn 1 thisKEY
	return $?
}
