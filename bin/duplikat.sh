#!/bin/bash

# wyszukuje duplikaty plików w katalogu na podstawie sum SHA1

[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1
shopt -s globstar
shopt -s dotglob

SHA1SUM=/dev/shm/${0##*/}-sha1sum-${RANDOM}
DUPLIKAT=/dev/shm/${0##*/}-duplikat-${RANDOM}
trap "rm -f $SHA1SUM $DUPLIKAT" EXIT

r="${1:-$PWD}"

echo -e "* Obliczam sumy kontrolne plików w katalogach"
for p in "$r"/** ; do
	[[ -d $p ]] && echo $p
	[[ -f $p ]] && sha1sum "$p" >>$SHA1SUM
done
echo -e "* Szukam duplikatów"
for s in $(cut $SHA1SUM -d' ' -f1 | sort -u) ; do
	echo -n "."
	[[ $(grep $s $SHA1SUM | wc -l) -gt 1 ]] &&
	{
		echo -n "#"
		echo "--------------------------------------------------------" >>$DUPLIKAT
		grep $s $SHA1SUM | cut -d' ' -f3- >>$DUPLIKAT
	}
done
echo -e "\n* Zapisuje wyniki"

DATA=$(date +%Y.%m.%d-%H.%M.%S-%N)
cp $SHA1SUM $HOME/${0##*/}.sha1sum.${DATA}.log
cp $DUPLIKAT $HOME/${0##*/}.duplikat.${DATA}.log

