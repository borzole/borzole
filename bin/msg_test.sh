#!/bin/bash

# ------------------------------------------------------------------------------
# plik z tłumaczeniami, najlepiej użyć $LANG do identyfikacji tłumaczenia
TRANSLATION=/dev/shm/$LANG
# dokument miejscowy, tylko dla oszczędności plików przykładu ;)
cat > $TRANSLATION <<__EOF__
po Home domek
po "Home party" "Domowa iprezka"
po "Qwerty 2" "Klawiaturka"
__EOF__
# ------------------------------------------------------------------------------
# załaduj bibliotekę do tłumaczeń
. msg.sh || exit 1
# załaduj tłumaczenia
. $TRANSLATION || exit 1
# przykłady
msg "Home party"
#~ msg "Homeparty"
 #~ msg "H2ome party"
 #~ msg "Qwerty" msg "zZXCV dF"
msg "Qwerty 2" ;msg "zZXCV d4F"

msg.sh ${0}
