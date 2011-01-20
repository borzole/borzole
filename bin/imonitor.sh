#!/bin/bash

# przykład monitorowania zmian folderu przy użyciu inotifywait
# coś jak fsniper, oba korzystają z biblioteki inotify
# http://inotify.aiken.cz/

dir=$HOME/temp

monitor(){
	inotifywait -rq -e close_write $dir | while read -r p ; do
	#~ while inotifywait -rq -e close_write $dir ; do
		# -r --recursive
		# -q --quiet
		# -e --event
		#~ rsync -av /folder_to_moniter -e "ssh -l pnix" pnix@remotehost:/home/pnix/tmp
		echo "Zapis do: $p"
	done
}


inotifywait -rmq -e create,move,delete --format "%:e %f %w" $dir | while read -r p
do
	echo "Zapis do: $p"
done

#~ nohup inotifywait -rm --timefmt "%Y %B %d %H:%M" --format "%T =-= %e %w%f" -e create,delete,move /somefile1 >> /somefile2 &> /dev/null &
