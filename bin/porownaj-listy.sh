#!/bin/bash

# porownajuje dwie proste listy

OLD=$1
NEW=$2
for p in $(cat $OLD $NEW | sort -u) ; do
	grep $p $NEW || echo $p >>brakujace.log
	grep $p $OLD || echo $p >>nadmiarowe.log
done
