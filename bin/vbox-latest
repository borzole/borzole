#!/bin/bash

# Powiadomienie o nowej wersji VirtualBox
# by borzole.one.pl

# wymaga: curl, mutt

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#DOKOGO="kowalski@gmail.com"
DOKOGO=$(my mail)

# wersje VirtualBox plik z wersją na serwerze
PLIK=LATEST.TXT
#PLIK=LATEST-BETA.TXT

msg(){
	# lokalne powiadomienie
	echo -e "Dostępna jest wersja VirtualBox $LATEST"
	# powiadomienie na maila
	echo -e "Dostępna jest wersja VirtualBox $LATEST

a) pobierz:	http://www.virtualbox.org/wiki/Linux_Downloads

b) katalog:	http://download.virtualbox.org/virtualbox/$LATEST
	
	"| mutt -s "Jest nowy VirtualBox $LATEST !" $DOKOGO 
	
	# a tak sobie zrobiłem, że jak kod wyjścia jest "9" to program ma się zatrzymać i nie sprawdzać puki mu nie pozwolę :)
	return 9
}

LOCAL=`VBoxManage -v | cut -dr -f1`
LATEST=`curl -s http://download.virtualbox.org/virtualbox/$PLIK`

[ "$LATEST" == "$LOCAL" ] && echo "brak aktualizacji" || msg

