#!/bin/bash

# minimalistyczny GUI
# VBoxSDL --startvm fedora-server
# ------------------------------------------------------------------------------
# http://www.tldp.org/LDP/abs/html/devref1.html
# exec 5<>/dev/tcp/jedral.one.pl/80
# echo -e "GET / HTTP/1.0\n" >&5
# cat <&5
# ------------------------------------------------------------------------------
NAME=fedora-server
IP=192.168.0.101
ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg
# ------------------------------------------------------------------------------
is_run(){
	VBoxManage -q list runningvms | grep ^\"$NAME\"
}
# ------------------------------------------------------------------------------
notify_http(){
	# /dev/tcp redirection to check Internet connection.
	# Try to connect. (Somewhat similar to a 'ping' . . .)
	echo "HEAD / HTTP/1.0" >/dev/tcp/${IP}/80
	if [ $? == 0 ] ; then
		# jeśli jest odp. to powiadom, że serwer działa
		notify-send -u critical -i $ICON "$NAME" "wirtualny serwer $IP już działa"
	else
		# jeśli nie ma odpowiedzi to zaczekaj sekundkę i spr. ponownie
		echo -n .
		sleep 1
		$FUNCNAME
	fi
	echo
}
# ------------------------------------------------------------------------------
notify_save(){
	is_run || notify-send -u low -i $ICON "$NAME" "wirtualny serwer mowi dobranoc"
}
# ------------------------------------------------------------------------------
main(){
	is_run
	if [ $? != 0 ] ; then
		# jeśli nie uruchomiona to uruchom
		VBoxHeadless --startvm $NAME --vrdp=off  >/dev/null &
		# TEST: czy dostępna jest już strona
		echo -ne "...oczekuje odpowiedzi z ${IP}:80 "
		notify_http 2>/dev/null
	else
		# inaczej uśpij
		VBoxManage -q controlvm $NAME savestate
		notify_save
	fi
}
# ------------------------------------------------------------------------------
[[ $1 == "--status" ]] && is_run || main

#@TODO: grep 'enabled="1"' $HOME/.VirtualBox/VirtualBox.xml
