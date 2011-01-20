#!/bin/bash

# kopiowanie w konsoli z paskiem postępu
# pv - monitor the progress of data through a pipe

source_file="$1"
destination_file="$2"

cat "$source_file" | pv -s 100g -p -e -r > "$destination_file"
