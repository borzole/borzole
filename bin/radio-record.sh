#!/bin/bash

# radio-record
# http://jordilin.wordpress.com/2006/07/28/howto-recording-audio-from-the-command-line/

cd $HOME
mplayer http://listen.di.fm/public3/soulfulhouse.pls &
MPLAYER_PID=$!

trap 'echo SIGINT' SIGINT

arecord -f cd -t raw | oggenc - -r -o out.ogg
kill -9 $MPLAYER_PID
