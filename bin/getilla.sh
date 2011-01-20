#!/bin/bash

# polecenie z powiadomieniem

# PRZYKŁAD: wtyczka Flashgot do firefox:
# 	polecenie:
#			/usr/bin/xterm
# 	parametry:
# 		-e getilla.sh wget -x [URL] -P [FOLDER]
# 		-e getilla.sh proz [URL] -P [FOLDER]
#
# aria2c # nie używam :)
# curl -C - -O # nie wiem, też nie używam ;P
# ------------------------------------------------------------------------------
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
[ $# -eq 0 ] && exit 1;
$@
RC=$?
# check whether $DISPLAY exists,
# if not, exit with get's exit code
#~ [ "x$DISPLAY" == "x" ] && exit $EXIT
ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg
if [[ $RC == 0 ]] ; then
  notify-send -i $ICON -u low "OK" "${*:2}"
else
  notify-send -i messagebox_critical -u critical "ERROR" "$*"
fi
exit $RC








