#!/bin/bash -ex

#
# By Charles-Antoine Guillat-Guignard ( http://www.xarli.net , xarli@xarli.net )
# Released under GNU GPL V2 ( http://www.gnu.org/licenses/gpl.txt )
# 6 septembre 2005, find the most recent version of this script at http://contrib.xarli.net/mpc2mp3/
#
# Use : mpc2mp3 [directory]
#
# This small script will convert mpc files to mp3, using mppdec and lame
#

ECHO='echo'
RENAME='which rename'
SED='which sed'
LAME='which lame'
LAMEOPTIONS='-p --vbr-new -v -b 64 -B 320 --abr 196 -h'
RM='which rm'

ENCODER='/usr/local/bin/mppdec'

if [[ -z $1 ]]
then
    REPERTOIRE=`pwd`
else
    REPERTOIRE=$1
fi

$RENAME "s/\ /\_$$\_/g" *.mpc

for FILE in `ls $REPERTOIRE/*.mpc`
do
    $ECHO "Fichier a traiter : '$FILE'" | $SED "s/\_$$\_/\ /g"
    $ENCODER $FILE `$ECHO $FILE | $SED 's/mpc$/wav/'` && $RM -f $FILE
    $LAME $LAMEOPTIONS `$ECHO $FILE | $SED 's/mpc$/wav/'` `$ECHO $FILE | $SED 's/mpc$/mp3/'` && $RM -f `$ECHO $FILE | $SED 's/mpc$/wav/'`
done

$RENAME "s/\_$$\_/\ /g" *

exit 0
