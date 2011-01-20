#!/bin/bash

# search_folder -- generuje folder z linkami symbolicznymi do wyszukanych plików
# jedral.one.pl


if ! readlink /proc/$$/fd/0 | grep -q ^pipe ; then
	echo -e "Użycie:
	find '/search/dir' -type f -iname \*.pdf | $0 ~/result/dir

	# z mechanizmem inotify dobrze jest sprawdzaś wzorzec tylko pliku
	find '/test/file' -type f -iname \*.pdf | $0 ~/result/dir
	"
	exit 0
fi

debug(){
	log=~/log
	log=/dev/null
	: echo $* >> $log
}

pipe(){
	# czyta z potoku
	while read -r line ; do
		readlink -f "$line" \
			&& debug "pipe file  ok  : $line" \
			|| debug "pipe file error: $line"
	done
}

mix(){
	# mieszane są ścieżki z potoku i istniejące linki, żeby wykluczyć puźniejsze duplikaty
	echo -e "$PIPE"
	# czyta z folderu wyszukiwania
	for link in "$dest"/* ; do
		[ -h "$link" ] && {
			if [ -f "$link" ] ; then
				readlink -f "$link" && rm -f "$link"
				debug refresh link: "$link"
			else
				# uszkodzone dowiązania widziane są wciąż jako dowiązania, ale już nie jako pliki
				rm -fv "$link" &>/dev/null
				debug broken link: "$link"
			fi
		}
	done
}

PIPE=$(pipe)
debug pipe count: ${#PIPE}

if [ ${#PIPE} != 0 ] ; then
	# folder wyszukiwania
	dest=$(readlink -f "$1")
	mkdir -p "$dest"
	# symbol na folderze
	gvfs-set-attribute -t stringv "$dest" metadata::emblems new

	mix | sort -u | while read -r src ; do
		core="$dest"/"${src##*/}"
		# zabezpieczenie przed duplikatem nazwy
		while [ -f "$core"$n ] ; do ((n++)) ; done
		new="$core"$n && n=''
		ln -s "$src" "$new" &
	done
fi
