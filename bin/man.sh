#!/bin/bash

# silnik

xterm -geometry 200x50+0+0 -e \
"help $@ &>/dev/null && help -m $@ | less || man $@"
