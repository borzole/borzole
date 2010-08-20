#!/bin/bash

# przykład jak zamienić string na tablicę w bash

STR=abc123xyz098
LENGTH=${#STR}

echo -e "$STR \n"

for (( i=0 ; i < $LENGTH ; i++ )) ; do
	echo $i : ${STR:${i}:1}
done
