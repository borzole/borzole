#!/bin/bash

title(){
	echo -n "vnstat - "
	vnstat -i ppp0 | grep ^Database | sed -e 's/:/\n\t/'
}

msg(){
	vnstat -i ppp0 | grep -v ^Database
}

ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg

notify-send -u low \
			-t 0 \
			-i $ICON \
			"$(title)" \
			"$(msg)"
