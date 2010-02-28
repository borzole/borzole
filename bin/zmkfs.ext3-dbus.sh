#!/bin/bash

lista_menu(){
	for p in $( fdisk -l $1 2>/dev/null | grep '^/dev/' | cut -d' ' -f1 ) ; do
		echo "TRUE $p "
	done
}

menu(){
	zenity --title "Formatowanie Dysków" --text "bedzie formacik panie?" \
		--width=400 --height=300 \
		--list  --checklist \
		--column="zaznacz" --column "partycja" \
		$(lista_menu $1) \
		--separator " " --multiple \
		--print-column=2
}

disk_format(){

	LISTA=$(menu $1)
	exec 4> >(zenity --progress --pulsate --width=300 --auto-close --auto-kill  --title="${0##*/}" )
	
	MSG="# Formatuje partycje "
	for d in $LISTA ; do
		echo "$MSG $d \n obieranie ziemniaków " >&4
		echo "mkfs.ext3 $d"
		sleep 2
		echo "$MSG $d \n przypalanie zupy" >&4
		sleep 2
		echo "$MSG $d \n zmywanie garów" >&4
		sleep 2
	done
	echo "100" >&4
	exec 4>&-
	zenity --title "${0##*/}" --info --text="Zakończono formatowanie dyskun <b>$1</b>"
}

get_device(){
	echo "$1" \
		| grep "interface=org.freedesktop.DeviceKit.Disks.Device" \
		| cut -d'/' -f7  \
		| cut -d';' -f1 
}

dbus_out(){
	dbus-monitor --system --monitor interface="org.freedesktop.DeviceKit.Disks.Device"
}

dbus_read(){
	while read line ; do
		DISK=$( get_device "$line" )
		if [[ $DISK = sd[a-z] ]] ; then
			disk_format /dev/$DISK
			break
		fi
	done
}

dbus_out | dbus_read
