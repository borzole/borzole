#!/bin/bash

[ $# -eq 0 ] && { echo "Użycie: ${0##*/} plik" ; exit 0 ; }
ci "$1" && co -l "$1",v
