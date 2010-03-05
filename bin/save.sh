#!/bin/bash

LOG="$HOME/cmd.log"

LINE="# -----------------------------------------------------------------------"

if [ $# -eq 0 ] ; then
	echo -e "nie podano żadnego polecenia"
	exit 0
fi
# ------------------------------------------------------------------------------
echo -e "$LINE" >>"$LOG"
echo -e "# EXEC: $@" >>"$LOG"
echo -e "$LINE" >>"$LOG"
eval "$@" | tee -ai "$LOG"
echo -e " -- zapisano do: $LOG --"
