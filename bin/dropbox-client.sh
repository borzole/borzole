#!/bin/bash

touch input.txt
touch output.txt

echo -n "Enter Command: "
read INCOM

echo "$INCOM" > input.txt

while [ -f input.txt ];do
	sleep 10
done

cat output.txt
