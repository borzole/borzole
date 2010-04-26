#!/bin/bash

msg(){
	#~ vnstat | grep '/' | sed -e 's/today//g'
	vnstat -i ppp0
}

ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg

# NotifyOSD: http://forums.fedoraforum.org/showthread.php?t=225028
#~ ICON=notification-audio-next
#~ ICON=notification-audio-play
#~ ICON=notification-audio-previous
#~ ICON=notification-audio-volume-high
#~ ICON=notification-audio-volume-low
#~ ICON=notification-audio-volume-medium
#~ ICON=notification-audio-volume-muted
#~ ICON=notification-audio-volume-off
#~ ICON=notification-battery-low
#~ ICON=notification-device-eject
#~ ICON=notification-device
#~ ICON=notification-display-brightness
#~ ICON=notification-keyboard-brightness
#~ ICON=notification-message-email
#~ ICON=notification-message-im
#~ ICON=notification-network-ethernet-connected
#~ ICON=notification-network-ethernet-diconnected
#~ ICON=notification-network-wireless
#~ ICON=notification-power

# http://www.galago-project.org/specs/notification/0.9/index.html
notify-send -u low \
			-t 4000 \
			-i $ICON \
			"VNSTAT" \
			"$(msg)"

