#!/bin/bash

# find-example sed

re=${1-'^rpm'}

if [ $# == 0 ] ; then
	echo -e "Wyświetl polecenia w \$PATH według wzoru z \$1 \nprzykład:"
	echo -e "\t ${0##*/} "\'$re\'
	echo -e "rezultat \n--------------------"
	
fi

BIN=( `echo $PATH | sed -e 's/:/\ /g'` )

for bin in ${BIN[@]} ; do
	find $bin -xtype f | xargs -i grep -n -H $re '{}' 2>/dev/null | grep -v '^Plik binarny'
done
