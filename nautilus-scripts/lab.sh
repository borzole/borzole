#!/bin/bash

# minimum Bash 4
[[ ${BASH_VERSINFO[0]} -ge 4 ]] || exit 1

# enable **
shopt -s globstar
# enable ** for dotfiles
shopt -s dotglob

# sprawdźmy zależności
id3info -V || exit 1

r=${1:-${NAUTILUS_SCRIPT_CURRENT_URI#file://}}

for f in "$r"/** ; do

done
