#!/usr/bin/env python
#-*- coding:utf-8 -*-

from progressbar import ProgressBar
import time

# 1
p = ProgressBar()
for i in range(101):
    p.render(i, 'step %s' % i)
    time.sleep(0.01)
# 2
p = ProgressBar('yellow', width=20, block='✭', empty='✩')
for i in range(11):
    p.render(i, 'step %s\nProcessing...\nDescription: write something.' % i)
    time.sleep(0.1)

# GEANY: you can insert Unicode code points by hitting Ctrl-Shift-u, then still holding Ctrl-Shift, type some hex digits ...
# http://en.wikipedia.org/wiki/List_of_Unicode_characters#Block_elements
print  u'\u03A0 \u03A3 \u03A9'
