#!/bin/bash

# Get domain name
# http://www.cyberciti.biz/tips/spice-up-your-unix-linux-shell-scripts.html

OUTPUT="/dev/shm/whois.output.$$"
domain=$(zenity --title "${0##*/}" \
				--entry --entry-text "fedora.pl" \
				--text "Enter the domain you would like to see whois info" )

if [ $? -eq 0 ] ; then
	# Display a progress dialog while searching whois database
	whois $domain \
		| tee >(zenity --width=200 --height=100 \
						--title "${0##*/}" \
						--progress --pulsate \
						--text="Searching domain info..." \
						--auto-kill --auto-close \
						--percentage=10) >${OUTPUT}
	# Display back output
	zenity --width=600 --height=600	\
		--title "Whois info for $domain" \
		--text-info --filename="${OUTPUT}"

fi
