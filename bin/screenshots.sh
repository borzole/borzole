#!/bin/bash

# zrzut pulpitu

Quality="90"

sleep 5

FILE=$HOME/zrzut_$(date "+%Y%m%d%_%H%M%S_").png

import -window root -quality $Quality $FILE

