#!/bin/bash

# skrypt reaguje na zamontowanie usb, przy użyciu inotify-tools

while sudo inotifywait -e modify /var/log/messages &>/dev/null ; do
	if sudo tail -n1 /var/log/messages | grep -q 'Attached SCSI removable disk' ; then
		echo "USB needs love!"
	fi
done

