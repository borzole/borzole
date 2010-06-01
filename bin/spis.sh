#!/bin/bash

# Spis skryptów z opisami

VERSION=2010.05.31-19:49

opis(){
	# wyłuskuje opis skryptu, jako pierwszy blok komentarza
	sed -e ' # przepiękny łamaniec wyłyskujący pierwszy blok komentarza ?!
		# jeśli nie komentarz, to zmień status bufora i usuń wiersz
		/^[^#]/{
			x
			/1$/s/.*/&2/
			x
			d
		}
		# jeśli komentarz, to zmień status, i usuń wiersz jeśli nie jest to pierwszy blok komentarza
		/^#/{
			x
			/^$/s/.*/1/
			/2$/s/.*/&1/
			/12/ {
				x
				d
				x
			}
			x
		}
		# poniewarz IFS="|" to trzeba się pozbyć znaków "|"
		s/|/;/g
		#@TODO dlaczego nie mogę wywalić #!
		#~ /^#!\//d
		# wywalić znaki komentarza
		/^#$/d
		s/^#[[:blank:]]//g
		# usunąć puste linie
		/^$/d
		/perl/d
	' "$1"

	#@TODO tak wiem, napewno można zrobić to krócej :/
	# sed -e :a -e N -e 's/\\\n//' -e ta "$1" # łączy linie w jedną
	# [[:blank:]]
	# [[:space:]]
	# [[:alnum:]]
}

list(){
	# deskryptor pliku 4 = wejście informacyjne dla paska postępu
	exec 4> >(zenity --progress --percentage=0 --width=400 --auto-close --auto-kill --title="${0##*/}")
	# policz skrypty
	c=$(ls -1 /usr/local/{,s}bin/* | wc -l )
	j=0
	for i in /usr/local/{,s}bin/* ; do
		let j++
		x=$((100 * $j/$c))
		# wyłapujemy tylko skrypty
		file $i | grep script > /dev/null 2>&1 && {
			echo "$x" >&4
			echo -e "#Ładuje sktypty: ${i##*/} ..." >&4

			# rodzaj powłoki
			s=$(grep '#!' $i | head -n 1 | sed -e 's/^#!//g')

			# opis skryptu
			o=$(opis "$i")

			# wyjście
			echo -e "FALSE|$i|$s|${i##*/}|$o|"
		}
	done
	# zamknięcie deskryptora 4
	echo "100" >&4
	exec 4>&-
}

get_snippets(){
	local IFS="|"
	zenity --title="Lista skryptów z opisami" \
		--text "Zaznacz skrypty, które chcesz obejrzeć" \
		--width=1024 --height=800 \
		--list  --checklist \
		--column="" --column "path" --column "#!" --column "script"  --column "opis" \
		$(list) \
		--separator " "  --multiple \
		--print-column=2 --hide-column=2
}
FILES="$(get_snippets)"
[[ $FILES != '' ]] && geany $FILES || exit 0
