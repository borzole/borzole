#!/bin/bash

# przykład jak wczytywać plik linia po lini i ładować każdą kolumnę do innej zmiennej

INPUT=$(mktemp)
trap "rm -f $INPUT" EXIT

cat > $INPUT <<__EOF__
device1,deviceType1,major,minor,permissions
device2,deviceType2,major,minor,permissions
device3,deviceType3,major,minor,permissions
device4,deviceType4,major,minor,permissions
__EOF__

IFS=,
while read -r line ; do
	read -r f1 f2 f3 f4 f5 <<<"$line"
	echo $f5 $f4 $f3 $f2 $f1
done <$INPUT


# a tak się rozbija zmienną $PATH
IFS=':'
for p in $PATH ; do
	echo $p
done
