#!/bin/bash

# RPM : id3lib 
# Library for manipulating ID3v1 and ID3v2 tags
# URL  : http://id3lib.sourceforge.net/
# id3tag [OPTIONS]... [FILES]...
#   -aSTRING   --artist=STRING   Set the artist information
#   -ASTRING   --album=STRING    Set the album title information
#   -sSTRING   --song=STRING     Set the title information
#   -ySTRING   --year=STRING     Set the year
#   -tSTRING   --track=STRING    Set the track number

for d in {a..z} ;do
	cd $d	2>/dev/null
	for f in *.mp3 ;do
		artist=`echo $f | awk -F" - " '{printf $1}'`
		title=`echo $f | awk -F" - " '{printf $2}'`
		id3tag -a"$artist" -s"$title" "$f"	2>/dev/null
	done
	cd ..		
done
