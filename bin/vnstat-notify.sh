#!/bin/bash

# vnStat - a console-based network traffic monitor

INTERFACE=ppp0
ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg

title(){
	echo -n "vnstat - "
	vnstat -i $INTERFACE | grep ^Database | sed -e 's/:/\n\t/'
}
msg(){
	vnstat -i $INTERFACE | grep -v ^Database
}

notify-send -u low \
			-t 0 \
			-i $ICON \
			"$(title)" \
			"$(msg)"
