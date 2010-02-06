#!/bin/bash

# zmanr.sh - lista stron man z paczki rpm 
# ------------------------------------------------------------------------------
# TEST: czy są X-y (w końcu to graficzna aplikacja :P)
[ -z "$DISPLAY" ] && exit 1
# -------------------------------------------------------------------
get_cmd(){
	zenity --title "${0##*/}" --entry \
		--text "Podaj nazwę polecenia lub paczki rpm: " 
}
# -------------------------------------------------------------------
TMP=$1
# jeśli nazwa strony nie została podana jako parametr to wyświetli się okienko
if [ -z "$TMP" ] ; then
	TMP=$(get_cmd)
	# jeśli nic nie wpisano, to żegnamy się grzecznie bez słowa
	[ -z "$TMP" ] && exit 0
fi

# ------------------------------------------------------------------------------
#@TODO jeśli jest zarówno polecenie jak i paczka o tej nazwie
rpm -q $TMP >/dev/null 2>&1
[ $? -eq 0 ] && RPM=$TMP || RPM=$(rpm -qf $(which $TMP))
# ------------------------------------------------------------------------------
menu_lista()
{
	rpm -ql $RPM \
		| grep '/man/' \
		| cut -d'.' -f1 \
		| while read line; do echo " TRUE ${line##*/}" ; done \
		| sort -u
}
# -------------------------------------------------------------------
menu_height(){
	menu_lista | wc -l
}
# -------------------------------------------------------------------
menu(){
	zenity --title "${0##*/}" \
		--text "Patrz Ziutek co znalzałem dla
	cmd:<b>$TMP</b>
	rpm: <b>$RPM</b>\n$(rpm -qi $RPM | grep -v ':')" \
		--width=400 --height=$(($(menu_height)*50)) \
		--list  --checklist \
		--column="wybierz" --column "polecenie" \
		$(menu_lista) \
		--separator " " --multiple \
		--print-column=2
}
# ------------------------------------------------------------------------------
# generowanie stron wybranych z menu
for p in $(menu) ; do
	zman.sh $p
done

