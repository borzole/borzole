#!/bin/bash

# by borzole.one.pl

. $HOME/.config/user-dirs.dirs

[[ ! -d $XDG_DESKTOP_DIR ]] && exit 1
[[ ! -d $XDG_MUSIC_DIR ]] && exit 1

rm -f "$XDG_DESKTOP_DIR"/all.m3u
rm -f "$XDG_DESKTOP_DIR"/ost.m3u

# all
find "$XDG_MUSIC_DIR" -iname \*.mp3 | sort -u >> "$XDG_DESKTOP_DIR"/all.m3u

# ost
find "$XDG_MUSIC_DIR"  -mindepth 1 -maxdepth 1 -xtype d -iname [0-9]\* -exec \
	find '{}' -iname \*.mp3 >> "$XDG_DESKTOP_DIR"/ost.m3u \;
