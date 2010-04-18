#!/bin/bash

usage(){
	echo "Użycie: ${0##*/} plik"
	exit 0
}
[[ $# -eq 0 ]] && usage
[[ ! -f $1 ]] && usage
[[ ! -d RCS ]] && mkdir RCS
ci "$1" && co -l "$1"
