#!/bin/bash

echo -e "złap mnie nim przepadnę,
stane się blade,
przezroczyste,\nżadne" | potok.sh
potok.sh < potok_test.sh
potok.sh

#~ # silnik.sh
#~ readlink /proc/$$/fd/0
#~
#~
#~ echo $$
#~ echo NIC | silnik.sh
#~ silnik.sh < ~/.bashrc
#~ silnik.sh <<__EOF__
#~ silnik.sh <<$$
#~ __EOF__
#~ silnik.sh <<<$$
#~ silnik.sh NIC
