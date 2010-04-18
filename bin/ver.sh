#!/bin/bash

usage(){
	echo "Użycie: ${0##*/} plik"
	exit 0
}
[[ $# -eq 0 ]] && usage
[[ ! -f $1 ]] && usage
[[ ! -d RCS ]] && mkdir RCS
ci -m" -- $2" "$1" && co -l "$1"
rlog "$1" | sed -ne '/^$/,/^ -- /p'

# przywrócenie wybranej wersji:
# co -r1.2 plik.odt

# ci -u plik.odt # zostawia kopię pliku na swoim miejscu
