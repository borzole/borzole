#!/bin/bash

# źródło: http://blog.y3ti.pl/2008/12/lista-zadan-crona-dla-wszystkich-userow/

if [ $(id -u) != 0 ] ; then
	echo "Uruchom jako root"
	su -c $0
	exit
fi

users=`cut -d: -f1 /etc/passwd | sort`

for user in $users ; do
	tasks=`sudo crontab -l -u $user 2> /dev/null`

	if [ "$tasks" != "" ] ; then
		echo -e "\033[31;1m**** $user **** \033[0m"
		echo -e "$tasks"
		echo
	fi
done
