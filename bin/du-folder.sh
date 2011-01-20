#!/bin/bash

# pokazuje rozmiar katalogu

usage(){
	echo -e "${0##*/} -- rozmiat katalogu
UŻYCIE:
	${0##*/} folder
"
	exit 1
}

[ $# -eq 0 ] && usage

du -h $1 | tail -n 1
