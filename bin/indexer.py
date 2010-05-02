#!/usr/bin/env python
#-*- coding:utf-8 -*-
#
#       indexer.py
#       Version     0.2
#       Date        2010.05.02-08:49
#
#       Copyright 2009 AJ Hekman
#       This work is licensed under the
#       Creative Commons Attribution 3.0 United States License
#
#		Zmiany by Borzole:
#		- ikonki na base64 (szybsza odpowiedź serwera)
#		- ścieżka jako parametr skryptu (był 'current' na sztywno)
"""
Usage:
	indexer.py /path/to/existing/folder
	indexer.py ./folder
	indexer.py .

* if you want a particular directory to NOT be indexed:
	- create a blank file "do_not_index" in that directory
	- directories below the "do_not_index" directory will still be indexed
"""

import os,sys,datetime

# CLI
# test: czy jest dokładnie 1 parametr i czy to istniejący katalog
if len(sys.argv) == 2 and os.path.isdir(sys.argv[1]):
	path=sys.argv[1]
else:
	msg="Usage: \n\t" + os.path.basename(sys.argv[0]) + " /path/to/existing/folder"
	sys.exit(msg)

# Funkcje
def ScanDirectory(dirToScan):
    d=[]
    f=[]
    for n in os.listdir(dirToScan):
        if os.path.isfile(os.path.join(dirToScan, n)):
            f.append(n)
        else:
            d.append(n)
            ScanDirectory(os.path.join(dirToScan, n))
    d.sort()
    f.sort()
    makeIndexHTML(dirToScan, d, f)

def makeIndexHTML(localDirectory, listofDirectories, listofFiles):
    print localDirectory

    #do not index current directory if do_not_index is present
    for n in listofFiles:
        if n == "do_not_index": return

    indexf = open(os.path.join(localDirectory,"index.html"), "w")

    def parentcheck():
            #if this is the directory the script was run from, do not make link point to a parent directory
            if localDirectory == os.getcwd():
				return "../index.html"
            #if a parent directoy contains "do_not_index", do not link to it
            elif os.path.exists(os.path.join(os.path.dirname(localDirectory),"do_not_index")):
				return ""
            #if all else is good, return a valid link to parent directory
            else:
				return "../index.html"

    indexf.write(htmlHead % parentcheck() )

    for n in listofDirectories:
        #do not make link for child directory if do_not_index is present there
        childDirectory = os.path.join(localDirectory, n)
        if  os.path.exists(os.path.join(childDirectory, "do_not_index")): continue
        indexf.write(htmlDir % (n, n))

    for n in listofFiles:
        #do not list the following files, you may comment the next line out if you want them listed
        if n == "index.html" or n == "indexer.pyc" or n == ".dropbox": continue
        indexf.write(htmlFile % (n, n))

    #write footer portion
    indexf.write(htmlFoot % str(datetime.date.today()))

    indexf.close()

htmlHead = """<html>
    <head>
        <title>dropbox :: folder listing</title>
        <link rel="shortcut icon" href="http://www.getdropbox.com/static/1238803391/images/favicon.ico">
<!--
        <link type="text/css" rel="stylesheet" href="http://dl.dropbox.com/u/409786/web/css/indexpy.css">
-->
        <style type="text/css"><!--

body, td {
	font-family:lucida grande, lucida sans unicode, verdana;
	font-size:13px;
	line-height:16px;
}
a { color:#1f75cc; text-decoration:none; }
a:hover { color:#FFA500; text-decoration:underline; }
a:visited { color:#96B630; text-decoration:none; }
a:visited:hover { color:#A52A2A; text-decoration:underline; }

.up,
.dir,
.file {
	background-color:transparent;
	background-repeat:no-repeat;
	background-attachment:scroll;
	opacity:1;
	display:block;
	padding-left: 20px;
}
/*
.up   { background-image:url(http://dl.dropbox.com/u/409786/web/img/up.png);}
.dir  { background-image:url(http://dl.dropbox.com/u/409786/web/img/folder.png);}
.file { background-image:url(http://dl.dropbox.com/u/409786/web/img/file.png);}
*/
/* $ base64 up.png */
.up   { background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAALGPC/xhBQAAAYhJREFUOE/NkctKAnEYxYWeo5doEV000lRSjOwixYBiJmhNkXShKIQuVuYlRydtMs0sElIKN2a16h6ZWY31Ai17idOM4CIKdFr1X37/8x3Od34i0b97qoDUIfe0uP4UrCvaTo0em2FNGqHwiOmqTXRJXU1/QhuZyoxgq+BHKL8Oy6ERbe7mGP9X0Wgg3TejT3Wz02djiL4EES4EQB4NQkm1sjKXeK6iQVlgSPUizjKIPNPo2lah6sWykEuC/WIYsdcQdLsa4QbmNPHJL8eLDCazI+jZUfkEpbCcENmNvJvrgQbzRKF/T/MhyIQ819sct7NIvEexx53C05jIDHNJ1OhklFDTMii9LZA6myBZrEeDve77meOXxlrrmSFN5VZx8BZB+NlfosKjDT56QeXW4LlfhvN2AY4rO8QL9T97Ii9MjbzJ0vUM/A9O7LKbJSpMwQc654GPm7nuHFi5mUfrSuPvRQ9xSchTvc2cIbImjgyPl0hooYtrSng7Qgq0U1LI3RLhpARRqUb8BdSx2Yn+pc4BAAAAAElFTkSuQmCC");}
.dir  { background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAGrSURBVDjLxZO7ihRBFIa/6u0ZW7GHBUV0UQQTZzd3QdhMQxOfwMRXEANBMNQX0MzAzFAwEzHwARbNFDdwEd31Mj3X7a6uOr9BtzNjYjKBJ6nicP7v3KqcJFaxhBVtZUAK8OHlld2st7Xl3DJPVONP+zEUV4HqL5UDYHr5xvuQAjgl/Qs7TzvOOVAjxjlC+ePSwe6DfbVegLVuT4r14eTr6zvA8xSAoBLzx6pvj4l+DZIezuVkG9fY2H7YRQIMZIBwycmzH1/s3F8AapfIPNF3kQk7+kw9PWBy+IZOdg5Ug3mkAATy/t0usovzGeCUWTjCz0B+Sj0ekfdvkZ3abBv+U4GaCtJ1iEm6ANQJ6fEzrG/engcKw/wXQvEKxSEKQxRGKE7Izt+DSiwBJMUSm71rguMYhQKrBygOIRStf4TiFFRBvbRGKiQLWP29yRSHKBTtfdBmHs0BUpgvtgF4yRFR+NUKi0XZcYjCeCG2smkzLAHkbRBmP0/Uk26O5YnUActBp1GsAI+S5nRJJJal5K1aAMrq0d6Tm9uI6zjyf75dAe6tx/SsWeD//o2/Ab6IH3/h25pOAAAAAElFTkSuQmCC");}
.file { background-image:url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAABGdBTUEAAK/INwWK6QAAABl0RVh0U29mdHdhcmUAQWRvYmUgSW1hZ2VSZWFkeXHJZTwAAAC4SURBVCjPdZFbDsIgEEWnrsMm7oGGfZrohxvU+Iq1TyjU60Bf1pac4Yc5YS4ZAtGWBMk/drQBOVwJlZrWYkLhsB8UV9K0BUrPGy9cWbng2CtEEUmLGppPjRwpbixUKHBiZRS0p+ZGhvs4irNEvWD8heHpbsyDXznPhYFOyTjJc13olIqzZCHBouE0FRMUjA+s1gTjaRgVFpqRwC8mfoXPPEVPS7LbRaJL2y7bOifRCTEli3U7BMWgLzKlW/CuebZPAAAAAElFTkSuQmCC");}

        --></style>
    </head>
    <body><center>
        <table border="0" cellspacing="0" cellpadding="2" width="800" >
            <tr><td>
                <a href="http://www.getdropbox.com/">
                    <img border="0" alt="dropbox" src="http://www.getdropbox.com/static/images/main_logo.png">
                </a>
                <hr size="1" color="#c0c0c0">
            </td></tr>
            <tr><td><b>folder contents:</b></td></tr>
            <tr><td><a class="up" href="%s">parent directory</a></td></tr>"""

htmlDir = """
            <tr><td><a class="dir" href="%s/index.html">%s</a></td></tr>"""

htmlFile = """
            <tr><td><a class="file" href="%s">%s</a></td></tr>"""

htmlFoot = """
            <tr><td>
              <hr size="1" color="#c0c0c0">
              <font color="#808080">generated on %s</font>
            </td></tr>
            <tr><td align="right">
              <img border="0" alt="dropbox" src="data:image/gif;base64,R0lGODlhFAAUAOZNAMrKyvLy8urq6sfHx6mpqe3t7aenp+jo6NTU1MjIyKioqNjY2MzMzNzc3Pb29qysrM7OztPT0+Xl5aWlpdLS0u/v7/T09Nra2snJyba2tqurq9vb297e3vr6+sHBwfDw8MLCwrOzs7CwsL29vbm5ua+vr5qamsDAwOLi4ri4uL+/v7y8vPPz8/n5+aGhoaSkpL6+vp6enuHh4bW1tcbGxqKiotfX17GxsZ+fn6Ojo9nZ2d/f37e3t8/Pz8TExIiIiPX19a6urs3NzdbW1rKysuvr68vLy6qqqsPDw8XFxaampvj4+NHR0fv7+wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAE0ALAAAAAAUABQAAAfugE2Cg4SFhoeIiRZBBi2DRwoBiRs5DEwagg8wDAoIhkshBEwXKDYGLiQUCxwjIkCEJjNMTAgXEjIDAwAUDQcbNYQAMZYRGwUdFjtCPQ0SJDSFOjgAHAVLSwEWBRwLJUyHCQ8VSw5LHwEdSzArhwsTICAH1wEOAgBMPBCFSS8QAyUeUGBjQuAGAgkqThCaIILCACIeMBwY8MNAiggChigg1GKEAh8hkCwQcMIAgRQIVmRwYOiCiQQMBFQAkCBDAg3fEL1gcqBCgQEQGkRQkqgJCwIAzt1ToYFFUUEYMgjA4MLIU0JFHkwQcLWr10SBAAA7">
              <font color="#808080">&copy; 2009 dropbox</font>
            </td></tr>
        </table>
    </body>
</html>"""

# Go!
ScanDirectory(path)
