#!/bin/bash

# cr2lf.sh -- zamień pliki tekstowe z windy na linuksowe
# winda kończy wiersza znakiem powrotu karetki, a unixy znakiem nowej lini

tr '\r' '\n' < $1
