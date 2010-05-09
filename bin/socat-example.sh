#!/bin/sh

# do zabawy: http://forum.fedora.pl/lofiversion/index.php/t22799.html
tmp=$RANDOM

cat > $tmp <<__EOF__
#!/bin/sh

{
 read -p enter command - [1] or [2]
 echo reply = $REPLY >/tmp/a
 #dcop ksmserver ksmserver logout 0 $REPLY 0
}
__EOF__

chmod +x $tmp

#~ Nazwa              : socat
#~ Podsumowanie       : Bidirectional data relay between two data channels ('netcat++')
#~ Adres URL          : http://www.dest-unreach.org/socat
#~ : Socat is a relay for bidirectional data transfer between two independent data
#~ : channels. Each of these data channels may be a file, pipe, device (serial line
#~ : etc. or a pseudo terminal), a socket (UNIX, IP4, IP6 - raw, UDP, TCP), an
#~ : SSL socket, proxy CONNECT connection, a file descriptor (stdin etc.), the GNU
#~ : line editor (readline), a program, or a combination of two of these.
#~ : The compat-readline5 library is used to avoid GPLv2 vs GPLv3 issues.

socat TCP-LISTEN:1400 EXEC:"$tmp",fdin,pty,ctty,setsid,pipes

rm $tmp
