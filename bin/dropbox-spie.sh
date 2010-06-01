#!/bin/bash

# poszukajmy Dropbox/Public

# autor: Krzysztof Dziadziak
# źródło: http://forwardfeed.pl/index.php/2010/02/01/dropbox-public-folder/
# zmiany: borzole (jedral.one.pl)
# ------------------------------------------------------------------------------
p=index.html
SPIS=spis.html
i=${1:-0}
# ------------------------------------------------------------------------------
echo "Szukamy plików $p w katalogach userów http://dl.dropbox.com

UWAGA!
	aby zakończyć poszukiwania naciśnij [Ctrl]+[C]
"
while : ; do
	echo -n "."
	wget -q --tries=2 --timeout=30 --limit-rate=20k http://dl.dropbox.com/u/$i/"$p"
	if [ -f "$p" ] ; then
		echo -e "\nhttp://dl.dropbox.com/u/$i/$p"
		echo -e "<a href=\"http://dl.dropbox.com/u/$i/$p\">$i/$p</a> <br />" >> $SPIS
		rm -f "$p"
	fi
	# podbijamy index
	let i=$((i+1))
	trapEXIT(){
		echo
		echo -e "$i" | tee -i last.log
	}
	trap trapEXIT EXIT
done
