#!/bin/bash

# manh - lista stron man plików *.h
# by borzole.one.pl

echo -e "Strony man /usr/include/*.h"
echo -e "Wybierz numer, wyjście: Ctl+D"

select p in `ls /usr/include/*.h | cut -d/ -f4`; do 
	man $p 
done
