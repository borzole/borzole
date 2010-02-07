#!/bin/bash

# by borzole ( jedral.one.pl )

for p in * ; do
	hg addremove $p 2>/dev/null
done

hg commit -m " -- $@"

hg push  https://borzole.googlecode.com/hg
