#!/bin/bash

# pomysł: http://nfsec.pl/techblog/142
# by jedral.one.pl

# Nazwa i wersja aplikacji
BASE="$0"
NAME="${0##*/}"
VERSION=0.3
# v0.3 - dodanie mini menu na potrzeby skryptu nautilusa
# v0.2 - dodanie opcji usuwania pliku źródłowego

#algorytm szyfrowania
ALG=des3

# ------------------------------------------------------------------------------ 
## kolory
# normalna czcionka
E="\e[0m" 
# bold
B="\e[1;38m" 

red="\e[0;31m"
Red="\e[1;31m"

blue="\e[0;34m"
Blue="\e[1;34m"
# ------------------------------------------------------------------------------
## rysuje linię
linia(){
	# domyślnie jest "_", ale może rysować linię ze znaku podanego jako parametr
	znak=${1:-_}
	for i in {1..40}; do echo -en ${znak}; done ; echo
}
# ------------------------------------------------------------------------------
## mini pomoc
help(){
	echo -e "${blue}Aby uzyskać ${Red}pomoc${blue} wpisz: ${E}${B}\n ${NAME} -h \n ${NAME} --help${E}"
	exit 0
}
# ------------------------------------------------------------------------------
## dłuższy opis funkcji programu
manual(){
	echo -e "$(linia '~@')\n\n\t${Blue}${NAME}${E} - szyfrowanie plików przy pomocy OpenSSL\n\n$(linia '~@')\n
${Red}Użycie: ${E}${NAME} [opcje] [[opcja] [plik]] ...
$(linia -)
${Red}Opcje: ${E}
	${B}-c plik, --crypt plik ${E}
		szyfruje plik 
	${B}-e plik, --encrypt plik ${E}
		odszyfrowuje plik
	${B}-d plik, --delete plik${E}
		usuń plik źródłowy (dosłownie ${red}rm -rf plik${E}), ustawiać tylko po operacji crypt/encrypt
	${B}--cli plik ${E}
		mini menu wyboru -e/-c/-d na potrzeby nautilus-skrypt
	${B}-h, --help ${E}
		wyświetla pomoc
	${B}-v, --version ${E}
		wersja skryptu
${Red}Opis:${E}
	Program służy do 'szybkiego i łatwego szyfrowania plików/katalogów'
${Red}Przykłady:${E}
	${B}Szyfrowanie pliku:${E}
		${NAME} -c plik
		${NAME} --crypt \"plik ze spacja\"
	${B}Szyfrowanie pliku z usunięciem:${E}		
		${NAME} -c \"plik ze spacja\" --delete
	${B}Odszyfrowanie pliku:${E}
		${NAME} -e plik.des3
	${B}CLI:${E}
		${NAME} --cli plik.des3
	${B}Skrypt jest idiotoodporny i może łączyć opcje:${E}
		${NAME} -c \"plik ze spacja\" -d --help -e plik666.des3 -v "
}
# ------------------------------------------------------------------------------
## pobierz hasło
haslo(){
	echo -e "\nPodaj ${B}hasło${E} dla ${Blue}$FILE:${E}"
	read -s PASS
	# alternatywnie podać jakiś plik może być z usb:
	# PASS="$(cat ~/.ssh/id_rsa)"
}
# ------------------------------------------------------------------------------
## szyfrowanie
crypt(){
	haslo
	tar -zcvf - "$FILE" | openssl $ALG -salt -k "$PASS" | dd of="${FILE}.des3"
}
# ------------------------------------------------------------------------------
## odszyfrowanie
encrypt(){
	haslo
	dd if="$FILE" | openssl $ALG -d -k "$PASS" | tar zxvf -
}

cli(){
	echo -e "Wybierz operację dla piku: ${Blue}$FILE:${E}"
	echo -e "Exit: Ctrl+D"
	select p in crypt encrypt delete; do
		if [ "$p" = "crypt" ]; then
			"$BASE" -c "$FILE"
		elif [ "$p" = "encrypt" ]; then
			"$BASE" -e "$FILE"
		elif [ "$p" = "delete" ]; then
			rm -rf "$FILE"
			exit $?
		else
			echo "Nie ma takiej opcji, naciśnij: 1, 2, 3"
		fi
	done		
}
# ------------------------------------------------------------------------------
## gdy brak parametrów:
if [ $# -eq 0 ]; then help ; fi

# ------------------------------------------------------------------------------
## obsługa parametrów
while [ $# -gt 0 ]; do
	case "${1}" in
		--crypt | -c )
			FILE="$2"
			crypt
			if [ "$3" = -d ]||[ "$3" = "--delete" ]; then 
				rm -rf "$2"
				shift
			fi
			shift 2
			;;
		--encrypt | -e )
			FILE="$2"
			encrypt
			if [ "$3" = -d ]||[ "$3" = "--delete" ]; then 
				rm -rf "$2"
				shift
			fi
			shift 2
			;;
		--cli )
			FILE="$2"
			cli 
			shift 2
			;;
		--help | -h | --h* )
			manual
			shift
			;;
		--version | -v )
			echo -e "wersja: ${VERSION}" >&2
			shift
			;;
		*)
			echo "nie rozpoznany parametr: $1"
			shift
			;;
   esac
done

exit $?
