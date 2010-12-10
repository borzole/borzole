#!/usr/bin/env python
#-*- coding:utf-8 -*-

# lista linków do przepisów z code.activestate.com
# rss ściąga listę 10 popularnych

import os
import urllib
from xml.dom import minidom

url="http://code.activestate.com/feeds/recipes/langs/python/"
local=os.getenv("HOME")+"/code.activestate.com.xml"

def forum_topics(source):
	DOMTree = minidom.parse(source)
	cNodes = DOMTree.childNodes
	for i in cNodes[0].getElementsByTagName("entry"):
		print i.getElementsByTagName("link")[0].getAttribute("href") + 'download/1/'

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
	test_local()
