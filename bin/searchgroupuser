#!/bin/bash

# searchgroupuser
# jest skryptem służącym do wyświetlania użytkowników należących do wybranej grupy systemowej. 
# Autorem skryptu jest użytkownik drunna, z forum Linux Questions. Prezentuje on po kolei: 0) nazwę grupy, 1) id grupy, 2) użytkowników odczytanych z /etc/group, 3) użytkowników odczytanych z /etc/passwd:


srchGroup="$1"

for thisLine in "`grep "^${srchGroup}:" /etc/group`"
do
  grpNumber="`echo ${thisLine} | cut -d":" -f3`"
  grpUsers="`echo ${thisLine} | cut -d":" -f4 | sed 's/,/ /g'`"
done

pwdUsers="`awk -F":" '$4 ~ /'${grpNumber}'/ { printf("%s ",$1) }' /etc/passwd`"

echo "0. Grupa: ${srchGroup}"
echo "1. Id grupy: ${grpNumber}"
echo "2. Użytkownicy z /etc/group: ${grpUsers}"
echo "3. Użytkownicy z /etc/passwd: ${pwdUsers}"
echo "Wszyscy użytkownicy: ${grpUsers} ${pwdUsers}"


# W praktyce wygląda to tak:
## searchusergroup users
#0. Grupa: users
#1. Id grupy: 100
#2. Użytkownicy z /etc/group: user1 user2
#3. Użytkownicy z /etc/passwd: games tinydns dnslog syncdns dnscache
#Wszyscy użytkownicy: user1 user2 games tinydns dnslog syncdns dnscache

