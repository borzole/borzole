#!/bin/bash

# komunikaty

killall firefox
find $HOME/.mozilla/ -iname \*.sqlite -exec sqlite3  '{}' VACUUM \;
firefox &
