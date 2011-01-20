#!/usr/bin/python

# gcopy/gpaste -- copied some text to clipboard

# You can do stuff like the following after you've copied some text to clipboard:
# 		$ gpaste | wc
# And visa-versa:
#		$ date | gcopy
# Or, both:
# 		$ gpaste | wc | gcopy
#
# source: https://bbs.archlinux.org/viewtopic.php?pid=579801#p579801

import sys
import pygtk
import gtk

cp = gtk.clipboard_get()

s = sys.stdin.read()
if s[-1] == '\n': s = s[:-1]
cp.set_text(s)
cp.store()
