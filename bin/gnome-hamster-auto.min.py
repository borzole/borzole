#!/usr/bin/env python
#-*- coding:utf-8 -*-

# gnome-hamster-auto

import gtk, wnck, dbus

b = dbus.SessionBus()
o = b.get_object("org.gnome.Hamster","/org/gnome/Hamster")
i = dbus.Interface(o, "org.gnome.Hamster")

def change_hamster(win):
	activity = win.get_workspace().get_name()
	category= 'auto'
	description = win.get_name()
	tags =" #"+ win.get_application().get_name()
	fact=activity+"@"+category+","+description+tags
	i.AddFact(fact,0,0)

def active_window_changed(screen=None,window=None):
	win = screen.get_active_window()
	change_hamster(win)
	win.connect("name-changed", change_hamster)

s = wnck.screen_get_default()
s.connect("active_window_changed", active_window_changed)
while gtk.events_pending(): gtk.main_iteration()
gtk.main()
