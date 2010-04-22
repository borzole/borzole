#!/bin/bash

URL='http://money.rediff.com/'
echo -e "
# Różne sposoby na rozwiązanie tego samego problemu
# skrypt pobiera indeks BSE ze strony $URL
"
# ------------------------------------------------------------------------------
echo -n "lynx | awk + tr + cut  >"
lynx --dump "$URL" | awk '/BSE LIVE/{ print $5}' | tr -d "," | cut -d'.' -f1
# ------------------------------------------------------------------------------
echo -n "lynx | awk             >"
lynx --dump "$URL" | awk '/BSE LIVE/{ gsub(/,|\.[0-9]+/, ""); print $5}'
# ------------------------------------------------------------------------------
echo -n "lynx | sed             >"
CSED=/dev/shm/cmd.sed
cat >"$CSED"<<__EOF__
/BSE LIVE/{
	s/,//g
	#   [20]Update Now BSE LIVE      17573.99     +101.43    +0.58%
	#^-------------1---------------^ ^-2-^.^-----------3----------^
	s/\(.*\)\ \([0-9]*\)\.\([0-9]*\ .*\)/\2/g
	p
}
__EOF__
lynx --dump "$URL" | sed -n -f "$CSED"
# ------------------------------------------------------------------------------
echo -n "curl | sed             >"
cat >"$CSED"<<__EOF__
/id="bseindex"/{
	s/<[^>]*>//g
	s/,//g
	s/[^0-9\.]//g
	s/\.[0-9]*//g
	p
}
__EOF__
curl -s "$URL" | sed -n -f "$CSED"
# ------------------------------------------------------------------------------
