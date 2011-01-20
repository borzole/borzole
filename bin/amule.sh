#!/bin/bash +x

# bo cieknie z amule, to taki wrapper z watchdog
# jak przegina to go ubijam a potem i tak jest uruchamiany przy bezczynności przez
# $ xautolock -time 1 -locker amule.sh # w autostart dać

name=amule
max=1000

# przekieruj wyjście do logu, jeśli nie uruchomiono z terminala
if ! tty -s ; then
	exec &> ~/.log/${0##*/}
fi

apps(){
	ulimit -S -v $((${max}*1024))
	nice -n +20 $name
}

watchdog(){
	dir_pid=/dev/shm/$$
	dir=/dev/shm/$$/${0##*/} && mkdir -p $dir
	trap "rm -rf $dir_pid" EXIT

	echo $max > $dir/max
	while : ; do
		pids=$(pgrep -l $name | awk '$2~/^'${name}'$/{print $1}')

		for pid in $pids ; do
			virt=$(top -p $pid -b -n 1 | awk '$1~/^'${pid}'$/{print $5}' | sed 's:m::')
			echo "virt = $virt m (limit = $max)" > $dir/log
			if [ $virt -gt $max ] ; then
				kill -9 $pid
				exit 123
			fi
		done
		sleep 5
		max=$(cat $dir/max) # można sterować przez plik :P
	done
}
watchdog &
apps
