#!/bin/bash

# by borzole ( jedral.one.pl )

for p in * ; do
	hg add $p 2>/dev/null
done

hg commit -m " -- $@"

hg push  https://borzole.googlecode.com/hg
