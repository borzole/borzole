#!/bin/bash

# komunikat o przekroczeniu ustalonej zajętość dysku
# źródło: http://www.cyberciti.biz/faq/mac-osx-unix-get-an-alert-when-my-disk-is-full/


# rozbudowany by borzole ( jedral.one.pl )
VERSION=2010.01.13-20.33

# Skrypt udaje "demona" więc wystarczy go uruchomić raz przy starcie
#
# PRZYKŁAD:
# - uruchomienie z domyślnym progiem zajętości
#		diskused
# - uruchomienie z progiem 22%
#		diskused 22
# - uruchomienie z progiem 90% sprawdzanym co 5 minut (300s)
#		diskused 90 300
# ------------------------------------------------------------------------------
export DISPLAY=:0.0
export LANG=pl_PL.UTF-8
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
# ------------------------------------------------------------------------------
ICON="/usr/local/share/icons/diskused.png"
# próg zajętości w % (musi być poniżej 100)
# domyślnie jest 80%, ale można też przekazać jako parametr do skryptu
THRESHOLD=${1:-80}
# czas w sekundach co ile ma być sprawdzany stan partycji
# domyślnie jest 60s, ale można też przekazać jako drugi parametr do skryptu
CHECKTIME=${2:-60}
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
requires(){
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
_msg(){
	# wyskakujące okienko z powiadomieniem
	notify-send --urgency critical --expire-time 4000 --icon $ICON "$TITLE" "$INFO"
	# ikona zenity w zasobniku
	zenity --notification --window-icon $ICON --text "$INFO"
	# DEBUG - parametr $? określa kod wyjścia programu
	# echo $? | zenity --text-info
	# po kliknięciu na ikonę (kod wyjścia 0) dostaniemy pełne okienko z informacją
	if [ $? == 0 ] ; then

		zenity --question --window-icon $ICON --title "$TITLE" --text "$INFOLONG" \
			--ok-label="Ok : monitoruj dalej" \
			--cancel-label="Wiem! : wyłącz demona "
		[ $? != 0 ] && exit $?
	fi
}
# ------------------------------------------------------------------------------
_add_msg(){
	SHOWMSG=TRUE
	# treść powiadomienia
	INFO+="
	partycja [ $FS ] zajęta w $CURRENT% "
}
# ------------------------------------------------------------------------------
_check_disk(){
	# punkt montowania partycji
	FS="$1"
	OUTPUT=($(LC_ALL=C df -P ${FS}))
	# stan naszej partycji
	CURRENT=$(echo ${OUTPUT[11]} | sed 's/%//')
	# warunek decydujący o powiadomieniu
	[ $CURRENT -gt $THRESHOLD ] && _add_msg
}
# ------------------------------------------------------------------------------
main(){
	# załaduj do tablicy listę zamontowanych partycji
	MOUNTED=( $(df -l | awk -F"% " '{print $2}' | grep -v '/dev/shm') )
	# sprawdź każdą partycję
	for p in "${MOUNTED[@]}" ; do
		_check_disk $p
	done
	# jeśli próg został przekroczony to wyświetl powiadomienie
	if [ "$SHOWMSG" == "TRUE" ] ; then
		TITLE="Mało miejsca na dysku!"
		INFOLONG="Przekroczono ustalony próg $THRESHOLD% zajętości partycji !
	usuń kilka plików zanim zrobi się za ciasno!\n$INFO"
		_msg
	fi
}
demon(){
	# prosty trik pozwalający na pracę ciągłą
	main
	sleep $CHECKTIME
	# "wyzeruj" parametry
	SHOWMSG=FALSE
	INFO=""
	demon
}
# sprawdź zależności skryptu
requires zenity notify-send
# zapewnij pojedyńcze uruchomienie
lock_script
# usuń plik blokujący nawet przy nieprzewidzianym wyjściu
trap unlock_script EXIT
# uruchom demona
demon
# ------------------------------------------------------------------------------
