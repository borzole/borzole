#!/bin/bash

# gamma -- jaśniej/ciemniej

get_gamma(){
	xgamma 2>&1 | awk '{print $3}' | cut -d',' -f1
}

case $1 in
	+)
		GAMMA=$(echo -e "$(get_gamma)+0.1" | bc) ;;
	-)
		GAMMA=$(echo -e "$(get_gamma)-0.1" | bc) ;;
	*)
		echo ${0##*/} +/- ;;
esac

GAMMA=$(echo $GAMMA | sed -e 's:^\.:0.:')
xgamma -gamma $GAMMA

notify-send -t 300 -i /usr/share/pixmaps/gnome-color-browser.png \
	"gamma: $(get_gamma)" \
"dopuszczalny zakres: [ 0.100 - 10.000 ]
domyślnie: 1.000"
