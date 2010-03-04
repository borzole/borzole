#!/bin/bash

script_unlock(){
	# mimo, że jest to jedno polecenie to zróbmy funkcję
	# nieszczęściem by było usunąć niewłaściwy plik
	# a tak minimalizujemy prawdomodobieństwo błędu
	rm -f "$SCRIPT_LOCK"
	echo -e "${B}[ zakonczono ]${N} usuwam plik blokujący skryptu: $SCRIPT_LOCK"
}
