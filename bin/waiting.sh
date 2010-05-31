#!/bin/bash

# This script displays a sequence of characters as an indication that
# the calling script is still running.

# Description:
# ------------
# If another script needs some time to finish its execution a sequence of
# characters can be displayed to indicate that another script is still running.
#
# Call from another script:       nice -n 19 waiting &
# Explicit call to display:
# 1. a r-otating l-ine (default): nice -n 19 waiting rl &
# 2. b-ouncing l-ines:            nice -n 19 waiting bl &
# 3. r-unning d-ots:              nice -n 19 waiting rd &
# 4. b-ouncing d-ots:             nice -n 19 waiting bd &
# 5. an e-xpanding "o":           nice -n 19 waiting eo &
# 6. a r-eappearing p-hrase:      nice -n 19 waiting rp 'your phrase' &
#
# Since waiting is started in the background it will be useful to trap
# signals which cause the calling script to terminate so that waiting can be
# terminated as well. E.g. the following can be defined in the calling script:
#
# nice -n 19 waiting &
# WAITING_PID="$!"
#
# cleanup() {
#    test -n "$WAITING_PID" && kill -TERM $WAITING_PID &> /dev/null
#    exit 0
# }
#
# trap cleanup HUP INT QUIT ABRT TERM EXIT
#
#
# Changelog:
# --------
# Version 0.1 initial release (december 2005)
#
#
# Copyright (C) 2005 patch_linams@yahoo.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software (the "Software"), to deal in the Software
# without restriction, including without limitation the rights to use,
# copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE.
#

# function to execute while waiting
declare -f WAITING

# indication of waiting: r-otating l-ine (default),  b-ouncing l-ines.
# r-unning d-ots, b-ouncing d-ots, e-xpanding "o", r-eappearing p-hrase
SHOW="rl"

# number of running dots
declare -i NOD=5

# reappearing phrase
PHRASE=""

rotating_line() {
    echo -ne "-\033[1D"
    sleep 0.125
    echo -ne "\ \033[2D"
    sleep 0.125
    echo -ne "|\033[1D"
    sleep 0.125
    echo -ne "/\033[1D"
    sleep 0.125
}

bouncing_lines() {
    echo -ne "_\033[1D"
    sleep 0.25
    echo -ne "-\033[1D"
    sleep 0.25
    echo -ne "=\033[1D"
    sleep 0.25
}

reappearing_phrase() {
    let POS=0
    let LEN=$(expr length "$PHRASE")
    while [ $POS -lt $LEN ]; do
	echo -ne "${PHRASE:$POS:1}"
	let POS=$POS+1
	sleep 0.4
    done
    sleep 0.4
    echo -ne "\033["$LEN"D\033[K"
}

running_dots() {
    PHRASE=""
    for i in $(seq -s " " 1 $NOD); do
	PHRASE=$PHRASE"."
    done
    reappearing_phrase
}

bouncing_dots() {
    echo -ne ".\033[1D"
    sleep 0.25
    echo -ne ":\033[1D"
    sleep 0.25
    echo -ne "°\033[1D"
    sleep 0.25
}

expanding_o() {
    echo -ne " \033[1D"
    sleep 0.25
    echo -ne ".\033[1D"
    sleep 0.25
    echo -ne "o\033[1D"
    sleep 0.25
    echo -ne "O\033[1D"
    sleep 0.25
}

check_option() {
    test -n "$1" && SHOW="$1"
    case $SHOW in
	rl)
	    WAITING=rotating_line
	    ;;
	bl)
	    WAITING=bouncing_lines
	    ;;
	rd)
	    WAITING=running_dots
	    ;;
	bd)
	    WAITING=bouncing_dots
	    ;;
	eo)
	    WAITING=expanding_o
	    ;;
	rp)
	    if [ -n "$2" ]; then
		PHRASE="$2"
		WAITING=reappearing_phrase
	    else
		echo "No phrase given!"
		exit 1
	    fi
	    ;;
	*)
	    echo "No such indication available!"
	    exit 1
	    ;;
    esac
}

check_option "$@"
while(true); do
    $WAITING
done
#EOF
