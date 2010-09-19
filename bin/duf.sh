#!/bin/bash

# disk usage formatted

# trik koloruje błędy na czerwono
exec 2> >( grep --color=always \. )

du -sk "$@" | sort -n | while read size fname; do
	for unit in k M G T P E Z Y; do
		if [ $size -lt 1024 ]; then
			echo -e "${size}${unit}\t${fname}"
			break
		fi
		size=$((size/1024))
	done
done
