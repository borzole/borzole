#!/bin/bash

lista_menu(){
	for p in $( fdisk -l 2>/dev/null | grep '^/dev/' | cut -d' ' -f1 ) ; do
		echo "TRUE $p "
	done
}

menu(){
	zenity --title "Formatowanie Dysków" --text "bedzie formacik panie?" \
		--width=400 --height=300 \
		--list  --checklist \
		--column="zaznacz" --column "partycja" \
		$(lista_menu) \
		--separator " " --multiple \
		--print-column=2
}

for d in $(menu) ; do
	echo "mkfs.ext3 $d"
done
