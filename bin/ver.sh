#!/bin/bash

[ $# -eq 0 ] && { echo "Użycie: ${0##*/} plik" ; exit 0 ; }
[ $# -eq 2 ] && MSG="-m'$2'" || MSG=""

[ ! -d RCS ] && mkdir RCS

RV="RCS/${1},v"

[[ ! -f $1 ]] && [ -f ./RCS/"$1",v ]

ci "$MSG" "$1" && co -l "$RV"
