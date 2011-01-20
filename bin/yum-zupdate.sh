#!/bin/bash

# yum-zupdate -- instalator aktualizacji

# Użycie:
# 	jednorazowo np. do cron
# 		/usr/local/sbin/yum-zupdate
#	jako demon na końcu pliku  "/etc/rc.d/rc.local" dodać wpis tej postaci
# 		/usr/local/sbin/yum-zupdate -d &
#	można skorygować czas sprawdzania aktualizacji podając go jako parametr w sekundach
#	np. 20min (1200 sekund)
# 		/usr/local/sbin/yum-zupdate -d 1200 &
# by borzole ( jedral.one.pl )
VERSION=2010.03.05-17.35
# ------------------------------------------------------------------------------
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
. bslib.sh || exit 1
# ------------------------------------------------------------------------------
# czas w sekundach co ile ma być uruchamiany demon (1800 = 30 minut)
# ikona
ICON="/usr/share/pixmaps/yum-zupdate.svg"
# powiadomienia
TITLE="Dostępne są aktualizacje !"
MESSAGE="Aktualizacja systemu w toku!"
# ------------------------------------------------------------------------------
menu_update(){
	# wyświetla menu do zaznaczeniem, które pakiety zaktualizować
	zenity --title "$TITLE" --text "$INFO" --window-icon $ICON \
		--width=600 --height=500 \
		--list  --checklist \
		--column="zaznacz" --column "rpm" --column "wersja" --column "repo" \
		$(echo "$CURRENT" | xargs -i echo TRUE '{}' ) \
		--separator " "  --multiple \
		--print-column=2
}
# ------------------------------------------------------------------------------
run_update(){
	# wyskakujące powiadomienie
	notify-send --urgency critical --expire-time 4000 --icon $ICON "$TITLE" "$INFO" &
	# ikona w schowku
	zenity --notification --window-icon $ICON --text "$INFO"
	# jeśli kliknięto ikonę
	if [ $? == 0 ] ; then
		# wynikiem jest lista progrmów do aktualizacji
		YUMUPDATE=$(menu_update)
		if [ $? == 0 ] ;then
			# nieklikalna ikona w schowku z informacją, że update trwa
			exec 4> >(zenity --notification --listen --window-icon $ICON )
			echo "tooltip:$MESSAGE" >&4
			echo "message:$MESSAGE" >&4
			# wykonuje aktualizację
			yum update -y --skip-broken $YUMUPDATE
			# powiadomienie o wyniku
			if [ $? == 0 ] ;then
				YUMUPDATE_N=$( echo $YUMUPDATE | sed -e 's/\ \ */\n/g' )
				echo -e "$YUMUPDATE_N" | zenity --text-info --title="Zakończono aktualizacje!"
			else
				zenity --warning --title="$TITLE" --text="<b>Wystąpiły pewne problemy!</b>"
			fi
			# zamknięcie ikony w schowku
			exec 4>&-
		fi
	fi
	# KONIEC
}
# ------------------------------------------------------------------------------
main(){
	# sprawdza aktualizacje
	CURRENT=$(yum check-update -q 2>/dev/null | grep -iv error)
	if [ "$CURRENT" != '' ] ; then
		ILE=$( echo -n "$CURRENT" | wc -l )
		INFO="Ilość aktualizacji: $ILE"
		echo -e $INFO
		run_update
	fi
}
# ------------------------------------------------------------------------------
demon(){
	# dzięki temu będzie chodził w kółko
	main
	sleep $CHECKTIME
	demon
}
# ------------------------------------------------------------------------------
requires yum zenity notify-send
script_lock
trap script_unlock EXIT

if [[ $# -eq 0 ]] ; then
	main
elif [[ $1 == '-d' ]] ; then
	CHECKTIME=${2:-1800}
	demon
else
	echo Nieznany parametr >&2
	exit 1
fi
