#!/bin/bash

# A Shell Script To Convert All .flac Files To .MP3 Format
# Note: I found this script somewhere on usenet and I've modified it for my needs
METAFLAC=/usr/bin/metaflac
FLAC=/usr/bin/flac
ID3=/usr/bin/id3
LAME=/usr/bin/lame
FIND=/usr/bin/find
 
t=$(${FIND} . -type f  -iname "*.flac")
if [ "$t" == "" ]
then
	echo "There are no *.flac file in $(pwd) directory"
	exit 1
fi
 
for f in *.flac
do
	OUTF=$(echo "$f" | sed s/\.flac$/.mp3/g)
	ARTIST=$(${METAFLAC} "$f" --show-tag=ARTIST | sed s/.*=//g)
	TITLE=$(${METAFLAC} "$f" --show-tag=TITLE | sed s/.*=//g)
	ALBUM=$(${METAFLAC} "$f" --show-tag=ALBUM | sed s/.*=//g)
	GENRE=$(${METAFLAC} "$f" --show-tag=GENRE | sed s/.*=//g)
	TRACKNUMBER=$(${METAFLAC} "$f" --show-tag=TRACKNUMBER | sed s/.*=//g)
	DATE=$(${METAFLAC} "$f" --show-tag=DATE | sed s/.*=//g)
	$FLAC -c -d "$f" | $LAME -m j -q 0 --vbr-new -V 0 -s 44.1 - "$OUTF"
	$ID3 -t "$TITLE" -T "${TRACKNUMBER:-0}" -a "$ARTIST" -A "$ALBUM" -y "$DATE" -g "${GENRE:-12}" "$OUTF"
done
