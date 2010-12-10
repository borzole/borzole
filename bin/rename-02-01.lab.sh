#!/bin/bash

# podbija nazwy o jeden

cd ~/temp

find . -type d | while read -r d ; do
	(
		cd "$d"
		LAST=` ls -1 | tail -n 1`
		FIRST=`ls -1 | head -n 1`
		[ ${#FIRST} != 0 ] && echo rm -f "$FIRST"
		[ ${#LAST}  != 0 ] && echo rm -f "$LAST"
		for f in * ; do
			if [[ $f == 0[1-9].* ]] ; then
				nr=$((${f%%.*} -1 ))
				name="${f#[0-9]*.}"
				echo mv "$f" "${nr}.${name}"
			fi
		done
	)
done
