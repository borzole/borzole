#!/bin/bash

# Spis skryptów z opisami

VERSION=2010.08.20-17:20

# folder ze skryptami
DIR="$(readlink -f `dirname $0`)"

# policz skrypty
c=$(ls -1 "$DIR"/* | wc -l )

opis(){
	# wyłuskuje opis skryptu, jako pierwszy blok komentarza
	awk 'BEGIN { FS="\n"; RS=""; i=0 } { if (i == 1) print $0; i++ }' "$1" \
	| sed -e '
		# poniewarz IFS="|" to trzeba się pozbyć znaków "|"
		s/|/<--pipe-->/g
		# wywalić znaki komentarza
		#~ s/#/-/g
	'
}

list(){
	# deskryptor pliku 4 = wejście informacyjne dla paska postępu
	exec 4> >(zenity --progress --percentage=0 --width=400 --auto-close --auto-kill --title="${0##*/}")
	j=0
	for i in "$DIR"/* ; do
		let j++
		# długość paska postępu
		x=$((100 * $j/$c))
		# wyłapujemy tylko skrypty
		file $i | grep script > /dev/null 2>&1 && {
			echo "$x" >&4
			echo -e "#Ładuje sktypty: ${i##*/} ..." >&4

			# opis skryptu
			o=$(opis "$i")

			# dodatkowy IFS rozdzielający rekordy, nie może być w samym rekordzie,
			# bo by było za dużo o jeden i zenity wariujej
			[[ $j -ne 1 ]] && echo -n "|"

			# wyjście
			echo -ne "FALSE|$i|${i##*/}|$o"
		}
	done
	# zamknięcie deskryptora 4
	echo "100" >&4
	exec 4>&-
}

menu(){
	local IFS="|"
	zenity --title="Lista $c skryptów z opisami" \
		--text "Zaznacz skrypty, które chcesz obejrzeć. Zostaną otwarte w domyślnym edytorze" \
		--width=800 --height=600 \
		--list  --checklist \
		--column="" --column "path" --column "script"  --column "opis" \
		$(list) \
		--separator " "  --multiple \
		--print-column=2 --hide-column=2
}
# otwórz wybrane skrypty w domyślnym edytorze
for i in $(menu) ; do xdg-open $i & done
