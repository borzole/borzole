#!/bin/bash

is_root(){
	# tylko root może uruchomić ten skrypt
	if [ $(whoami) != root ] ; then
		Error "Brak dostępu : musisz mieć prawa 'root' ( su - , sudo ) "
		exit 0
	fi
}
