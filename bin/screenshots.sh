#!/bin/bash

# zrzut pulpitu

Quality="500"

for p in {5..1}
do
	sleep 1
	echo -n .
done

FILE=$HOME/zrzut_$(date "+%Y%m%d%_%H%M%S_").png

import -window root -quality $Quality $FILE

echo
