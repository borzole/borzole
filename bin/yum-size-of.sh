#!/bin/bash

# skrypt pokazuje miejsce zajmowane przez paczkę rpm podaną jako argument

# by borzole.one.pl

# PRZYKŁAD:
# 		yum-size-of scribus
#		yum-size-of firefox
#
# PRZYKŁAD:
#		for r in kadu firefox scribus ; do yum-size-of $r ; done | grep -v '^-' | grep -v size_
#
# TODO:
# 		- skrypt powinien przeszukiwać tylko aktywne repozytoria, a nie wszystkie
#		- było by git, gdyby uwzględniał zależności

paczka=${1:-gimp}

query(){
	echo "SELECT name, size_package, size_installed, size_archive, version, release, arch
	FROM packages
	WHERE name = '$1'; "
}

show_result(){
	REPO=${mydb##/var/cache/yum/}

	SIZE_PACKAGE=$( echo $SQLITE_SELECT | cut -d\| -f2 )
	SIZE_PACKAGE_MB=$( echo "scale=3; $SIZE_PACKAGE/1024/1024" | bc -l )

	SIZE_INSTALLED=$( echo $SQLITE_SELECT | cut -d\| -f3 )
	SIZE_INSTALLED_MB=$( echo "scale=3; $SIZE_INSTALLED/1024/1024" | bc -l )

	SIZE_ARCHIVE=$( echo $SQLITE_SELECT | cut -d\| -f4 )
	SIZE_ARCHIVE_MB=$( echo "scale=3; $SIZE_ARCHIVE/1024/1024" | bc -l )

	VERSION="$( echo $SQLITE_SELECT | cut -d\| -f5 )"
	VERSION+=".$( echo $SQLITE_SELECT | cut -d\| -f6 )"
	VERSION+=".$( echo $SQLITE_SELECT | cut -d\| -f7 )"

	# wyświetl ładne wyniki
	echo -e " $SIZE_PACKAGE_MB MB \t| $SIZE_INSTALLED_MB MB \t| $SIZE_ARCHIVE_MB MB \t| ${VERSION} \t( ${REPO%%/*} )"
}

main(){
	# rezultaty
	echo -e "yum-size-of \e[1;31m$paczka\e[0m"
	echo -e "--------------------------------------------------------------------------------"
	echo -e " size_package \t| size_installed | size_archive | version ( repo )"
	echo -e "--------------------------------------------------------------------------------"

	for mydb in $( find /var/cache/yum/ -type f -name \*primary\*.sqlite | sort ) ; do
		SQLITE_SELECT=$( sqlite3 "$mydb" "$(query $paczka)" )
		if [ "$SQLITE_SELECT" != "" ] ; then
			show_result
		fi
	done
}

# let it happen
main
