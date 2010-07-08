#!/bin/bash

# webr - otwiera stronę polecenia
# by jedral.one.pl

firefox $(rpm -qi `rpm -qf $(which $1)` |grep URL |cut -d":" -f2- )
# ToDo:
# gnuplot wskazuje na "/etc/alternatives..." i już nie działa - trzeba jakieś podązanie za linkiem zrobić.
