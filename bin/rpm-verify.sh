#!/bin/bash

# sprawdź paczki i przeinstaluj błędne

VERIFY=/var/log/verify.log
RPMS=/var/log/rpms.log

# tylko root może uruchomić ten skrypt
[ $(id -u) != 0 ] && { echo Uruchom jako root ; exit 1 ; }

# wygeneruj log, jeśli nie istnieje
[ -f $VERIFY ] && echo -- log $VERIFY już istnieje || rpm -qa -V | tee -ai $VERIFY

# wychwyć pliki z logu
FILES=$(sed -e 's:\ :\n:g ; s/://g' $VERIFY | grep ^/ | sort -u)

# sprawdź do których paczek należą
rpm -qf $FILES | sort -u | tee -ai $RPMS

echo -- log $RPMS zawiera listę błędnych paczek
