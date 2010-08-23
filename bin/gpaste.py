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

import pygtk
import gtk

cp = gtk.clipboard_get()

if cp.wait_is_text_available():
    print cp.wait_for_text()
