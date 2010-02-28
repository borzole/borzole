#!/bin/bash

# bslib - "Bash Shell Library" ...czyli biblioteka skryptów (funkcji)
# ------------------------------------------------------------------------------
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
#~ export DISPLAY=:0.0
#~ export LANG=pl_PL.UTF-8
# ------------------------------------------------------------------------------
Verbose(){
	if [ "$VERBOSE" == "0" ] ; then	
		echo -e "$@"
	fi
}
# ------------------------------------------------------------------------------
setDefault(){
	# ustaw parametr z domyślną wartością o ile nie istnieje
	local thisVARIABLE=$1
	local thisVALUE=$2
	if [ ! -z $thisVARIABLE -a ! -z $thisVALUE ] ; then
		eval $(echo -e "$thisVARIABLE=$thisVALUE")
		Verbose setDefault: $thisVARIABLE=$thisVALUE
	else
		echo -e "Nie ustawiono $thisVARIABLE" >2&
	fi
}
# ------------------------------------------------------------------------------
BslibSource(){
	[ -z $MSG_LOADING_SCRIPTS ] && MSG_LOADING_SCRIPTS="Loading scripts from folder"
	
	Verbose "$MSG_LOADING_SCRIPTS: $BSLIB_DIR"
	for thisSCRIPT in $( find "$BSLIB_DIR" -xtype f -iname \*.sh ) ; do
		if [ -f "$thisSCRIPT" ] ; then
			thisCMD="source '$thisSCRIPT'"
			eval $thisCMD
			Verbose $thisCMD
		fi
	done
}
# ------------------------------------------------------------------------------
BslibSourceLang(){
	if [ -d $BSLIB_DIR/lang ] ; then
		thisLANG=$BSLIB_DIR/lang/$LANG
		if [ -f $thisLANG ] ; then
			thisCMD="source '$thisLANG'"
			eval $thisCMD
			Verbose $thisCMD
		else
			echo -e "LANG: $thisLANG" >&2
			exit
		fi
	fi
}
################################################################################
# Go!
################################################################################
# "zachęta" wbudowanego polecenia "select"
PS3=':: ctrl+d :: wybierz nr:: '
# czcionka: (N)ORMAL, (X)BOLD, (R)ED, (G)REEN, (B)LUE
declare -A C # -A option declares associative array.
C[N]="\e[0m" 
C[X]="\e[1;38m" 
C[r]="\e[0;31m"
C[R]="\e[1;31m"
C[g]="\e[0;32m"
C[G]="\e[1;32m"
C[b]="\e[0;34m"
C[B]="\e[1;34m"
# ustaw jeśli nie ustawiono
[ -z "$VERBOSE" ] && VERBOSE=0
# folder ze skryptami
setDefault BSLIB_DIR /usr/local/share/bslib
# ------------------------------------------------------------------------------
if [ -d $BSLIB_DIR ] ; then
	BslibSourceLang
	BslibSource
else
	echo -e "BSLIB_DIR: $BSLIB_DIR" >&2
	exit 1
fi
# ------------------------------------------------------------------------------
