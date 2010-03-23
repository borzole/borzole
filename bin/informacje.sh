#!/bin/bash

# informacje.sh
# ------------------------------------------------------------------------------
#while x=0
#do
MOJEIP=`/sbin/ifconfig eth0 | grep 'inet addr' | grep Bcast | awk '{print $2}' | awk -F: '{print $2}'`
MOJMAC=`/sbin/ifconfig eth0 | grep HWaddr | awk '{print $5; }'`
MOJKOMP=`/bin/hostname`
MOJPROMISC=`/sbin/ifconfig eth0 | grep -i promisc`

if [ -n "$MOJPROMISC" ]
then
  MOJPROMISC="ON"
else
  MOJPROMISC="OFF"
fi

clear

date
echo -e ""
echo -e "==================== SIEC ====================="
echo -n Aktualny numer IP ..........
echo -e "\E[32m $MOJEIP\033[0m"
echo -n Aktualny adres MAC .........
echo -e "\E[32m $MOJMAC\033[0m"
echo -n Aktualna nazwa komputera ...
echo -e "\E[32m $MOJKOMP\033[0m"
echo -n Tryb promiscous ............
echo -e "\E[32m $MOJPROMISC\033[0m"
echo -e "==============================================="

echo -e "\n\n\n"


echo -e "============================= DYSKI ==========================="
echo -e ""

for i in `mount | grep "^/"  | awk '{print $1}' | cut -d "/" -f 3`
do
  WOLNE_MB=`df -m |grep $i 2>/dev/null |awk '{print $4}'`
  ZAJETE_MB=`df -m |grep $i 2>/dev/null |awk '{print $3}' `

  punkt_montowania=`mount | grep $i  | awk '{print $3}'`
  opcje_montowania=`mount | grep $i | awk '{print $6}'`
  typ_partycji=`mount | grep $i | awk '{print $5}'`

  echo -e "Partycja \E[37;44m $i \033[0m  zamontowana w \E[37;44m $punkt_montowania \033[0m   ( $typ_partycji )"
  echo -e ""
  echo -e "Opcje montowania : $opcje_montowania"
  echo -e ""
  echo -e "zajęte : \E[32m $ZAJETE_MB MB \033[0m \t wolne : \E[32m $WOLNE_MB MB  \033[0m"
  echo -e "==============================================================="
done



# wypisz ilość procesów w systemie
processes=`ps -A | wc -l`
let processes-=5

  echo -e ""
  echo -e "Liczba uruchomionych procesów w systemie : \E[32m $processes \033[0m "
  echo -e "==============================================================="
  echo -e ""

# wypisz ilość procesów w systemie, które nie śpią
processes=`ps -A r | wc -l`
let processes-=2

  echo -e ""
  echo -e "Liczba procesów w systemie które nie śpią : \E[32m $processes \033[0m "
  echo -e "==============================================================="
  echo -e ""


#if
# read -t 1 response
#then
# exit
#fi
#done



# wypisz jak długo system już działa
echo "Czas działania systemu : `uptime | sed -e 's/^.*up *//g' -e 's/, *[0-9] *u.*$//g'` h"
