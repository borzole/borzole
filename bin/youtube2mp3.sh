#!/bin/bash

# youtube2mp3

TMP=$(mktemp)
trap "rm -f $TMP" EXIT
youtube-dl --output='%(title)s' --format=18 "$1" | tee -ai $TMP

FILM=$(grep '\[download\] Destination:' $TMP | cut -d' ' -f3-)
MP3=$(tr [:upper:] [:lower:] <<< "$FILM")

ffmpeg -i "$FILM" -acodec libmp3lame -ac 2 -ab 256k -vn -y "$MP3".mp3
