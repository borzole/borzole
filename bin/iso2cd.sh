#!/bin/bash

# example call: iso2cd debian_lenny_final.iso
cdrecord -s \
	dev=`cdrecord --devices 2>&1 | grep "\(rw\|dev=\)" | awk {'print $2'} | cut -f'2' -d'=' | head -n1` \
	gracetime=1 \
	driveropts=burnfree -dao -overburn -v
