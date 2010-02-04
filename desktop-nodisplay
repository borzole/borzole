#!/bin/bash

# desktop-nodisplay - skrypt w zenity do ustawiania czy jakieś ikonki mają być niewidoczne w menu
# poniewarz operuje na plikach w /usr/share/applications/ to musi być uruchomiony z prawami root
# by borzole (jedral.one.pl)

menu_desktop_display(){
	for app in /usr/share/applications/*.desktop ; do
		exec=$(grep -i '^Exec\ *=' $app | cut -d\= -f2)
		nodisplay=$(grep -i '^NoDisplay\ *=' $app | cut -d\= -f2) ; [ "$nodisplay" == '' ] && nodisplay=false
		echo -e $nodisplay ${exec%%\ *} ${app##*/}
	done
}

show_menu_desktop_display(){
	zenity --title="Ukrywacz Menu " --text "Zaznacz skróty, które mają być <b>niewidoczne</b> w menu" \
		--width=800 --height=800 \
		--list  --checklist \
		--column="NoDisplay" --column "Exec" --column "File"\
		$(menu_desktop_display|sort -k 2) \
		--separator " "  --multiple --print-column=3
}

SET_NODISPLAY=$(show_menu_desktop_display)
if [ $? == 0 ] ; then
	# najpierw wszytko ustawiamy na widoczny (tak jest szybciej)
	for app in /usr/share/applications/*.desktop ; do
		grep -i '^NoDisplay\ *=' $app >/dev/null 2>&1
		if [ $? != 0 ] ; then
			echo "NoDisplay=false" >> $app
		else
			sed -e 's/NoDisplay=true/NoDisplay=false/g' -i $app
		fi		
	done
	# wybrane stają się nie widoczne
	for p in $SET_NODISPLAY ; do 
		sed -e 's/NoDisplay=false/NoDisplay=true/g' -i /usr/share/applications/$p
	done
fi
