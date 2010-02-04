#!/bin/bash

# rpm-check-file-list - coś na kształ windowsowego chkdsk /r w konsoli odzyskiwania
# - skanuje i uzupełnia ewentualnie brakujące pliki
# - można uruchomić z parametrem "-y" dla automatycznego potwierdzenia

if [ $(whoami) != root ] ; then
	# istnienia niektórych katalogów nie da się sprawdzić bez praw root'a
	# a już napewno nie przeinstalować paczki
	echo "brak dostępu : musisz mieć prawa 'root' ( su - , sudo ) "
	exit 0
fi

echo " -- ładuję listę paczek"
RPMQA=$(rpm -qa)

ILOSC=$(echo $RPMQA | wc -w)
echo " -- znaleziono $ILOSC pakietów"
# licznik
NR=0

# wykonaj dla każdej paczki w systemie
for paczka in ${RPMQA} ; do
	let NR=( $NR+1 )
	echo "sprawdzam (${NR}/${ILOSC}) :  $paczka"
	# wykonaj dla każdego pliku w paczce
	for plik in `rpm -ql $paczka | grep -v '(' ` ; do
		# sprawdź czy plik/katalog istnieje
		if [ ! -f $plik ] && [ ! -d $plik ] ; then 
			# objekt nieistnieje lub szczegóły o popsuciu :)
			file $plik
			echo " -- reinstall : $paczka"
			yum reinstall $1 $paczka
			# przerwanie pętli, by nie sprawdzać reszty pakietów z tej paczki
			break
		fi
	done
done
