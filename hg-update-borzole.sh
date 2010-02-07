#!/bin/bash

# by borzole ( jedral.one.pl )

obj="bin"
obj+=" share/bslib"
obj+=" share/nautilus-scripts"

for p in $obj ; do
	hg addremove $p 2>/dev/null
done

hg commit -m " -- $@"

hg push  https://borzole.googlecode.com/hg
