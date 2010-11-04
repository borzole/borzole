#!/bin/bash

# TEST mp3 > wav 30s

for p in 10 20 30 40 50 ; do
	# start-stop point
	# -ss hh:mm:ss -endpos hh:mm:ss
	echo mplayer zipera.mp3 -endpos 00:00:${p} -ao pcm:waveheader:file=zipera.${p}.wav -vc dummy -vo null
done

