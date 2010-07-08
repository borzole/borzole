#!/bin/bash

# PLD 
# by jedral.one.pl

mychroot="/mnt/pld"

function on(){

	mount /dev/sdb2	$mychroot/boot &&
	mount /dev/sdb4 $mychroot &&
	#mount /dev/sdb3		swap
	cp -L /etc/resolv.conf $mychroot/etc/ &&
	mount --bind /dev $mychroot/dev &&
	mount -t proc proc $mychroot/proc &&
	mount -t sysfs none $mychroot/sys &&
	mount --bind /tmp $mychroot/tmp
	# mount --bind /home $mychroot/home/users
}

function off(){
	umount $mychroot/tmp &&
	umount $mychroot/sys &&
	umount $mychroot/proc &&
	umount $mychroot/dev &&
	umount $mychroot &&
	umount $mychroot/boot
}

menu(){
	case "$1" in
		on)
			on
			;;
		off)
			off
  			;;
		*)
			$0 {on|off}
			;;
	esac
}
menu $@

# ---------------------------------------- NOTES
#~ 
#~ fakeroot fakechroot chroot /home/lucas/project/pld/ /bin/sh

#1. skopiować ldd bash
#2. skopiować ldd rpm i wsio z paczki
# rpm --root / --initdb

#3. montowanie
#~ mount --bind /proc $mychroot/proc
#~ mount --bind /sys $mychroot/sys
#~ mount --bind /dev $mychroot/dev

#4. metodą:  rpm -q yum --requires
# sprawdzać zależności i dla wszystkich
#~ for r in rpm yum ... python python-pycurl
#~ do
	#~ for p in $(rpm -ql $r) ; do echo mkdir -p /home/lucas/project/pld${p%/*} 2>/dev/null ; done | sort -u | sh
	#~ for p in $(rpm -ql $r) ; do cp -p $p /home/lucas/project/pld${p} 2>/dev/null ; done
#~ done

# wszelkie niedosiągnięcia wyszukać przez "yum provides pycurl"

# skopiować repozytoria i ustawić na sztywno architekturę

#5. yum install rpm yum
