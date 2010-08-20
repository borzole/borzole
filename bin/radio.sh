#!/bin/bash

# posłuchaj radia z netu
# chyba gdzieś z forum Ubuntu to wziołem

list(){
	curl -s http://www.di.fm/ \
	| awk -F '"' '/href="http:.*\.pls.*96k/ {print $2}' \
	| sort \
	| awk -F '/|\.' '{print $(NF-1) " " $0}'
}

zenity --list --width 700 --height 500 \
	--column 'radio' --column 'url' \
	$(list) \
	--print-column 2 \
	| xargs mplayer

