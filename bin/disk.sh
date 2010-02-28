#!/bin/bash

# pokazuje zajętość dysku na bierząco, dobre do przenoszenia między partycjami
# by borzole.one.pl

#~ while : ; do
	#~ clear && df -h && sleep 1
#~ done

watch df -h
