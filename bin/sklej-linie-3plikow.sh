#!/bin/bash

# przykładowy skrypt skleja linie z 3 plików

# 5 kolejne
# 6 linie
# 7 pliku
# 8
# 9
# 10
# 11

f1=/tmp/test.log
f2=/etc/passwd
f3=/etc/group
cat $0 > $f1
# ---
N=`wc -l < $f1`
F2=`awk '{ a[NR]=$0 } END { print a[3] } ' $f2`
F3=`awk '{ a[NR]=$0 } END { print a[10] a[11] a[16] a[22] } ' $f3`

new(){
    for (( i=1; i <= $N; i++ )); do
        LINE=$(awk '{ a[NR]=$0 } END { print a['$i'] } ' $f1)
        echo -n $LINE
        [ $i == 10 ] && echo ${F2}${F3} || echo
    done
}
NEW=$(new)

echo -e "$NEW" > $f1

xdg-open $f1
