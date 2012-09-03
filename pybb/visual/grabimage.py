"""
grabimage.py

Author: James Howard

File used to grab images from a given website.

Usage: grabimage <website> <savelocation> <numimages> <time between reading>
    
example usage:
    python grabimage http://argus0.mines.edu/image.jpg ./images/ 10 2
"""


import urllib
import sys
import time

if __name__ == "__main__":

    if len(sys.argv) != 5:
        print 'usage python grabimage "http://argus0.mines.edu/image.jpg"' + \
                '"./images/" 10 2'
                
    else:
        print "taking images."
        url = sys.argv[1]
        sl = sys.argv[2]

        for i in range(int(sys.argv[3])):
            print "."
            urllib.urlretrieve(url, sl + str(i) + ".jpg")
            time.sleep(float(sys.argv[4]))