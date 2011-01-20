#!/usr/bin/env python
#-*- coding:utf-8 -*-

# przykład zastosowania do postu
# http://jedral.one.pl/2010/11/plan-doskonay.html

import os, pickle

tasks={ 'geany':'7',
        'emacs':'5',
        'vim'  :'4',
        'nano' :'3',
        'gedit':'2',
        'kate' :'1'}

old={}
new={}

db=os.getenv("HOME")+"/.editor.db"

# load saved
try:
    with open(db, 'r') as f:
        old = pickle.load(f)
except Exception, e:
    old = tasks

for k,v in tasks.items():
    suma = int(v)
    try:
        suma += int(old.get(k))
    except Exception, e:
        pass
    new[k] = suma

current = max(new,key = lambda x: new.get(x))
new[current] = 0

# save new
with open(db, 'w') as f:
    pickle.dump(new,f)

# return current task
print current
