#!/bin/bash

DebugRun(){
	if [ "$DEBUG" == "TRUE" ] ; then	
		Debug " -- START -- "
		eval "$@"
		Debug " -- STOP --  "
	fi
}
