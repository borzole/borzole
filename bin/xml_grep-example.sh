#!/bin/bash


URL=http://dl.dropbox.com/u/409786/pub/repo/index.html
# znaleźć ścieżkę za pomocą firebug'a
XPATH='//*[@id="opis"]'

xml_grep -t  "$XPATH" "$URL" 2>/dev/null   

# jest jeszcze "xmlstarlet" ale tylko czysty xml działał.
