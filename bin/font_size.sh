#!/bin/bash

# zmienia rozmiar czcionki używanej przez programy

key=/desktop/gnome/interface/font_name

font=$(gconftool-2 -g --ignore-schema-defaults ${key})
size=$(echo $font | awk '{print $NF}')

case $1 in
	+)
		((size++)) ;;
	-)
		((size--)) ;;
	*)
		echo Użycie: ${0##*/} +/-
		exit 1 ;;
esac

# new font
font=$(echo $font | sed 's/[0-9]\+$/'${size}'/g')
gconftool-2 -s /desktop/gnome/interface/font_name -t string "$font"
