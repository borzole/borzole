#!/bin/bash

# mtube -  youtube przez mplayer
video_id=$(curl -s $1 | sed -n "/watch_fullscreen/s;.*\(video_id.\+\)&title.*;\1;p");
mplayer -fs $(echo "http://youtube.com/get_video.php?$video_id");
