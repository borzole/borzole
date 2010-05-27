#!/bin/bash

# http://wiki.fedora.pl/wiki/Typowe_problemy#Jak_bez_PackageKit_mam_instalowa.C4.87_programy_z_poziomu_nautilusa.3F

# terminal
TERM="xterm -e"
#TERM="gnome-terminal -x"

# yum z opcjami
YUM="yum localinstall --nogpgcheck --noplugins"

# jeśli masz skonfigurowane 'sudo'
$TERM sudo $YUM "$@"
# lub bez sudo
#$TERM su -c"$YUM '$@'"
