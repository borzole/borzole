#!/bin/bash

# losowo aktualizuje paczki

exec 4> >(grep --color=always \.)
while : ; do
	echo "Upgrade >>> F14: " >&4
	orphans=`package-cleanup --orphans --qf "%{name}" -q `
	N=`echo -e "${orphans}" | wc -l`
	[ $N == 0 ] && exit 0
	R=(`echo "${orphans}" | shuf -n5`)
	echo "pozostało: ${N}: random upgrade: ${R[*]}" >&4
	yum -y upgrade ${R[*]} --skip-broken
done

exec 4>&-
