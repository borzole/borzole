#!/bin/bash

# mexm -- do konversji dowolnego filmu o proporcjach ekranu => 16/9 z pomoca Mencodera
# http://forum.fedora.pl/index.php?/topic/23367-bash%3B-analiza-pliku-wideo-i-zdefiniowanie-zmiennych/

exec 2> >( grep --color=always \. )	 # trik koloruje błędy na czerwono
# ------------------------------------------------------------------------------

# avi info
[[ -f $1 ]] && FILM=$1 || { echo "Podaj film jako parametr" >&2 ; exit 1; }

DUMP=$(mplayer -identify -endpos 1 -ao null -vo null "$FILM" )

list_ids(){
	grep ^ID_ <<<"$DUMP" | cut -d'=' -f1
}

for ID in $(list_ids) ; do
	eval $ID=\"$(grep ^${ID} <<<"$DUMP" | cut -d'=' -f2- )\"
done

echo ---------------------------------------------------------------------------
list_ids
echo ---------------------------------------------------------------------------
echo tytuł: $ID_FILENAME
echo wymiary: $ID_VIDEO_WIDTH x $ID_VIDEO_HEIGHT
echo ID_AUDIO_FORMAT: $ID_AUDIO_FORMAT

#h wysokosc
#w szerokosc
#x kadrowanie po szerokosci
#y kadrowanie po wysokosci

#wymiary filmu szerokoscxwysokosc
echo "Wybierz:1)640:360 2) 512:288 3) 768:432 lub wpisz z reki szerokosc:wysokosc"
read k

case $k in
1) scale="640:360" ;;
2) scale="512:288" ;;
3) scale="768:432" ;;
*) scale=$k ;;
esac

#bitrate filmu
echo "Wybierz bitrate 1) 1000 2) 1200 3) 1400 4) 1600 5) 1800 6) 2000 lub wpisz z reki "
read k
case $k in
1) bitrate="1000" ;;
2) bitrate="1200" ;;
3) bitrate="1400" ;;
4) bitrate="1600" ;;
5) bitrate="1800" ;;
6) bitrate="2000" ;;
*) bitrate=$k ;;
esac


#dla xvid w tej wersji tylko mp3 dziala
codecaudio="mp3lame -lameopts abr:br=128 -srate 44100"

echo "wybrane wymiary to "$scale
echo "wybrany bitrate to "$bitrate
echo "wybrany codecaudio to"$codecaudio

sleep 5

#obcinamy brzegi;
h=$ID_VIDEO_HEIGHT
let w=$ID_VIDEO_HEIGHT*16/9
let w=${w/\.*} #zaokragla w dol
let x=($ID_VIDEO_WIDTH-$w)/2
let x=${x/\.*} #zaokragla w dol


if [ $x -ge 0 ] ; then

if [ $(ls | grep -c "divx2pass.log") = "1"  ]; then # jak jest log do pass 1 to robi pass 2
echo pass 2 ongoing
exec
mencoder $ID_FILENAME -vf crop=$w:$h:$x:0,scale=$scale -ovc xvid -xvidencopts threads=4:qpel:chroma_opt:vhq=4:bvhq=1:quant_type=mpeg:pass=2:bitrate=$bitrate -oac $codecaudio  -o $FILM2

else #nie ma logu dla pass 1
echo pass 1 ongoing than pass 2
exec
mencoder $ID_FILENAME -vf crop=$w:$h:$x:0,scale=$scale -ovc xvid -xvidencopts threads=4:qpel:chroma_opt:vhq=4:bvhq=1:quant_type=mpeg:pass=1 -oac $codecaudio  -o /dev/null &&
mencoder $ID_FILENAME -vf crop=$w:$h:$x:0,scale=$scale -ovc xvid -xvidencopts threads=4:qpel:chroma_opt:vhq=4:bvhq=1:quant_type=mpeg:pass=2:bitrate=$bitrate -oac $codecaudio  -o $FILM2

fi
