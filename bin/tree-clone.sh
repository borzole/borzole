#!/bin/bash

# treeclon - kopiuje drzewo katalogow bez plików 
# by jedral.one.pl

# treeclon  DrzewoDoSkopiowania  MiejsceDocelowe
find "$1" -xtype d -printf "$2/%P\n" | xargs -i mkdir -p '{}'

