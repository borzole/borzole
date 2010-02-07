#!/bin/bash
# by borzole ( jedral.one.pl )
VERSION=2010.02.04-14.29
# ------------------------------------------------------------------------------
# bslang - generuje plik do włumaczenia
# ------------------------------------------------------------------------------
SCRIPT=$1

sed -e '
	s/\ \ */\n/g
	s/[\$\"\:]/\n/g
	' $SCRIPT \
	| grep "MSG_" \
	| xargs -i echo "{}=\"\"" \
	| tee -i $LANG

echo "Wynik zapisano do pliku: $LANG"
