#!/bin/bash

# cutfun.sh - wycinanie funkcji ze skryptu
# użycie:
# 	cutfun.sh /home/lucas/start.sh

[ $# -eq 0 ] && exit 1

SCRIPT="$1" 
DIR="${SCRIPT%.*}.d"

INIT="init.sh"
MAIN="main.sh"
PLUGIN="plugin.d"

if [[ -d $DIR ]] ; then
	echo "Folder '$DIR' już istnieje, wychodzę"
	exit 1
else
	mkdir -p "$DIR/$PLUGIN"
fi

cp -p "${SCRIPT}" "${DIR}/${MAIN}"

# tymczasowy skrypt parsujący
CUTSCRIPT=$(mktemp)

trap $( rm -f $CUTSCRIPT ) EXIT

get_funlist(){
	# jeśli funkcje to blok postaci "nazwa234 ()..." wówczas mamy listę funkcji
	# obcinamy nazwy na spacji lub (
	grep '^[a-zA-Z0-9\_\-]*\ *()' "${DIR}/${MAIN}" \
		| sed -e 's/\ \ *//g' \
		| cut -d\( -f1 \
		| sort
}

FUNLIST=( $(get_funlist) )

for fun in ${FUNLIST[@]} ; do
cat <<__EOF__

echo '#!/bin/bash' > $DIR/$PLUGIN/${fun}.sh
sed -n -e '/^${fun}\\ *()/,/^}/p' ${DIR}/${MAIN} >> $DIR/$PLUGIN/${fun}.sh
sed -e '/^${fun}\\ *()/,/^}/d' ${DIR}/${MAIN} -i
chmod +x $DIR/$PLUGIN/${fun}.sh

__EOF__
done > $CUTSCRIPT
bash $CUTSCRIPT
rm -f $CUTSCRIPT

cat >"${DIR}/${INIT}"<<__EOF__

#!/bin/bash

# enable globstar (dopasowanie **)
shopt -s globstar
# rekursywnie
for s in "./$PLUGIN"/**/*.sh ; do
	. "\$s" || exit 1
done

. "${MAIN}" || exit 1
__EOF__

chmod +x "${DIR}/${INIT}"


