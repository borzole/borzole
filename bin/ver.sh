#!/bin/bash

[ $# -eq 0 ] && { echo "Użycie: ${0##*/} plik" ; exit 0 ; }

[ ! -d ./RCS ] && mkdir RCS

RV="RCS/${1},v"

[[ ! -f $1 ]] && [ -f ./RCS/"$1",v ]

ci "$1" && co -l "$RV"
