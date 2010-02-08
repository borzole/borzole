#!/usr/bin/env python 

# http://www.shell-fu.org/lister.php?id=54
# http://localhost:8000/

# po otwarciu firewalla
# http://jedral.dyndns.com:8000

import SimpleHTTPServer;

SimpleHTTPServer.test()


# dla portu 51776 zamiast domyslnego 8000
#~ from SimpleHTTPServer import test; 
#~ import sys; 
#~ 
#~ sys.argv = [None, 51776]; 
#~ test()
