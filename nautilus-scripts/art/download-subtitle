#!/usr/bin/env python

# Download subtitles from opensubtitles.org (nautilus version)
# Default language is english, to change the language change sublanguageid parameter
# in the searchlist.append function

# Carlos Acedo (carlos@linux-labs.net)
# Inspired on subdownloader
# License GPL v2

import os
import struct 
import subprocess
from xmlrpclib import ServerProxy, Error


def hashFile(name): 
      try: 
                longlongformat = 'q'  # long long 
                bytesize = struct.calcsize(longlongformat) 
                    
                f = open(name, "rb") 
                    
                filesize = os.path.getsize(name) 
                hash = filesize 
                    
                if filesize < 65536 * 2: 
                       return "SizeError" 
                 
                for x in range(65536/bytesize): 
                        buffer = f.read(bytesize) 
                        (l_value,)= struct.unpack(longlongformat, buffer)  
                        hash += l_value 
                        hash = hash & 0xFFFFFFFFFFFFFFFF #to remain as 64bit number  
                         
    
                f.seek(max(0,filesize-65536),0) 
                for x in range(65536/bytesize): 
                        buffer = f.read(bytesize) 
                        (l_value,)= struct.unpack(longlongformat, buffer)  
                        hash += l_value 
                        hash = hash & 0xFFFFFFFFFFFFFFFF 
                 
                f.close() 
                returnedhash =  "%016x" % hash 
                return returnedhash 
    
      except(IOError): 
                return "IOError"

# ================== Main program ========================

server = ServerProxy("http://api.opensubtitles.org/xml-rpc")
peli = os.environ['NAUTILUS_SCRIPT_SELECTED_FILE_PATHS'].strip('\n')

try:
    myhash = hashFile(peli)
    print myhash
    size = os.path.getsize(peli)
    session =  server.LogIn("","","en","python")
    print session
    token = session["token"]
    
    searchlist = []
    searchlist.append({'moviehash':myhash,'moviebytesize':str(size)})
    
    moviesList = server.SearchSubtitles(token, searchlist)
    print(moviesList)
    if moviesList['data']:
        kdialog_items = []
        for item in moviesList['data']:
            kdialog_items += [item['SubFileName'],item['LanguageName'],item['MatchedBy']]
    
        args = ['zenity','--list','--width=600','--height=400','--text=Select subtitle',]
        args += ['--column=File name','--column=Lang','--column=Mathed by']
    
        resp = subprocess.Popen(args+ kdialog_items,stdout=subprocess.PIPE).communicate()[0].strip('\n')

        if resp != '':
            index = 0
            data = moviesList['data']
            
            while index < len(data) and data[index]['SubFileName'] != resp:
                index += 1

            sub = data[index]
            
            subFileName = os.path.splitext(os.path.basename(peli))[0] + os.path.splitext(sub['SubFileName'])[1]
            subDirName = os.path.dirname(peli)
            subURL = sub['SubDownloadLink']
            
            response = os.system("wget -O - '{0}' | gunzip  >  {1}".format(subURL, os.path.join(subDirName,subFileName)))
            
            if response != 0:
                os.system('zenity --error --text="An error ocurred downloading or writing the subtitle"')
        
    else:
        os.system('zenity --error --text="No subtitles found"')
    
    server.Logout(session["token"])
except Error, v:
    os.system('zenity --error --text="An error ocurred"')



