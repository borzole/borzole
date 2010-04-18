#!/bin/bash

[ $# -eq 0 ] && { echo "Użycie: ${0##*/} plik" ; exit 0 ; }
[ ! -d ./RCS ] && mkdir RCS
#~ ci "$1" && co -l "$1",v
ci -u "$1"
chmod +w "$1"
co -l "$1",v
