#!/bin/bash
#
# by borzole.one.pl
# VERSION = 2009.12.28 08:15
# ------------------------------------------------------------------------------
# sensors-alarm - komunikat o alarmie polecenia "sensors"
# by borzole.one.pl
#
# Skrypt udaje "demona" więc wystarczy go uruchomić raz przy starcie
# 
# PRZYKŁAD:
# - uruchomienie z domyślnym czasem monitorowania 5min
#		sensors-alarm
# - sprawdza co 10 minut (600s)
#		sensors-alarm 600
# ------------------------------------------------------------------------------
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
# pełne ścieżki do programów
ICON="/usr/local/share/icons/sensors-alarm.png"
# czas w sekundach co ile ma być sprawdzany stan
# domyślnie jest 300s, ale można też przekazać jako drugi parametr do skryptu
CHECKTIME=${1:-300}
# ------------------------------------------------------------------------------
# czcionka: (N)ORMAL, (X)BOLD, (R)ED, (G)REEN, (B)LUE
N="\e[0m" 
X="\e[1;38m" 
r="\e[0;31m"
R="\e[1;31m"
g="\e[0;32m"
G="\e[1;32m"
b="\e[0;34m"
B="\e[1;34m"
# ------------------------------------------------------------------------------
wymaga(){
	# sprawdza zależności skryptu 
	# np.
	# 		wymaga wget zenity notify-send
	for apps in "$@" ; do
		which ${apps} >/dev/null 2>&1
		if [ $? != 0 ] ; then
			echo -e "${R}[ ERROR ] Nie znaleziono programu \"$apps\""
			echo -e "${G}Spróbuj zainstalować:"
			echo -e "\tsu -c'yum install $apps'"
			echo -e "a jeśli zawiedzie, to spróbuj odnaleźć paczkę dostarczającą wymaganą zależność:"
			echo -e "\tsu -c'yum provides \\*bin/$apps'"
			exit 1;
		fi
	done
}
# ------------------------------------------------------------------------------
lock_script(){
	# gdy chcemy mieć uruchomioną tylko jedną jego kopie
	LOCK_SCRIPT="/tmp/lock_script_${0##*/}.pid"
	if [ -f $LOCK_SCRIPT ] ; then
		# jeśli spróbujemy uruchomić drugą kopię skryptu:
		echo -e "${R}[ wychodzę ]${N} plik blokujący skryptu istnieje: $LOCK_SCRIPT"
		exit 0 
	else
		echo -e "${B}[ uruchamiam ]${N} tworzę plik blokujący skryptu: $LOCK_SCRIPT"
		# zawartość pliku blokującego jest mało istotna, ważne by istniał
		echo $$ > $LOCK_SCRIPT
	fi
}
# ------------------------------------------------------------------------------
unlock_script(){
	# mimo, że jest to jedno polecenie to zróbmy funkcję
	# nieszczęściem by było usunąć niewłaściwy plik
	# a tak minimalizujemy prawdomodobieństwo błędu
	rm -f $LOCK_SCRIPT
	echo -e "${B}[ zakonczono ]${N} usuwam plik blokujący skryptu: $LOCK_SCRIPT" 
}
# ------------------------------------------------------------------------------
msg(){
	TITLE="sensors-alarm"
	INFO="$OUTPUT"
	# wyskakujące okienko z powiadomieniem
	notify-send --urgency critical --expire-time 4000 --icon $ICON "$TITLE" "$INFO"
	# ikona zenity w zasobniku
	zenity --notification --window-icon $ICON --text "$INFO"
	# po kliknięciu na ikonę (kod wyjścia 0) dostaniemy pełne okienko z informacją 
	if [ $? == 0 ] ; then
		zenity --question --window-icon $ICON --title "$TITLE" --text "$INFO" \
			--ok-label="monitoruj dalej" \
			--cancel-label="wyłącz demona " 
		[ $? != 0 ] && exit $?
	fi
}
# ------------------------------------------------------------------------------
main(){
	OUTPUT=$(sensors | grep -i alarm)
	# warunek decydujący o powiadomieniu
	[ "$OUTPUT" != '' ] && msg
}
# ------------------------------------------------------------------------------
demon(){
	# prosty trik pozwalający na pracę ciągłą
	main
	sleep $CHECKTIME
	demon
}
# ------------------------------------------------------------------------------
# sprawdź zależności skryptu 
wymaga zenity notify-send
# zapewnij pojedyńcze uruchomienie
lock_script
# usuń plik blokujący nawet przy nieprzewidzianym wyjściu
trap unlock_script EXIT
# uruchom demona
demon
# ------------------------------------------------------------------------------
