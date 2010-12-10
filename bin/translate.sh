#!/bin/bash

# tłumacz słówek na podstawie słownika

declare -A M # bash 4

dict(){
	M["$1"]=$2
}

translate(){
	local IFS=.
	local i
	for w in $@ ; do
		((i++)) && [ $i -gt 1 ] && echo -n .
		echo -n ${M["$w"]}
	done
	echo
}
# słownik
dict Inbox Odebrane
dict Sent Wyslane
dict Outbox Wychodzace
dict Trash Kosz
dict Oferty oferty
# test
translate Inbox.Oferty # Odebrane.oferty
translate Inbox # Odebrane
translate Outbox #Wychodzące
translate Sent #Wysłane

translate Trash.Sent.Trash.Outbox #Kosz
