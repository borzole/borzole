#!/bin/bash

#	{ wget | proz | aria2c | curl } z powiadomieniem
#
# by Michał Bentkowski (mr.ecik@gmail.com)
# rozbudowane by borzole.one.pl
# licensed under GPLv2+
# requires: notify-send ( libnotify.rpm )
 
# Jako "download manager"
# Wtyczka Flashgot do firefox:
# PRZYKŁAD:
# 	polecenie:
#			/usr/bin/gnome-terminal
# 	parametry:
# 		-x getilla --wget [URL] -P [FOLDER]

# ICONS: (change if you don't like them ;-))
ICON_OK=messagebox_info
ICON_ERR=messagebox_critical

# ------------------------------------------------------------------------------
# PATHS: (change them if it's needed)
if [ "$#" -eq 0 ]; then
	exit 1;
elif [ "$1" = -w ]||[ "$1" = "--wget" ]; then
	GET=/usr/bin/wget
	# getilla --wget -x [URL] -P [FOLDER]
elif [ "$1" = -p ]||[ "$1" = "--proz" ]; then
	GET=/usr/bin/proz
	# --proz [URL] -P [FOLDER]
	# getilla --proz [URL] -P [FOLDER]
elif [ "$1" = -a ]||[ "$1" = "--aria2c" ]; then
	GET=/usr/bin/aria2c   
	# nie używam :)
elif [ "$1" = -c ]||[ "$1" = "--curl" ]; then
	GET=/usr/bin/curl -C - -O
	# nie wiem, też nie używam ;P
else
	GET=/usr/bin/?
	shift $#
fi

# ------------------------------------------------------------------------------
# just run "get" with given parameters

# $GET "${@:2}"
shift
$GET $@
EXIT=$?

# check whether $DISPLAY exists,
# if not, exit with get's exit code
[ "x$DISPLAY" == "x" ] && exit $EXIT

# don't notify if --help
# was invoked
for p in $*; do [[ "$p" == "--help" ]] && exit $EXIT; done

if [ "x$EXIT" == "x0" ]; then
  notify-send -i $ICON_OK -u low "Download OK" "${*:2}"
  #~ xdg-open ${*:2}
else
  notify-send -i $ICON_ERR -u critical "Download ERROR" "$*"
fi
exit $EXIT








