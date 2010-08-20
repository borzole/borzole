#!/bin/bash

# przykład tokenizacji

# jakieś tam pliki z danymi
INPUT=/tmp/test_in.txt
SWITCH=/tmp/test_switch.txt
OUTPUT=/tmp/test_out.txt

cat >$INPUT<<__EOF__
ala "" ma kota "" a kot ma "" ale
__EOF__

cat >$SWITCH<<__EOF__
dwa;01;34;ala
__EOF__

# ------------------------------------------------------------------------------
set_tab(){
	# zmieniamy separator pól wejściowych na średnik
	local IFS=';'
	# ładujemy plik do tablicy
	TAB=( $(cat $SWITCH) )
}

set_tab

# pracujemy na kopii
cat $INPUT > $OUTPUT

# dla każdego elementu tablicy...
for p in ${TAB[@]}
do
	# podmień pierwszy napotkany tekst pasujący do wzorca
	# opcja "-i" wykonuje operację bezpośrednio na pliku
	sed -e 's/\"\"/'$p'/' $OUTPUT -i
done
# pokaż plik
cat $OUTPUT

# ------------------------------------------------------------------------------
# ala dwa ma kota 01 a kot ma 34 ale
