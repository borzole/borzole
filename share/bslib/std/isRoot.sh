#!/bin/bash

isRoot(){
	# tylko root może uruchomić ten skrypt
	if [ $(whoami) != root ] ; then
		Error "Brak dostępu : musisz mieć prawa 'root' ( su - , sudo ) "
		exit 0
	fi
}
