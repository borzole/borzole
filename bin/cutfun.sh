#!/bin/bash

# cutfun - wycinanie funkcji ze skryptu
# by borzole.one.pl

# użycie:
# 1. zrób kopię swojego skryptu
# 2. zrób kopię swojego skryptu !!!
# 		cutfun /home/lucas/start.sh

SCRIPT="$1" 
# tu wędrują wycięte funkcje
PLUGIN="${SCRIPT}_plugin"

# tymczasowy skrypt parsujący
CUTSCRIPT="/tmp/cutfun_wycinanka.sh"

trap $( rm -f $CUTSCRIPT 2>/dev/null ) EXIT

get_funlist()
{
	# jeśli funkcje to blok postaci "nazwa234 ()..." wówczas mamy listę funkcji
	# obcinamy nazwy na spacji lub (
	grep '^[a-zA-Z0-9\_\-]*\ *()' $SCRIPT | cut -d' ' -f1 | cut -d\( -f1| sort 
}

parser_create_file()
{
	FUNLIST=( $(get_funlist) )
	mkdir -p "$PLUGIN"
	for fun in ${FUNLIST[@]} ; do
		echo -e "echo '#!/bin/bash' > $PLUGIN/$fun" 
		echo -e "sed -n -e '/^${fun}\\ *()/,/^}/p' $SCRIPT >> $PLUGIN/$fun" 
		echo -e "sed -e '/^${fun}\\ *()/,/^}/d' $SCRIPT -i" 
		echo -e "chmod +x $PLUGIN/$fun" 
	done
}

parser_create_file > $CUTSCRIPT
sh $CUTSCRIPT
rm -f $CUTSCRIPT

# -------------------------------------------------------------------------------------------------
# mała podpowiedź
echo "
[ Export zakończony ]
: oczyszczonony skrypt = $SCRIPT
: wyeksportowane funkcje = $PLUGIN

[ Jak teraz zaimportować te funkcje do skryptu? ]
: wystarczy wstawić na początku skryptu:
 ------start-----
# importowanie funkcji z katalogu
for script in $PLUGIN/* ; do
	source \$script
done
 ------stop-----
"
