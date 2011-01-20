#!/usr/bin/env python
#-*- coding:utf-8 -*-

# Fedora Weekly News

import urlparse, urllib
import BeautifulSoup

url="https://fedoraproject.org/w/index.php?title=FWN/Issue"

for i in reversed(range(248,249,1)):
	soup = BeautifulSoup.BeautifulSoup(urllib.urlopen(url+str(i)))
	for link in soup.findAll('a'):
		k,s = link.attrs[0] #, link.contents
		if k == 'href' and s.startswith('http'):
			print s
