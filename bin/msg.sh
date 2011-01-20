#!/bin/bash

# msg.sh -- alternatywa dla gettext w bash

[[ ${BASH_VERSINFO[0]} -lt 4 ]] && exit 1

declare -A MSG_ID # wewnętrzna tablica tłumaczeń
# ------------------------------------------------------------------------------
msg(){
	[[ -n ${MSG_ID[$1]} ]] && echo ${MSG_ID[$1]} || echo "$1"
}
# ------------------------------------------------------------------------------
po(){
	MSG_ID[$1]="$2"
}
# ------------------------------------------------------------------------------
po_dump(){
	echo "# File: ${1##*/}"
	echo "# po \"Example message\" \"Przykładowa wiadomość\""
	sed -e 's/\ *\(msg\ \ *\"[:alnum:]*\)/\n\1/g' "$1" \
		| grep -E '^msg\ \ *"' \
		| cut -d'"' -f2 \
		| sort -u \
		| xargs -i echo "po \"{}\" \"\""
	return 0
}
# ------------------------------------------------------------------------------
main(){
	# funkcja aktywna tylko przy wykonaniu skryptu
	[[ -n $1 ]] && po_dump $1 || echo -e "Użycie:\n ${0##*/} [FILE]"
}
# ------------------------------------------------------------------------------
library(){
	# funkcja aktywna tylko przy 'source' skryptu
	return 0
}
# ------------------------------------------------------------------------------
[[ $BASH_SOURCE == $0 ]] && main $@ || library
