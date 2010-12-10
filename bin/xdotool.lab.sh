#!/bin/bash

#@lab: fake keyboard/mouse input

# Get window id of firefox
WID=`xdotool search --title --name "Namoroka_-_Vimperator"`

# Set focus to firefox
#~ xdotool windowfocus $WID

# Move cursor to the specified position
xdotool mousemove 930 10

# Send a mouse click (left click) to firefox
xdotool click 1

# Move cursor to top-middle of the screen
xdotool mousemove 909 10
