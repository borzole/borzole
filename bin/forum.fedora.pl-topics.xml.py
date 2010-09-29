#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import urllib
from xml.dom import minidom

url="http://forum.fedora.pl/index.php?/rss/forums/5-forum-fedorapl/"
local=os.getenv("HOME")+"/rss-z-forum.fedora.pl.xml"

def forum_topics(source):
	DOMTree = minidom.parse(source)
	cNodes = DOMTree.childNodes
	for i in cNodes[0].getElementsByTagName("item"):
		print i.getElementsByTagName("title")[0].firstChild.data
		#~ print item.toxml()

def test_online():
	src=urllib.urlopen(url)
	forum_topics(src)

def test_local():
	# save xml to file
	src=urllib.urlopen(url)
	with open(local,'w') as f:
		f.write(src.read())
	# read xml from file
	with open(local, 'r') as source:
		forum_topics(source)

if __name__ == "__main__":
	test_online()
	print " ---------------------------------------------- "
	test_local()
