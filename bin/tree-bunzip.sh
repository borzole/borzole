#!/bin/bash

# przejdź po drzewie katalogów i rozpakuj bz2

find /katalog/główny/ -type f -iname \*.bz2 | while read -r line ; do
	dir=${line%/*}
	name=${line##*/}
	(
		cd "$dir"
		bunzip2 "$name"
		rm -f "$name"
	)
done
