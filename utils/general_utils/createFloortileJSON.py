
#############################
##      Libs               ##
#############################
import plistlib
import os
from plistlib import *


#############################
##      Constants          ##
#############################
C__DIRECTORY = "/Users/avihayassouline/Downloads/negev/"
C__COMPANY_NAME = "NegevCeramics"
C__BASE_URL = "http://hsm-dev-assets.s3.amazonaws.com/ConfigFiles/Ver_1/FloortileFiles/negev/"
C__LOGO = "negev_logo.png"
C__LOGO2X = "negev_logo.png"

def createFloortileJSON(i__directory):
    
    print '{'
    print '"company-name": "%s",' % C__COMPANY_NAME
    print '"base-url": "%s",' % C__BASE_URL 
    print '"logo": "%s",' % C__LOGO 
    print '"logo@2x": "%s",' % C__LOGO2X
    print '"floortiles": ['
    
    files = os.listdir(i__directory)
    for file in files[:-1]:
        if os.path.isdir(i__directory + file):
            continue;
        if (file[-3:] != "jpg" and file[-4:] != "jpeg"):
            continue;
        print '{"title": "", "filename": "%s", "tileSize": %s},' % (file, file[-6:-4])
    print '{"title": "", "filename": "%s", "tileSize": %s}' % (file, file[-6:-4])
    print ']'
    print '}'
    
    
if __name__ == "__main__":
    createFloortileJSON(C__DIRECTORY)