#!/usr/bin/env python
#-*- coding:utf-8 -*-

# xor-encrypt
# https://bbs.archlinux.org/viewtopic.php?pid=685115#p685115

import sys
with open(sys.argv[1], 'rb') as f:
	data = ''.join(chr(ord(c) ^ 64) for c in f.read())
with open(sys.argv[1], 'wb') as f:
	f.write(data)
