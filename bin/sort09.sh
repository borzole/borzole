#!/bin/bash

# sort09 - sortuje na katalogi 0-9
# by jedral.one.pl


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

for i in {0..9} ;do
	mkdir $i 2>/dev/null
	echo -e "$i"
	find . -xtype f -iname $i\* -exec mv '{}' ./$i/ \; 2>/dev/null
done

echo -e "usuwam puste katalogi"
rm0dir -a
