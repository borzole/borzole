#!/bin/bash

# zsudo - sudo z okienkiem zenity o hasło
# by borzole.one.pl

# run:	zsudo polecenie
# przydatne dla [Alt]+[F2], coś jak consolehelper dla każdego :P

zenity	--title="zenity sudo" --width=250 --text="Próbujesz uruchomić aplikację:
	\" $@ \"
z uprawnieniami administratora !
Podaj swoje hasło dla sudo:" \
	--entry --entry-text "****" --hide-text \
	|sudo -S "$@"
	
# uwagi:
# zahaszuj linijkę "require tty" poleceniem visudo
# Defaults    requiretty
