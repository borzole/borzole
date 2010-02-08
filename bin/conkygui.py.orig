#!/usr/bin/env python

import pygtk
pygtk.require('2.0')
import gtk
from subprocess import call as sh

class Table:
    def callback(self, widget, data=None):
        #~ print "shell %s" % data
        sh(data, shell=True)

    def delete_event(self, widget, event, data=None):
        gtk.main_quit()
        return False

    def __init__(self):
        self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
        self.window.set_title("Conky")
        self.window.connect("delete_event", self.delete_event)
        self.window.set_border_width(10)

        # Create a 4x3 table
        table = gtk.Table(4, 3, True)
        self.window.add(table)
		# --------------------------------------------------
		# http://www.pygtk.org/docs/pygtk/class-gtkframe.html
        #~ frame = gtk.Frame(" Conky GUI ")
        frame = gtk.Frame()
        label = gtk.Label( ''' proste menu dla Conky\n...oj! cool  ''' )
        frame.add(label)
        frame.set_shadow_type(gtk.SHADOW_NONE)
		# wypelnij komorke w tabeli:
        # szerokosc od slupka 0 do 3
        # wysokosc od poziomu 0 do 1
        table.attach(frame, 0, 3, 0, 2)
        label.show
        #~ frame.show		
		# --------------------------------------------------
        button = gtk.Button("Start")
        button.connect("clicked", self.callback, "conky -d")
        table.attach(button, 0, 1, 2, 3)
        button.show()
		# --------------------------------------------------
        button = gtk.Button("ReStart")
        button.connect("clicked", self.callback, "killall conky ; sleep 1; conky -d")
        # szerokosc od slupka 1 do 2
        # wysokosc od poziomu 0 do 1
        table.attach(button, 1, 2, 2, 3)
        button.show()
		# --------------------------------------------------
        button = gtk.Button("Stop")
        button.connect("clicked", self.callback, "killall conky")
        table.attach(button, 2, 3, 2, 3)
        button.show()
		# --------------------------------------------------
        button = gtk.Button("Quit")
        button.connect("clicked", lambda w: gtk.main_quit())
        table.attach(button, 0, 3, 3, 4)
        button.show()
		# --------------------------------------------------
        table.show()
        #~ self.window.show()
        self.window.show_all()

def main():
    gtk.main()
    return 0       

if __name__ == "__main__":
    Table()
    main()
