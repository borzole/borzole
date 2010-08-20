#!/bin/bash

# kurs linuxa -- buahahahahah

PATH=/bin:/sbin:/usr/bin:/usr/sbin

IFS=:
for p in $PATH; do
	for i in $p/*; do
		pinfo ${i##*/}
	done
done
