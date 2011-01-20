#!/bin/bash

< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-8}
#Note: this works only with the GNU version of head. Solaris or BSD versions have no '-c' flag!

