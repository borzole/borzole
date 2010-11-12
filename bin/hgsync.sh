#!/bin/bash

# a to jest skrypt, który aktualizuje repozytorium skryptów
# demon fsniper monitoruje folder i przy każdej zmianie uruchamia ten skrypt

# lokalny klon repo
mkdir -p ${HG:=$HOME/studio/borzole.googlecode.com/hg}
# ------------------------------------------------------------------------------
rsync_mk(){
	mkdir -p $2
	rsync -aL $1/ $2
}

# wszystko robimy na kopii!
# sprzątamy dla nowych ( zostaje $HG/.hg i pliki )
find $HG -mindepth 1 -maxdepth 1 -xtype d ! -iname \.\* -exec rm -rf '{}' &>/dev/null \;
# root stricte 'korzeń'
R=/usr/local

rsync_mk {$R,$HG}/bin
rsync_mk {$R,$HG}/share/bslib
rsync_mk $R/share/nautilus-scripts $HG/nautilus-scripts
# ------------------------------------------------------------------------------
OLDPWD="$PWD"
cd "$HG"

hg addremove
echo " ----- STATUS -----"

#~ hg debugsetparents default
hg st
MSG="$@"
[[ $@ ]] &&
{
	hg commit -m "$MSG"
	hg push -f https://borzole.googlecode.com/hg
}
# ------------------------------------------------------------------------------
cd "$OLDPWD"
