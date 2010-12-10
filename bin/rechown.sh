#!/bin/bash

# ...rechown

rechown(){
	while [ "$1" ]; do

		DIR="$1"
		OWNER="$2"
		FMODE="$3"
		DMODE="$4"

		find "$DIR" | (
			while read line; do
				echo chmoding $line
				if [ -f "$line" ]; then M=$FMODE; fi
				if [ -d "$line" ]; then M=$DMODE; fi
				chown "$OWNER" "$line"
				chmod "$M" "$line"
			done
		)

		shift 4
	done
} # end rechown

# setting some defaults to rechown
while [ "$1" ] ; do
	rechown "$1" $(logname) 644 755
	shift
done
