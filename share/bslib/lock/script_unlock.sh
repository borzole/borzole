#!/bin/bash

script_unlock(){
	# mimo, że jest to jedno polecenie to zróbmy funkcję
	# nieszczęściem by było usunąć niewłaściwy plik
	# a tak minimalizujemy prawdomodobieństwo błędu
	[[ -f $SCRIPT_LOCK ]] && rm -f "$SCRIPT_LOCK"
	verbose "[ zakonczono ] usuwam plik blokujący skryptu: $SCRIPT_LOCK"
}
