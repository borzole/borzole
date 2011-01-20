#!/bin/bash

# Maximum mount count & Reserved block count


for d in /dev/sd??* ; do
	# jeśli system plików to ext2...ext4
	fs="$(file -s $d | awk '{print $5}')"
	if [[ "$fs" == ext[2-4] ]] ; then
		BC=$(tune2fs -l $d | grep '^Block count' | awk '{print $NF}')
		RBC=$(tune2fs -l $d | grep '^Reserved block count' | awk '{print $NF}')
		procent=$(echo -e "scale=1; 100*$RBC/$BC" | bc | sed -e 's:^\.:0.:')
		echo -e "$d : $fs : $procent % for root"
		tune2fs -l $d | grep -i 'Maximum mount count'
	fi
done
