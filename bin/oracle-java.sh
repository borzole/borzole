#!/bin/bash

# jeden plik dla jre/jdk 32/64
 NAZWA=libjavaplugin.so
 [[ $(arch) = 'x86_64' ]] && x86='.x86_64' || x86=''
 [[ $(arch) = 'x86_64' ]] && j86='amd64'   || j86='i386'
 [[ $(arch) = 'x86_64' ]] && LIB='lib64'   || LIB='lib'
 rpm -q jdk >/dev/null 2>&1 && JRE='jre/'
 DIR=/usr/${LIB}/mozilla/plugins
 LINK=${DIR}/${NAZWA}
 ALIAS=${NAZWA}${x86}
 PLIK=/usr/java/default/${JRE}lib/${j86}/libnpjp2.so

#rejestrowanie pluginu do przeglądarki na liście alternatyw:
 echo /usr/sbin/alternatives --install ${LINK} ${ALIAS} ${PLIK} 2
#zaznacz, który silnik ma być domyślny
 echo /usr/sbin/alternatives --config ${ALIAS}
