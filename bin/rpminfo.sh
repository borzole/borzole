#!/bin/bash

echo INFORMATION: ; rpm -qi $@ ; echo
echo REQUIRES: ; rpm -qR $@ ; echo
echo PROVIDES: ; rpm -q --provides $@ ; echo
echo FILELIST: ; rpm -qlv $@
