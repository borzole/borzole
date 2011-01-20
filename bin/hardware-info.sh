#!/bin/bash

cat /proc/cpuinfo
cat /proc/meminfo
cat /etc/X11/xorg.conf

lspci
lsusb

glxconfig

netstat -tap

nmap localhost

dmesg

free
free -m
df
fdisk -l
cat /proc/cpuinfo
cat /etc/fstab
cat /etc/mtab
