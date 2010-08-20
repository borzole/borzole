#!/bin/bash

# Applications Categories
# wypisuje kategorie

grep -h ^Categories /usr/share/applications/* \
	| cut -d= -f2 \
	| sed -e 's/;/\n/g' \
	| sort -u
