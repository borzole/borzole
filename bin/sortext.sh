#!/bin/bash

# sortext - sortuje podane rozszerzenie do katalogów z $@
# by borzole.one.pl

# np.:
#	sortext pdf
# znajdzie wszystkie PDF (również w podkatalogach)i wrzuci do jednego katalogu

for i in "$@" ;do 
	mkdir $i 2>/dev/null
	find . -xtype f -iname \*.$i -exec mv '{}' ./$i/ \; 2>/dev/null
done
