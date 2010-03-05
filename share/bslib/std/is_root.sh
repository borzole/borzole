#!/bin/bash

is_root(){
	# tylko root może uruchomić ten skrypt
	if [ $(whoami) != root ] ; then
		echo -e "Brak dostępu : musisz mieć prawa 'root' ( su - , sudo ) " >&2
		exit 0
	fi
}
