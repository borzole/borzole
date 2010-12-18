#!/bin/bash

# skrypt generuje polecenia do ustawienia pluginu java z paczek jre/jdk  dla i386/x86_64

# INIT
NAZWA=libjavaplugin.so
[[ $(arch) = 'x86_64' ]] && x86='.x86_64' || x86=''
[[ $(arch) = 'x86_64' ]] && j86='amd64'   || j86='i386'
[[ $(arch) = 'x86_64' ]] && LIB='lib64'   || LIB='lib'
rpm -q jdk >/dev/null 2>&1 && JRE='jre/'
DIR=/usr/${LIB}/mozilla/plugins
LINK=${DIR}/${NAZWA}
ALIAS=${NAZWA}${x86}
PLIK=/usr/java/default/${JRE}lib/${j86}/libnpjp2.so

# TEST: czy jest taki plik
if [ -f ${PLIK} ] ; then
	echo "# [ OK ] libnpjp2.so istnieje "
else
	echo "# [ ERR ] libnpjp2.so nie istnieje, wychodzę "
	exit 1
fi
echo -e "# --------------------------------------------------------------------"
echo
echo -e "# rejestrowanie pluginu do przeglądarki na liście alternatyw:"
echo /usr/sbin/alternatives --install ${LINK} ${ALIAS} ${PLIK} 2
echo
echo -e "# ustawienie jako domyślny:"
#echo /usr/sbin/alternatives --config ${ALIAS}
echo /usr/sbin/alternatives --set ${ALIAS} ${PLIK}
echo
echo -e "# --------------------------------------------------------------------"
echo -e "# [ A ] jeśli wszystko jest w porządku należy wykonać:"
echo -e "#	su -c'${0} | sh'"
echo -e "# --------------------------------------------------------------------"
echo -e "# [ B ] lub jeśli nie chcesz korzystać z 'alternatives' możesz zrobić link:"
echo -e "# 	ln -s ${PLIK} ${LINK}"
echo -e "# --------------------------------------------------------------------"
