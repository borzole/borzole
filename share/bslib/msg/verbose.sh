#!/bin/bash

verbose(){
	# wyświetl tylko pod warunkiem:
	[[ $VERBOSE == 0 ]] && echo -e "$@" || return 0
}
