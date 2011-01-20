#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os,sys
import gtk
import nautilus

TOOLTIP="""
Every directory may have a local config file called '.hidden'
with a list of files invisible in nautilus
"""

class HiddenProvider():
	EMBLEM="important"
	ICON='/usr/share/icons/gnome/16x16/emblems/emblem-important.png'

	def err(self,msg):
		"""useful for debugging:
		$ tail -f ~/.xsession-errors"""
		sys.stderr.write(str(msg)+'\n')

	def get_config_path(self, file):
		dir_uri = file.get_parent_uri().replace('%20',' ')
		return str(dir_uri[7:])+'/.hidden'

	def get_hidden_files_list(self, file):
		config = self.get_config_path(file)
		names = []
		if os.path.isfile(config):
			with open(config, 'r') as f:
				names = [ line.replace('\n','')
							for line in f
								if line != '\n' ]
		return names, config

class UnhideFiles(nautilus.MenuProvider, HiddenProvider):
	def __init__(self):
		pass

	def get_file_items(self, window, files):
		if len(files) == 0:
			return

		names, config = self.get_hidden_files_list(files[0])

		# filter: only invisible files
		files = [ file for file in files
					if file.get_name() in names ]

		if len(files) == 0:
			return
		elif len(files) == 1:
			LABEL='Unhide file "%s"' % files[0].get_name()
		else:
			LABEL='Unhide all selected files'

		NAME='NautilusPython::unhide_files_item'

		item = nautilus.MenuItem(NAME,LABEL,TOOLTIP,self.ICON)
		item.connect('activate', self.unhide_files, files)

		return item,

	def unhide_files(self, menu, files):
		names, config = self.get_hidden_files_list(files[0])

		for file in files:
			names.remove(file.get_name())

		if len(names) != 0:
			with open(config, 'w') as f:
				for name in names:
					f.write(name+'\n')
		else:
			os.remove(config)

class HideFiles(nautilus.MenuProvider, HiddenProvider):
	def __init__(self):
		pass

	def get_file_items(self, window, files):
		if len(files) == 0:
			return

		names, config = self.get_hidden_files_list(files[0])

		# filter: only visible files
		files = [ file for file in files
					if file.get_name() not in names ]

		if len(files) == 0:
			return
		elif len(files) == 1:
			LABEL='Hide file "%s"' % files[0].get_name()
		else:
			LABEL='Hide all selected files'

		NAME='NautilusPython::hide_files_item'

		item = nautilus.MenuItem(NAME,LABEL,TOOLTIP,self.ICON)
		item.connect('activate', self.hide_files, files)

		return item,

	def hide_files(self, menu, files):
		config = self.get_config_path(files[0])

		with open(config, 'a') as f:
			for file in files:
				f.write(file.get_name()+'\n')

class HiddenEmblem(nautilus.InfoProvider, HiddenProvider):
	def __init__(self):
		pass

	def update_file_info(self, file):
		#@TODO zoptymalizować: nie trzeba sprawdzać listy dla każdego pliku
		names, config = self.get_hidden_files_list(file)
		if len(names) == 0:
			return

		if file.get_name() in names:
			file.add_emblem(self.EMBLEM)
