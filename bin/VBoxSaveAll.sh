#!/bin/bash

# Usypia wszystkie maszynki wirtualne

for v in $(VBoxManage -q list runningvms | cut -d'"' -f2) ; do
	VBoxManage -q controlvm $v savestate
done
