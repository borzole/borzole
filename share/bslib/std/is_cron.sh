#!/bin/bash

is_cron(){
	if $(tty -s) ; then
		Verbose "Oh good, this is interactive \nHello $USER"
		return 1
	else
		# for cron
		date +"Script $0 started %T" >> $FILE_LOG
#@TODO obsługa $FILE_LOG (czy jest ustawiony)
		return 0
	fi
}
