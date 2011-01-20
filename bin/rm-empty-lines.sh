#!/bin/bash

# Usuwa puste linie z pliku

usage(){
	echo -e "Usuwa puste linie w pliku tekstowym
Użycie:
	${0##*/} /path/to/file"
	exit 0
}

if [[ -f "$1" ]] ; then
	FILE="$1"
	file "$FILE" | grep text &>/dev/null || usage
	#~ CORE=$( egrep -v '^[[:space:]]*(#[^!]|$)' "$FILE" )
	CORE=$( egrep -v '^[[:space:]]*$' "$FILE" )
	echo -e "$CORE" > "$FILE"
else
	usage
fi
