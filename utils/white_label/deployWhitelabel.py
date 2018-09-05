#!/usr/bin/env python

############################################################################################
# deployWhitelabel.py
# v1.0
#
# iOS Dev Team
############################################################################################

#############################
##      Libs               ##
#############################
import sys
import urllib
import plistlib
import zipfile, os.path
import string
import random
import errno
import shutil
import re
from plistlib import *

#############################
##      Constants          ##
#############################
C__TMP_DIRECTORY = "/tmp/"
C__BOOTSTRAP_FILE = "Bootstrap.plist"
C__ORIGINAL_BUNDLE_ID = "com.autodesk.ios.homestyler"
C__ORIGINAL_PRODUCT_NAME_STRING = "PRODUCT_NAME = Homestyler"
C__ORIGINAL_PRODUCT_NAME_TEMPLATE = "PRODUCT_NAME = \"%s\""
C__HSHOME = os.getenv('HSHOME')
C__CUSTOMIZATION_DIRECTORY = os.path.join(C__HSHOME, "CmyCasa/HSCustomization")
C__PROJECT_FILE = "Homestyler.xcodeproj/project.pbxproj"
C__BUNDLE_INFO_FILES = ["CmyCasa/Homestyler-Info.plist", "Homestyler\ Tests/Homestyler\ Tests-Info.plist", "Homestyler\ copy-Info.plist", "Homestyler.xcodeproj/project.pbxproj"]
C__STYLESHEET_FILES = ["Stylesheets/HSStyle.nss","Stylesheets/HSStyle-iPhone.nss"]
C__LOCALIZATION_DIRECTORY = os.path.join(C__HSHOME, "CmyCasa/en.lproj")
C__CONFIG_MANAGER_FILE = os.path.join(C__HSHOME, "CmyCasa/ConfigManager.m")

#############################
##        Globals          ##
#############################

#________________REPLACE STRING IN FILES USING COMMAND LINE ______________
def replaceStringWithString(i__filename, i__strOri, i__strDst):
    l__replace_cmd = "sed -i '.original' 's/%s/%s/g' %s" % (str(i__strOri), str(i__strDst), str(i__filename))
    os.popen(l__replace_cmd)

#________________UTIL FUNCTIONS___________________________________________
def id_generator(size=15, chars=string.ascii_uppercase + string.digits):
    return ''.join(random.choice(chars) for _ in range(size))

def dlProgress(count, blockSize, totalSize):
	sys.stdout.write(".")
	sys.stdout.flush()
	
def copy(src, dest):
    try:
	    l__copy_cmd = "cp -p -r %s %s" % (src, dest)
	    os.popen(l__copy_cmd)
    except OSError as e:
        # If the error was caused because the source wasn't a directory
        if e.errno == errno.ENOTDIR:
            shutil.copy(src, dst)
        else:
            print('Directory not copied. Error: %s' % e)

#________________PREPARE STYLESHEET _______________________________________
def replaceStylesheetDefs(i__original_filepath, i__new_filepath):
	l__reg = re.compile('(?<=\/\* Begin - White Label \*\/)(\r?\n)'
	                 '(.*?)'
	                 '(?=\r?\n\/\* End - White Label \*\/)',re.DOTALL)
	
	# open file handlers
	l__original_fh = open(i__original_filepath)
	l__new_fh = open(i__new_filepath,'r+')
	
	# read content from files
	l__original_content = l__original_fh.read();
	l__new_content = l__new_fh.read();
	
	# retrieve new color definitions using the regular expression
	l__new_file_colors = l__reg.search(l__new_content).group()
	
	if (l__new_file_colors == None):
		exit(1);
	
	# perform the swap between colors
	l__modified_content = l__reg.sub(l__new_file_colors, l__original_content)
	
	# Rewrite the content to the new file path
	l__new_fh.seek(0)
	l__new_fh.write(l__modified_content)
	l__new_fh.truncate()
	
	# Close open file handlers
	l__original_fh.close()
	l__new_fh.close()
	

#________________PLIST FUNCTIONS___________________________________________
def getBundleIDFromPlist(i__plist_filename):
    l__plist = readPlist(i__plist_filename)
    return l__plist["BundleID"]

def getApplicationNameFromPlist(i__plist_filename):
    l__plist = readPlist(i__plist_filename)
    return str(l__plist["AppName"])
    

#________________ZIP FILE HANDELING_______________________________________
def unzip(source_filename, dest_dir):
    with zipfile.ZipFile(source_filename) as zf:
        for member in zf.infolist():
            words = member.filename.split('/')
            path = dest_dir
            for word in words[:-2]:
                drive, word = os.path.splitdrive(word)
                head, word = os.path.split(word)
                if word in (os.curdir, os.pardir, ''):
                    continue
                path = os.path.join(path, word)
            zf.extract(member, path)


#__________COMMAND LINE ARGUMENTS VALIDATION______________________________
def checkCommandLineArgument(i__arg):
    return True;

if __name__ == "__main__":
    if (len(sys.argv) != 2):
        print "deployWhiteLabel :: Invalid arguments. Usage: python deployWhiteLabel.py <URL TO WHITELABEL ZIP FILE>"
        exit(1)

    l__white_label_file_url = sys.argv[1];
    l__random_whitelabel_name = str(id_generator());
    l__tmp_zipfile = C__TMP_DIRECTORY + l__random_whitelabel_name + ".zip"
    l__tmp_zip_dir = C__TMP_DIRECTORY + l__random_whitelabel_name + "/"
    
    if (not checkCommandLineArgument(l__white_label_file_url)):
        print "deployWhiteLabel :: Bad argument"
        exit(1)
		
    # Stage 1: Retrieve the ZIP file provided by the command line argument
    print "Starting to download whitelabel zip file"   
    urllib.urlretrieve (l__white_label_file_url, l__tmp_zipfile, reporthook=dlProgress)
    print "Finished downloading whitelabel zip file"  
    
    # Stage 2: Unpack the ZIP file in a temporary folder and validate its content
    print "Unpacking to temporary directoy"
    unzip(l__tmp_zipfile, l__tmp_zip_dir)
    
    # Stage 3: Prepare new stylesheet files based on the current base stylesheet and the WL colors
    print "Preparing new stylesheet files"
    for l__stylesheet in C__STYLESHEET_FILES:
        replaceStylesheetDefs(os.path.join(C__CUSTOMIZATION_DIRECTORY, l__stylesheet), os.path.join(l__tmp_zip_dir, l__stylesheet))
    
    # Stage 4: Replace the content of HSCustomization folder with the delivered content
    print "Copying HSCustomization content"
    copy(l__tmp_zip_dir, C__CUSTOMIZATION_DIRECTORY)
	
    # Stage 5: Replace the BundleID inside the project files
    l__bundle_id = getBundleIDFromPlist(os.path.join(C__CUSTOMIZATION_DIRECTORY, C__BOOTSTRAP_FILE))
    for l__file in C__BUNDLE_INFO_FILES:
        replaceStringWithString(str(C__HSHOME + l__file), C__ORIGINAL_BUNDLE_ID, l__bundle_id)

    # Stage 6: Replace the name of the application (Appears as the name of the application on the springboard)
    l__product_name = getApplicationNameFromPlist(os.path.join(C__CUSTOMIZATION_DIRECTORY, C__BOOTSTRAP_FILE))
    l__product_name_string = C__ORIGINAL_PRODUCT_NAME_TEMPLATE % l__product_name
    replaceStringWithString(str(C__HSHOME + "Homestyler.xcodeproj/project.pbxproj"), C__ORIGINAL_PRODUCT_NAME_STRING, l__product_name_string) 
	
    # Stage 7: Perform cleanup of temporary folders so the build server won't die
    print "Cleaning temporary files and folder"
    shutil.rmtree(l__tmp_zip_dir)
    os.remove(l__tmp_zipfile)
    
    # Exit with success error code
    exit(0)