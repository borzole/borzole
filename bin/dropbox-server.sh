#!/bin/bash

# zabawka! pozwala wykonać dowolne polecenie przez dropbox :)

while true; do
	if [ -f  input.txt ];then
		OUTCOM=$(cat input.txt)
		$OUTCOM > output.txt
		rm input.txt > /dev/null 2>&1
		else
			sleep 10
	fi
done
