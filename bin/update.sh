#!/bin/bash

# yum update (32/64)

dy=${1:-12} # update co 42 godziny, albo z parametru

update='sudo yum --skip-broken -y update'
# ------------------------------------------------------------------------------
today(){
	date +'%F %H:%M'
}
today_h(){
	# czas w godzinach
	echo $(( $(date +%s)/3600 ))
}
# ------------------------------------------------------------------------------
last_update(){
	cat /var/log/yum.log \
		| grep Updated \
		| awk '{print $1" "$2" "$3}' \
		| tail -n 1
	#~ sudo yum history \
		#~ | awk -F'|' '$4 ~ /U/ {print $0}' \
		#~ | head -n 1 \
		#~ | awk -F'|' '{print $3}'
}
last_update_h(){
	echo $(( $(date -d "$LAST_UPDATE" +%s)/3600 ))
}
# ------------------------------------------------------------------------------
LAST_UPDATE=$(last_update)
# może się zdarzyć, że nie ma daty update w logach, ustawiam więc jakąś bardzo odległą
[ ${#LAST_UPDATE} == 0 ] && LAST_UPDATE='1999-01-01 00:00'
# różnica godzin
dx=$(( $(today_h) - $(last_update_h) ))

echo -e Today: '\t\t' $(today)
echo -e Last Update: '\t' $(date +'%F %H:%M' -d"$(last_update)") '-->' ${dx}h from ${dy}h

[[ $dx -lt $dy ]] || {
	echo -----------------------------------------------------------------------
	$update
	32 $update # to mój drugi system w chroot, można skasować
}
