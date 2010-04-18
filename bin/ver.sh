#!/bin/bash

usage(){
	echo "Użycie: ${0##*/} plik"
	exit 0
}

[[ $# -eq 0 ]] && usage
[[ ! -f $1 ]] && usage
[[ $# -eq 2 ]] && MSG="-m'$2'" || MSG=""

[[ ! -d RCS ]] && mkdir RCS

echo "$MSG"
#~ ci "$MSG" "$1" && co -l "$1"
ci "$1" && co -l "$1"
