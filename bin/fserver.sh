#!/bin/bash

# On/Off wirtualny serwer ikonką zenity w tray'u

# Użycie:
#   $ fserver.sh <nazwa> <IP> <port>
# np.
#   $ fserver.sh
#   $ fserver.sh fedora-server
#   $ fserver.sh fedora-server 192.168.0.101
#   $ fserver.sh fedora-server 192.168.0.101 80

# ------------------------------------------------------------------------------
# Wartości domyślne
NAME=${1:-fedora-server}
IP=${2:-192.168.0.101}
PORT=${3:-80}
ICON=/usr/share/icons/Fedora/scalable/apps/anaconda.svg

MSG_BUSY="...oczekuje odpowiedzi z ${IP}:${PORT} "
MSG_BUSY_OK="Serwer ${IP}:${PORT} działa "
MSG_BUSY_ERR="Coś poszło nie tak z serwerem ${IP}:${PORT} "

MSG_WORKING="Uruchomiony jest wirtualny serwer: ${IP}:${PORT}"
MSG_QUESTION="$MSG_WORKING \nMożesz go teraz bezpiecznie zamknąć."
MSG_QUESTION_OK="Monitoruj dalej"
MSG_QUESTION_CANCEL="Wyłącz serwer"

# ------------------------------------------------------------------------------
is_x(){
    [[ -n $DISPLAY ]]
}
# ------------------------------------------------------------------------------
is_run(){
    VBoxManage -q list runningvms | grep ^\"$NAME\" &>/dev/null
}
# ------------------------------------------------------------------------------
zenity(){
    # można też użyć $(which zenity)
    $(type -P zenity) --title "$NAME" --window-icon "$ICON" "$@"
}
# ------------------------------------------------------------------------------
notify(){
    notify-send -i "$ICON" "$NAME" "$@"
}
# ------------------------------------------------------------------------------
sustain_apps(){
    zenity --question \
        --text "$MSG_QUESTION" \
        --ok-label="$MSG_QUESTION_OK" \
        --cancel-label="$MSG_QUESTION_CANCEL"
}
# ------------------------------------------------------------------------------
tray_icon_clicked(){
    # ikona zenity w zasobniku
    zenity --notification --text "$MSG_WORKING"
}
# ------------------------------------------------------------------------------
tray_icon_working(){
    if tray_icon_clicked ; then
        if sustain_apps ; then
            $FUNCNAME
        else
            return 0
        fi
    fi
}
# ------------------------------------------------------------------------------
tray_icon_busy(){
    exec 4> >(zenity --notification --listen)
    echo "tooltip:${MSG_BUSY}" >&4
    #~ echo "message:${MSG_BUSY}" >&4
    if ($@) # monitorowane polecenie
    then
        notify -u low "$MSG_BUSY_OK" &
    else
        notify -u critical "$MSG_BUSY_ERR" &
    fi
    exec 4>&-
}
# ------------------------------------------------------------------------------
server_test(){
    # /dev/tcp redirection to check Internet connection.
    # Try to connect. (Somewhat similar to a 'ping' . . .)
    echo "HEAD / HTTP/1.0" >/dev/tcp/${IP}/${PORT} 2>/dev/null
    if [ $? != 0 ] ; then
        # jeśli nie ma odpowiedzi to zaczekaj sekundkę i spr. ponownie
        echo -n .
        sleep 1
        $FUNCNAME
    fi
    echo
}
# ------------------------------------------------------------------------------
server_on(){
    # uruchom (w tle)
    VBoxHeadless --startvm $NAME --vrdp=off  >/dev/null &
}
# ------------------------------------------------------------------------------
server_off(){
    # uśpij
    VBoxManage -q controlvm $NAME savestate
}
# ------------------------------------------------------------------------------
main(){
    if is_run ; then
        echo -e "TODO: obsłużyć wielokrotne uruchomienia ;P" >&2
        exit 1
    fi
    if is_x ; then
        server_on                   # start apps
        tray_icon_busy server_test  # monitor init process
                                    # sustain apps
        tray_icon_working           # monitor working apps

        MSG_BUSY="...trwa zamykanie serwera ${IP}:${PORT} "
        MSG_BUSY_OK="Serwer ${IP}:${PORT} został wyłączony "
        tray_icon_busy server_off   # end apps
    else
        echo -e "TODO: obsłużyć, gdy nie ma X-ów" >&2
        exit 1
    fi
}
# ------------------------------------------------------------------------------
main $@

# ------------------------------------------------------------------------------
#@TODO: grep 'enabled="1"' $HOME/.VirtualBox/VirtualBox.xml

# ------------------------------------------------------------------------------
#@NOTES

# http://www.tldp.org/LDP/abs/html/devref1.html
# exec 5<>/dev/tcp/jedral.one.pl/80
# echo -e "GET / HTTP/1.0\n" >&5
# cat <&5
