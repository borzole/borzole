#!/bin/bash

# przełącznik paska adresu nautilusa: guziki/ścieżka

cmd='gconftool-2 /apps/nautilus/preferences/always_use_location_entry'
switch="$cmd --set --type=Boolean"

[ $($cmd --get) = 'true' ] && $switch false || $switch true
