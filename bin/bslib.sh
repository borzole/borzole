#!/bin/bash

usage(){
	echo -e "  ${0##*/} -- Bash Shell Library

${0##*/} jest skryptem wykonującym hurtowy 'source' innych skryptów.
Domyślnie przeszukiwane są rekursywnie katalogi znajdujące się w tablicy:
  /usr/share/bslib
  /usr/local/share/bslib
  \$HOME/.bslib
  \$HOME/.bashrc.d
w poszukiwaniu plików postaci 'nazwa.sh'.

Użycie:
  Nadaj prawa wykonywania i zapisz skrypt w jednym z katalogów, z parametru \$PATH
  W swoim skrypcie umieść na początku:
     . ${0##*/} || exit 1
  lub
     source ${0##*/} || exit 1

Licencja:
  GPLv2+

Autor:
  Łukasz Jędral ( borzole )
  borzole@gmail.com
  http://jedral.one.pl"
}
# ------------------------------------------------------------------------------
library(){
	#~ [[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1
	if [[ ${BASH_VERSINFO[0]} -lt 4 ]] ; then
		echo "Błąd wersji BASH, wymaga min. wersji '4'" >&2
		exit 1
	fi
	# lista folderów ze skryptami:
	unset BSLIB_PATH
	BSLIB_PATH[${#BSLIB_PATH[*]}]=/usr/share/bslib
	BSLIB_PATH[${#BSLIB_PATH[*]}]=/usr/local/share/bslib
	BSLIB_PATH[${#BSLIB_PATH[*]}]=$HOME/.bslib
	BSLIB_PATH[${#BSLIB_PATH[*]}]=$HOME/.bashrc.d

	# Must enable globstar, otherwise ** doesn't work.
	shopt -s globstar
	# rekursywny source
	for d in "${BSLIB_PATH[@]}" ; do
		if [[ -d $d ]] ; then
			for s in "$d"/**/*.sh ; do
				. "$s" || exit 1
			done
		fi
	done
}
# ------------------------------------------------------------------------------
# inne funkcje dla wykonania/importu skryptu (jak w python)
[[ $BASH_SOURCE == $0 ]] && usage || library
