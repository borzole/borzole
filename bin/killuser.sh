#!/bin/bash

# killuser - skrypt, który w pętli będzie tak długo zabijał procesy użytkownika aż wszystkie zostaną finalnie zakończone. 
# autor: David Brock

USER=$1
MYNAME=`basename $0`
if [ ! -n "$USER" ]
 then
  echo "Użycie: $MYNAME użytkownik" >&2
 exit 1
  elif ! grep "^$USER:" /etc/passwd >/dev/null
 then
  echo "Użytkownik $USER nie istnieje!" >&2
 exit 2
fi
while [ `ps -ef | grep "^$USER" | wc -l` -gt 0 ]
 do
  PIDS=`ps -ef | grep "^$USER" | awk '{print $2}'`
  echo "Zabijam " `echo $PIDS | wc -w` " procesów użytkownika $USER."
 for PID in $PIDS
  do
   kill -9 $PID 2>&1 >/dev/null
 done
done
echo "Użytkownik $USER nie posiada już żadnych uruchomionych procesów."
