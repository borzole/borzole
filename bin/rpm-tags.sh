#!/bin/bash

# wypisuje tagi rpm na przykładzie paczki mc

for tag in $(rpm --querytags) ; do
	echo -n "$tag : "
	rpm -q --qf "%{$tag}\n" mc
done | less
