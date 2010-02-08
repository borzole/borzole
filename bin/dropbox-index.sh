#!/bin/bash

# http://files.getdropbox.com/u/409786/pub/index.html
# by borzole.one.pl

# położenie pliku konfiguracyjnego
CONFIG_FILE=$HOME/.dropbox-indexrc
# ------------------------------------------------------------------------------
if [ -f $CONFIG_FILE ]; then
	# ustaw główny katalog do zindeksowania
	box=$(grep '^\ *dropbox-path\ *=\ *' $CONFIG_FILE | cut -d\= -f2-)
else
	echo -e "# Podaj ścieżkę do zindeksowanie: \n# np.
#	/home/$(whoami)/Dropbox/Public/pub" | tee -ia $CONFIG_FILE
	read box
	echo "dropbox-path=$box" >> $CONFIG_FILE
	echo -e "Zapisano ustawienia do pliku: $CONFIG_FILE
	
	UWAGA! Skrypt generuje pliki index.html w całym drzewie katalogów,
	dlatego proszę teraz sprawdzić poprawność ścieżki i uruchomić skrypt ponownie.
	A teraz dla bezpieczeństwa... wychodzę ;)"
	exit 0
fi
# w razie ustawienia bzdury
if [ ! -d "$box"  ] ; then
	echo -e "BŁĄD! nie istnieje taki katalog : '$box'\nzmień zawartość pliku : $CONFIG_FILE\nlub usuń go całkowicie, by wygenerować ponownie"
	exit 1
fi
# ------------------------------------------------------------------------------
usage(){
	echo -e "${0##*/} - generator stron html dla dropbox

Użycie:
	${0##*/} { all | index | clean }

Opcje:
	all \tgeneruje pliki index.html w całym drzewie katalogu
	index\tgeneruje plik index.html tylko w aktualnym katalogu
	clean\tusuwa pliki index.html w całym drzewie katalogu
"
}
# ------------------------------------------------------------------------------
start(){ cat <<__TEXT__
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pl" >
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="author" content="borzole" />
	<meta name="keywords" content="dropbox public, borzole, fedora, łukasz jędral" />
	<meta name="description" content="Index zawartości folderu publicznego z dropbox" />
	<meta name="robots" content="all" />

	<title>Dropbox/Public</title>

	<link rel="icon" type="image/x-icon" href="http://files.getdropbox.com/u/409786/web/img/favicon.png" />	

	<link rel="stylesheet" type="text/css" href="http://files.getdropbox.com/u/409786/web/css/dropbox.css" title="default" />	
	<link rel="alternate stylesheet" type="text/css" href="http://files.getdropbox.com/u/409786/web/css/dropbox-alfa.css" title="dropbox-alfa" />
	<link rel="alternate stylesheet" type="text/css" href="http://files.getdropbox.com/u/409786/web/css/dropbox-beta.css" title="dropbox-beta" />
	<link rel="alternate stylesheet" type="text/css" href="http://files.getdropbox.com/u/409786/web/css/dropbox-zeta.css" title="dropbox-zeta" />
	<link rel="alternate stylesheet" type="text/css" href=" " title="brak" />
		
	<script type="text/javascript" src="http://files.getdropbox.com/u/409786/web/js/styleswitcher.js"></script>
</head>

<body>

<div id="container">
	<div id="intro">
		
		<div id="logo"><a href="http://files.getdropbox.com/u/409786/pub/index.html"><img src="http://files.getdropbox.com/u/409786/web/img/logo-box.png" alt="Home" /></a></div>
		<div id="tytul">Dropbox / Public</div>
		
		<div id="styl">css:
			<a href="#" onclick="setActiveStyleSheet('default'); return false;">default</a>
			<a href="#" onclick="setActiveStyleSheet('dropbox-alfa'); return false;">alfa</a>
			<a href="#" onclick="setActiveStyleSheet('dropbox-beta'); return false;">beta</a>
			<a href="#" onclick="setActiveStyleSheet('dropbox-zeta'); return false;">zeta</a>
			<a href="#" onclick="setActiveStyleSheet('brak'); return false;">brak</a>
		</div>
	</div>		
__TEXT__
}
# ------------------------------------------------------------------------------
stop(){ cat <<__TEXT__

	<div id="stopka">
			<a href="http://validator.w3.org/check/referer" title="Sprawdź XHTML">xhtml</a> &nbsp; 
			<a href="http://jigsaw.w3.org/css-validator" title="Sprawdź CSS">css</a> &nbsp; 
			<a href="http://creativecommons.org/licenses/by/2.5/pl/" title="Creative Commons">cc</a> &nbsp;
			<a href="http://jedral.one.pl" title="Łukasz Jędral">borzole</a> &nbsp;
	</div>
</div>
</body>
</html>

__TEXT__
}
# ------------------------------------------------------------------------------
galeria(){
	cd "$@"
	# generowanie miniaturek ( ImageMagic )
	# 	find . -maxdepth 1 -name \*.png -exec convert '{}' -resize 10% ./mini/'{}' \;
	# optymalizowanie PNG ( optipng )
	# 	find . -name \*.png -exec optipng -o7 '{}' \;
	echo '
	<div id="galeria"> <!--tu idzie lista plików dla index.html --> 
		<ul> '  >>  index.html
	find . -maxdepth 1 -xtype f -name \*.png | cut -d'/' -f2- |sort | xargs -i echo "			<li><a href=\""'{}'"\" ><img src=\""./mini/'{}'"\" alt=\""'{}'"\" /></a></li>" >> index.html
	echo '		</ul>
	</div>'  >>  index.html
}
# ------------------------------------------------------------------------------
index(){
	cd "$@"
	start >  index.html
	echo '
	<div id="index"> <!--tu idzie lista plików dla index.html --> 
		<ul>
			<li><a href="../index.html" >[up] ..</a></li>
			<li><a href="index.html" >[-] .</a></li>	'  >>  index.html
	# indeksowanie katalogów
	find . -mindepth 1 -maxdepth 1 -xtype d  ! -name .\* | cut -d'/' -f2- |sort | xargs -i echo "			<li><a href=\""'{}'/index.html"\" >[+] "'{}'"</a></li>" >> index.html
	# indeksowanie ukrytych katalogów
	find . -mindepth 1 -maxdepth 1 -xtype d    -name .\* | cut -d'/' -f2- |sort | xargs -i echo "			<li><a href=\""'{}'/index.html"\" >[+] "'{}'"</a></li>" >> index.html

	# indeksowanie plików
	find . -maxdepth 1 -xtype f ! -name .\* |grep -v index.html | grep -v .galeria | cut -d'/' -f2- |sort | xargs -i echo "			<li><a href=\""'{}'"\" >" '{}'"</a></li>" >> index.html
	# indeksowanie ukrytych plików
	find . -maxdepth 1 -xtype f   -name .\* |grep -v index.html | grep -v .galeria | cut -d'/' -f2- |sort | xargs -i echo "			<li><a href=\""'{}'"\" >" '{}'"</a></li>" >> index.html


	echo '
		</ul>
	</div>'  >>  index.html
	# opis z readme.txt 
	echo '	<div id="opis">	<!--	komentarz pochodzi z readme.txt	-->'  >>  index.html
		cat readme.html  >>  index.html 2>/dev/null
		# jeśli w danym katalogu istnieje plik ".galeria" (najlepiej pusty) do dodaje galerię:
		if [ -f "$@"/.galeria ]; then
			"$0" galeria "$@"
		fi
	echo '	</div> 	<!--	koniec komentarza	-->' >>  index.html
	stop >> index.html
}
# ------------------------------------------------------------------------------
menu(){
case "$1" in
	galeria)
		# nieudokumentowana finkcja :P
		shift
		galeria "$@"
  		;;
	index)
		# nieudokumentowana finkcja :P
		shift
		index "$@"
		;;
	all)
		# aktualizacja bazy
		# bo jest problem z follow
		#find "$box" -follow	-xtype d -exec "$0" index '{}' \;
		#find "$box" 				-xtype d -exec "$0" index '{}' \;
		
		# ciekawostke, to: 
		#find "$box" -follow	-xtype d -exec "$0" index '{}' \;
		#podąża za linkami ale ich nie uwzględnia
		#to podążą, ale nie rozróżnia typu ??
		# ważne że działa
		find "$box" -follow -type d -exec "$0" index "{}" \; 
		;;
	clean)
		# usuwanie wszystkich plików "index.html"
		find "$box" -follow -type f -name index.html -exec rm -rf '{}' \;
		;;
	*)
		usage
		;;
esac
}
# ------------------------------------------------------------------------------
# uruchomienie
[ -n "$1" ] && menu "$@" || usage
