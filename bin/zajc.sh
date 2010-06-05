#!/bin/bash

export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# potok do komunikacji
pipe=/dev/shm/server-${0##*/}.pipe
# magiczne słówko ;P do komunikacji
sig=magic
# domyślny terminal
TERM='xterm -hold -e '
##################### do ustawienia wedle "widzimisię" #########################
uruchom(){
	$TERM service network start
}
# ------------------------------------------------------------------------------
zatrzymaj(){
	$TERM service network stop
}
# ------------------------------------------------------------------------------
status(){
	$TERM ping -c 4 onet.pl
}
# ------------------------------------------------------------------------------
update(){
	$TERM yum update
}
# ------------------------------------------------------------------------------
menu(){
	zenity --title="${0##*/}" --text "Połączenie z internetem" \
		--width=250 --height=220 \
		--list  --radiolist \
		--column="" --column "zwracana funkcja" --column "Opis" \
		"FALSE" "uruchom" "Połącz z internetem"\
		"FALSE" "zatrzymaj" "Rozłącz" \
		"TRUE" "status" "Sprawdź ping" \
		"FALSE" "update" "Aktualizuj system" \
		"FALSE" "exit" "Zatrzymaj serwer" \
		--print-column=2 --hide-column=2
}
############################## bebechy skryptu #################################
init(){
	# Inicjuje serwer
	# Utwórz plik potoku, do którego użytkownik może wpisać polecenie
	mkfifo -m 622 $pipe
	# przechwyć wyjście/przerwanie skryptu
	trap exit_handle EXIT
	# przejdź w stan czuwania
	kernel
}
# ------------------------------------------------------------------------------
exit_handle(){
	# funkcja wykonywana przed zakończeniem skryptu
	rm -f $pipe
	echo "Bye bye!"
}
# ------------------------------------------------------------------------------
kernel(){
	# nasłuchiwanie poleceń z potoku
	local cmd
	while read -r cmd <$pipe ; do [ $cmd == $sig ] && config ; done
}
# ------------------------------------------------------------------------------
config(){
	# Obsługuje menu
	local run=$(menu) && $run
}
# ------------------------------------------------------------------------------
server(){
	if [ -p $pipe ] ; then
		# Serwer może być uruchomiony tylko raz,
		# więc przy próbie uruchomienia kolejnych instancji wychodzimy
		echo "Serwer $0 jest już uruchomiony ..." >&2
		exit 1
	else
		# Skoro serwer nie działa, to tu go uruchamiamy
		echo "Uruchamiam serwer $0 ..."
		init
	fi
}
# ------------------------------------------------------------------------------
client(){
	# jeśli serwer działa to wyślij polecenie rozpoczęcia komunikacji
	[ -p $pipe ] && echo $sig > $pipe || echo "Serwer nie jest uruchomiony" >&2
}
# ------------------------------------------------------------------------------
error(){
	# funkcja przyjmuje parametry z poteku.
	#@TODO: błędy wyskakują z opuźnieniem
	local LINE
	# status, czy była wiadomość błędu
	local ERROR=""
	while read -r LINE ; do
		ERROR+="$LINE\n"
	done
	[[ -n $ERROR ]] && zenity --error --title="${0##*/}" --width=200 \
		--text="<b>Wystąpił błąd!</b>\n$ERROR" 2>/dev/null
}
# ------------------------------------------------------------------------------
# przekieruj wszelkie błędy
exec 2> >(error)
# uruchom inną funkcję w zależności od tego czy to root/user
[[ $(id -u) -eq 0 ]] && ( server & ) || client
