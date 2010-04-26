#!/bin/bash

msg(){
	#~ vnstat | grep '/' | sed -e 's/today//g'
	vnstat -i ppp0
}

notify-send "VNSTAT" "$(msg)"
