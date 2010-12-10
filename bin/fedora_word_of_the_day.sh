#!/bin/bash

# słówko na dziś

rpm=$(rpm -qa --qf '%{name}\n'| shuf -n 1)
doc=`rpm -qd $rpm`

echo Dokumentacja $rpm

PS3='[ctrl+d] ? '

echo " -- HTML / TXT --"
select d in `echo -e "$doc" | grep /usr/share/doc/` ; do
	xdg-open $d
done

echo " -- INFO --"
select d in `echo -e "$doc" | grep /usr/share/info/` ; do
	pinfo $d
done

echo " -- MAN --"
select d in `echo -e "$doc" | grep /usr/share/man/` ; do
	man $d
done

