#!/bin/bash

# w nieparzyste dni używam Vim, a w parzyste Emacs ;D

is_odd(){
	# czy dzień jest nieparzysty
	(( $(date +%d) % 2 ))
}

if tty -s ; then
	# uruchomiono interaktywnie, więc korzystamy z dobrodziejstw terminala
	if is_odd ; then
		vim $@
	else
		emacs -nw $@
	fi
else
	# brak terminala, więc otwieramy w X
	if is_odd ; then
		gvim $@
	else
		emacs $@
	fi
fi
