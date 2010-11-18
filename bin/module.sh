#!/bin/bash

# wyszukuje paczki dostarczające moduły pythona
# http://forum.fedora.pl/index.php?/topic/23353-wyszukiwanie-modulow-pythona/

exec 2> >( grep --color=always \. ) # trik koloruje błędy na czerwono

list(){
        for p in $@ ; do
                echo /usr/lib{,64}/python{2.6,2.7,3.1}/{,plat-linux2/,lib-tk/,lib-old/,lib-dynload/,site-packages/{,PIL/,gst-0.10/,gtk-2.0/,wx-2.8-gtk2-unicode/}}${p}{.py,/__init__.py}
        done
}

yum provides $(list $@)
