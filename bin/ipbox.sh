#!/bin/bash

# publiczny IP

# ------------------------------------------------------------------------------
query(){
	cat <<!
	SELECT value
	FROM config
	WHERE key = 'dropbox_path'
	;
!
}
# ------------------------------------------------------------------------------
dropbox_path(){
	sqlite3 $db "$(query)" \
		| base64 -d \
		| sed -e's/^V//g' \
		| head -n 1
}
# ------------------------------------------------------------------------------
ip(){
	wget http://checkip.dyndns.org/ -q -O - \
		| grep -Eo '\<[[:digit:]]{1,3}(\.[[:digit:]]{1,3}){3}\>'
}
# ------------------------------------------------------------------------------

db=~/.dropbox/dropbox.db

dir=$(dropbox_path)/Public
log=$dir/ip.log
index=$dir/ip.html

IP=$(ip)

# ------------------------------------------------------------------------------

echo $IP > $log

cat >$index<<!
<html>
	<head>
		<meta http-equiv="Refresh" content="0; url=http://${IP}">
	</head>
	<body>
	</body>
</html>
!

