#!/bin/bash

# sortaz - sortuje na katalogi a-z
# by borzole.one.pl


# $1 = głębokość sortowania (domyślnie 1)
if [ $# == 0 ] ; then
	depth="-mindepth 1 -maxdepth 1"
elif [ $# == 1 ] ; then
	if [ "$1" = -a ]||[ "$1" = "--all" ]; then
		depth=""
	else
		depth="-mindepth 1 -maxdepth $1"
	fi
fi

for i in {a..z} ;do
	mkdir $i 2>/dev/null
	echo -e "$i"
	find . -xtype f -iname $i\* -exec mv '{}' ./$i/ \; 2>/dev/null
done

echo -e "usuwam puste katalogi"
rm0dir -a
