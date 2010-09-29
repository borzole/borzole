#!/bin/bash

# kalkulator

# trik koloruje błędy na czerwono
exec 2> >( grep --color=always \. )

while [[ $x != q ]] ; do
	echo -n "wprowadź działanie (q): "
	read x
	echo $x = $(($x))
done
