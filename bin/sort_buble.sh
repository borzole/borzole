#!/bin/bash

# sortowanie bąbelkowe

# trik koloruje błędy na czerwono
exec 2> >( grep --color=always \. )
# ----------------------------------------------------------
tab=( $(for((i = 0; i < 200; ++i)); do echo $(($RANDOM % 1001)); done) )

lz=${#tab[*]} # długość listy

To=$(cat /proc/uptime | awk '{print $1}') # czas start
for(( i=1 ; $i < $lz ; i++ )) ; do
	for(( j=$(($lz-1)) ; $j >= $i ; j-- )); do
		if [ ${tab[j-1]} -gt ${tab[j]} ]; then
			tmp=${tab[j-1]}
			tab[j-1]=${tab[j]}
			tab[j]=$tmp
		fi
	done
done
Tk=$(cat /proc/uptime | awk '{print $1}') # czas stop
echo ${tab[*]} # wyświetl listę

dT(){
	echo "scale=2; $Tk - $To" | bc | sed -e 's:^\.:0.:'
}

echo Czas sortowania $(dT) s
