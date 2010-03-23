#!/bin/bash

# wypisuje historię firefoxa ze wszystkich profili
# ------------------------------------------------------------------------------
query(){
	echo "SELECT url
	FROM moz_places ; "
}
# ------------------------------------------------------------------------------
for db in $HOME/.mozilla/firefox/*/places.sqlite ; do
	sqlite3 $db "$(query)"
done
