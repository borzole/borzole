#!/bin/bash

DATA=$(date +%Y.%m.%d-%H:%M)
SYSTEM=$(sed -e 's/release\ *//g' /etc/system-release)
LOG="$HOME/zainstalowane -- ${SYSTEM} $(arch) -- ${DATA}.log"

rpm -qa --qf "%{name}.%{arch} \n" | sort -u > "$LOG"
