#!/bin/bash

# w nieparzyste dni używam Vim, a w parzyste Emacs ;D

if tty -s
then
	# uruchomiono interaktywnie, więc korzystamy z dobrodziejstw terminala
	(( $(date +%d) % 2 )) && vim $@ || emacs -nw $@
else
	# brak terminala, więc otwieramy w X
	(( $(date +%d) % 2 )) && gvim $@ || emacs $@
fi
