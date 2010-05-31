#!/bin/bash

# http://wiki.fedora.pl/wiki/Typowe_problemy
# Jak bez PackageKit mam instalować programy z poziomu nautilusa

# terminal
TERM="xterm -e"
#TERM="gnome-terminal -x"

# yum z opcjami
YUM="yum localinstall --nogpgcheck --noplugins"

# jeśli masz skonfigurowane 'sudo'
$TERM sudo $YUM "$@"
# lub bez sudo
#$TERM su -c"$YUM '$@'"
