#!/bin/bash

# tar & bzip2 -9

[[ $# -eq 0 ]] && { echo "Użycie: bz9.sh plik"; exit 1;}
tar -cvf - "$1" | bzip2 -9 - > "${1}.tar.bz2"
