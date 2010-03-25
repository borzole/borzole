#!/bin/bash

egrep --color=always '# *@TODO' -R \
	/usr/local/bin/* \
	/usr/local/sbin/* \
	| sed -e 's/ *# *//g'
