#!/bin/bash

# skrypt wyciąga informacje o albumach grupy
# na podstawie strony metal-archives.com
# na potrzeby: http://forum.ubuntu.pl/showthread.php?t=139538

# Przykład:
#    skrypt.sh iron maiden
# autor: jedral.one.pl

server='http://www.metal-archives.com'

# ------------------------------------------------------------------------------
die(){
	echo -e "[Error] $*" >&2
	exit 1
}
# ------------------------------------------------------------------------------
set_band_url(){
	args=$*
	query="$server"/"search.php?string=${args/ /+}&type=band"
	url="$server"/$(curl "$query" | egrep 'band\.php\?id=[0-9]+' | cut -d\' -f4)
	[ "$url" == "$server/" ] && die "Nie znaleziono adresu dla grupy: $args"
	echo URL: $url
}
# ------------------------------------------------------------------------------
get_raw_page(){
	# Funkcja zwraca sformatowaną stronę
	curl "$url" |
		# formatuje kod tak, aby każdy tag był w osobnej linii
		sed -e 's/</\n</g ; s/>/>\n/g ' |
		# usuwam puste linie
		sed -e '/^[[:space:]]*$/d'
}
# ------------------------------------------------------------------------------
get_raw_album(){
	id=$1
	echo -e "$raw" |
		# wyłuskujemy blok z albumem
		sed -n -e '/release.php?id='$id'\x27>/,/\]/p'
		# \x27 to pojedynczy cudzysłów'
}
# ------------------------------------------------------------------------------
echo 'Szukam adresu grupy' $*
set_band_url $*

echo 'Pobieram stronę grupy' $*
raw=$(get_raw_page)

echo 'Wyłuskuje id albumów'
ids=$(echo -e "$raw" | sed -n 's:^.*release\.php?id=\([0-9]\+\).*$:\1:p')

for id in $ids ; do
	release="$server/release.php?id=$id"
	review="$server/review.php?id=$id"
	# blok inforacji o albumie
	raw_album=$(get_raw_album $id)
	# ten sam blok jako tablica, każda komórka to linia
	IFS=$'\n' tab_album=( $(echo -e "$raw_album") )
	IFS=$' \n\t' # reset IFS

	if echo -e "${tab_album[0]}" | grep -q class ; then
		# jeśli istnieje atrybut "class"
		class=$(echo -e "${tab_album[0]}" | sed -n 's:.*class=\x27\([a-z]*\)\x27.*:\1:p')
	fi
	title=${tab_album[1]}
	year=${tab_album[5]}

	echo "$title | $year | $class | $release"
done |
	# na koniec ładne formatowanie na podstawie '|'
	column -s'|' -t

# tak wygląda wyłuskany blok, ma s
<<!
<a class='album' href='/release.php?id=276114'>
The Final Frontier
</a>
</td>
<td nowrap='true' class='album'>
Full-length, 2010
</td>
<td>
</td>
<td>
[
<a href='/review.php?id=276114'>
14 reviews, average 76%
</a>
]
!
