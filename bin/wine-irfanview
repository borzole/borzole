#!/bin/bash

# dzieki niemu mozna double-clickiem w nautilusie otwierac pliki graficzne w IrfanView

IRFANVIEW="C:\\Program Files\Irfanview\i_view32.exe"
ROOT_DRIVE="Z:\\"
for arg
do
	wine "$IRFANVIEW" "${ROOT_DRIVE}$(echo "$arg" | sed 's/\//\\/g')"
done
