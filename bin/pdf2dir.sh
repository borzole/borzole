#!/bin/bash

# rozwala dokument PDF na pojedyńcze strony

src="$1"
dir="${src}.d"
mkdir -p "$dir"

pdftk "$src" burst output "${dir}"/strona%03d.pdf

#~ [ $? != 0 ] && rm -f "$src"
