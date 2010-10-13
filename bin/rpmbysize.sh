#!/bin/bash

# rpm by size
# http://wiki.fedora.pl/wiki/Kt%C3%B3re_programy_zajmuj%C4%85_najwi%C4%99cej_miejsca

#~ package-cleanup -q --leaves --all
#~ rpm -qa open\*

${@:-rpm -qa} --qf "%40{name} : %20{version} : %10{size} \n" \
	| sort -u -k 5 -g \
	| while IFS= read -r line
	do
		size=$(awk '{print $NF}' <<<$line)
		size=$(echo "scale=3; $size/1024/1024" | bc | sed -e 's:^\.:0.:')
		echo -e "$line" | sed -e 's:[0-9]*.[0-9]*$:  '$size'MB:g'
	done
