#!/usr/bin/env python
#-*- coding:utf-8 -*-

# gpaste-selection.py -- działa podobnie do gpaste.py z tą różnicą,
# że zwraca zaznaczony tekst (jeszcze przed skopiowaniem)

import pygtk
import gtk

cp = gtk.clipboard_get(selection="PRIMARY")

if cp.wait_is_text_available():
    print cp.wait_for_text()

