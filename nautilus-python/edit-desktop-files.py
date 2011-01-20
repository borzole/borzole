#!/usr/bin/env python
#-*- coding:utf-8 -*-

import gtk
import nautilus

class EditDesktopFiles(nautilus.MenuProvider):

    def __init__(self):
        pass

    def edit_desktop_files(self, menu, files):
        for file in files:
            # http://www.pygtk.org/docs/pygtk/class-gtkmountoperation.html
            gtk.show_uri(None,file.get_uri(), gtk.gdk.CURRENT_TIME)

    def get_file_items(self, window, files):
        # test: czy w ogóle cokolwiek jest zaznaczone
        if len(files) == 0:
            return

        # filtr: tylko pliki *.desktop
        files = [ file for file in files
                    if file.get_mime_type() == 'application/x-desktop' ]

        if len(files) == 0:
            return
        elif len(files) == 1:
            LABEL='Edit %s file' % files[0].get_name()
            TOOLTIP='Edit this desktop file in default editor'
        else:
            LABEL='Edit all desktop files'
            TOOLTIP='Edit all desktop files in default editor'

        NAME='NautilusPython::edit_desktop_files_item'
        ICON='/usr/share/pixmaps/nautilus/colors.png'

        item = nautilus.MenuItem(NAME,LABEL,TOOLTIP,ICON)
        item.connect('activate', self.edit_desktop_files, files)

        return item,

