#!/bin/bash

# /home/borzole/open_mailto.sh %s

# firefox "https://mail.google.com/mail?view=cm&tf=0&to=`echo $1 | sed 's/mailto://'`"

# If you'd like to make the script open a new tab in an existing Firefox window, 
# you can replace the firefox line in the script with the following:
firefox -remote "openurl(https://mail.google.com/mail?view=cm&tf=0&to=`echo $1 | sed 's/mailto://'`,new-tab)"
