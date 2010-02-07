#!/bin/bash

# win2utf - konwertuje kodowanie zawartości plików
# by borzole.one.pl
file="$1"

# kodowanie
from=cp1250
to=utf-8

mkdir -p ./$to 2>/dev/null
iconv -f $from -t $to -o ./$to/"$file" "$file" 

#---------------------------------------------------------------------
#alias iso2utf='iconv -f iso-8859-2 -t utf-8'
#alias utf2iso='iconv -f utf-8 -t iso-8859-2'
#alias win2utf='iconv -f cp1250 -t utf-8'
#alias win3utf='recode cp1250..utf-8'

# function win2utf(){
#	iconv -f cp1250 -t utf-8 $1 > $1-utf
# }

# co to za plik
# file plik

# sprawdzanie kodowania pliku
# $ enca srpm.sh 
#Universal transformation format 8 bits; UTF-8
