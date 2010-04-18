#!/bin/bash

usage(){
	echo "Użycie: ${0##*/} plik"
	exit 0
}

[ $# -eq 0 ] && usage
[ $# -eq 2 ] && MSG="-m'$2'" || MSG=""

[[ ! -d RCS ]] && mkdir RCS

[[ ! -f $1 ]] && {
	[[ -f RCS/${1},v ]] && co -l "$1" || usage
	}

ci "$MSG" "$1" && co -l "$1"
