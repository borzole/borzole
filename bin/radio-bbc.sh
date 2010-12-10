#!/bin/bash

# startradio -- quick access to BBC Radio streams, using mplayer

#  List urls in ~/.radiourls, in the format
#  URL,name,cli-command
#  http://www.bbc.co.uk/radio/listen/live/r1.asx,Radio 1,1

#  Many URLs can be found at http://www.bbcstreams.com
#  Geographic restrictions by IP may affect some streams

exec 2> >( grep --color=always \. )
# ------------------------------------------------------------------------------
default_url_list(){
cat <<__EOF__
http://www.bbc.co.uk/radio/listen/live/r1.asx,Radio 1,1
http://www.bbc.co.uk/radio/listen/live/r1x.asx,Radio 1Xtra,1x
http://www.bbc.co.uk/radio/listen/live/r2.asx,Radio 2,2
http://www.bbc.co.uk/radio/listen/live/r3.asx,Radio 3,3
http://www.bbc.co.uk/radio/listen/live/r4.asx,Radio 4,4
http://www.bbc.co.uk/radio/listen/live/r4lw.asx,Radio 4 LW,4lw
http://www.bbc.co.uk/radio/listen/live/r5l.asx,Radio 5 Live,5
http://www.bbc.co.uk/radio/listen/live/r5lsp.asx,Radio 5 Live Sports Extra,5se
http://www.bbc.co.uk/radio/listen/live/r6.asx,Radio 6,6
http://www.bbc.co.uk/radio/listen/live/r7.asx,Radio 7,7
http://www.bbc.co.uk/worldservice/meta/tx/nb/live/www15.ram,World Service,ws
http://www.bbc.co.uk/radio/listen/live/bbcmanchester.asx,Radio Manchester,manc
http://www.bbc.co.uk/radio/listen/live/bbcsuffolk.asx,Radio Suffolk,suff
__EOF__
}
# ------------------------------------------------------------------------------
startstream() {
    stopstreams

    echo -e "Starting new stream..."
    mplayer -playlist ${URLS[$1]} &> /dev/null &
        # Dumping to /dev/null because even the -really-quiet option wasn't really quiet enough
    echo ${NAMES[$1]} > $STATUS
}
# ------------------------------------------------------------------------------
stopstreams() {
    echo "Stopping all current streams..."

    for (( i=1; i<=$URLCOUNT; i++ ))
    do
        while [ $"`ps ux | grep mplayer | grep ${URLS[$i]} | grep -v grep | wc -l`" -ne "0" ]; do
            kill `ps ux | grep mplayer | grep ${URLS[$i]} | grep -v grep | head -n 1 | cut -c 10- | cut -c -5`
            sleep 1
        done
    done

    echo $NOTPLAYINGSTATUS > $STATUS
}
# ------------------------------------------------------------------------------
liststations () {
    for (( i=1; i<=$URLCOUNT; i++ ))
    do
        echo -e "\t"${COMMANDS[$i]}"\t\t"${NAMES[$i]}
    done
    echo
}
# ------------------------------------------------------------------------------
URLSOURCE="$HOME/.radiourls"
STATUS="$HOME/.radiostatus"
NOTPLAYINGSTATUS="Not playing"

# No URL data found in /home/lucas/.radiourls


### Get URLs, station names, and command-line arguments

URLCOUNT="`cat $URLSOURCE 2>/dev/null  | grep -v '#' | wc -l`"

if [ $URLCOUNT == "0" ]; then
    echo "No URL data found in "$URLSOURCE
    default_url_list > $URLSOURCE
else
    for (( i=1; i<=$URLCOUNT; i++ ))
    do
        URLS[$i]="`cat $URLSOURCE |  head -n $i | tail -n 1 | cut -d ',' -f 1`"
        NAMES[$i]="`cat $URLSOURCE  |  head -n $i | tail -n 1 | cut -d ',' -f 2`"
        COMMANDS[$i]="`cat $URLSOURCE |  head -n $i | tail -n 1 | cut -d ',' -f 3`"
    done
fi

### 'startradio stop'

if [ "$#" == "1" -a "$1" == "stop" ]; then

    stopstreams



### 'startradio list'

elif [ "$#" == "1" -a "$1" == "list" ]; then

    echo -e "\n'startradio start COMMAND', where\n"
    echo -e "\tCommand\t\tStation\n"
    liststations


### 'startradio playing'

elif [ "$#" == "1" -a "$1" == "playing" ]; then

    ISPLAYING="0"

    for (( i=1; i<=$URLCOUNT; i++ ))
    do
        if [ $"`ps ux | grep mplayer | grep  ${URLS[$i]} | grep -v grep | wc -l`" -ne "0" ]; then
            echo -e "\nNow playing: ${NAMES[$i]}\n"
            let    ISPLAYING="1"
        fi
    done

    if [ $ISPLAYING == 0 ]; then
        echo -e "\nNo streams playing\n"
    fi


### 'startradio pipemenu'

elif [ "$#" == "1" -a "$1" == "pipemenu" ]; then

    echo '<openbox_pipe_menu>'

    if [ "`cat $STATUS`" != "$NOTPLAYINGSTATUS" ]; then
        echo '<separator label="Now playing: '`cat $STATUS`'" />'
    fi

    for (( i=1; i<=$URLCOUNT; i++ ))
    do
        if [ "${NAMES[$i]}" == "$STATUS" ]; then
            echo '<item label="'${NAMES[$i]}'">'
            echo '<action name="Execute">'
            echo '<execute></execute>'
            echo '</action>'
            echo '</item>'
        else
            echo '<item label="'${NAMES[$i]}'">'
            echo '<action name="Execute">'
            echo '<execute>startradio start '${COMMANDS[$i]}'</execute>'
            echo '</action>'
            echo '</item>'
        fi
    done

    if [ "$STATUS" != "$NOTPLAYINGSTATUS" ]; then
        echo '<separator/>'
        echo '<item label="Stop radio">'
        echo '<action name="Execute">'
        echo '<execute>startradio stop</execute>'
        echo '</action>'
        echo '</item>'
    fi


    echo '</openbox_pipe_menu>'



### 'startradio start COMMAND'

elif [ "$#" == "2" -a "$1" == "start" ]; then

    STREAMSTARTED="0"

    for (( i=1; i<=$URLCOUNT; i++ ))
    do
            if [ ${COMMANDS[$i]} == $2 ]; then
                echo -e "Starting "${NAMES[$i]}""
                #startstream ${URLS[$i]},${NAMES[$i]}
                startstream $i
                let STREAMSTARTED="1"
            fi
    done

    if [ $STREAMSTARTED == 0 ]; then
        echo -e "\nError: station choice not recognised\n"
        liststations
    fi


### No valid command(s) found

else

    echo "Usage:
    startradio start OPTION
    startradio stop
    startradio playing
    startradio list
    startradio pipemenu

Play BBC radio streams using mplayer
"
    liststations
fi
