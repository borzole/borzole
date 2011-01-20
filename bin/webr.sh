#!/bin/bash

# webr - otwiera stronę polecenia
# by jedral.one.pl

[[ $@ ]] && {
	for p in $@ ; do
		file=$(which $p) || continue
		# rozwijanie linków symbolicznych np. typu 'alternatives'
		abs_path=$(readlink -f $file)
		xdg-open $(rpm -q --qf %{url} $(rpm -qf $abs_path)) &
	done
} || echo Użycie: ${0##*/} program

