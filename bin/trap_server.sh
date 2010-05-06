#!/bin/bash

cmd(){
	echo "spieprzaj dziadu"
}

main(){
	# typowe zajęcie demona
	echo -n .
}

demon(){
	while : ; do
		main
		sleep 0.1
	done
}

echo $$ > /tmp/server.pid
# przypisanie poleceń do numerów przerwań
trap 'exit 0' 35
trap "cmd" 36
demon
