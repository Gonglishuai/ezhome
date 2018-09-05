#!/usr/bin/env python

############################################################################################
# verifyLocalizations.py
# v1.0
#
# iOS Dev Team
# 
# This tool searches the source code of Homestyler for unused assets to help and reduce
# the footprint of the applciation to mininum
############################################################################################


#############################
##      Libs               ##
#############################
import os, sys

#############################
##      SETTINGS           ##
#############################
C__LOOK_STORYBOARD_FILES = True;            # Search for assets requirements in storyboard files
C__LOOK_PLIST_FILES = True;                 # Search for assets requirements in plist files
C__LOOK_XIB_FILES = True;                   # Search for assets requirements in xib files
C__MOVE_FILES_TO_OUTPUT_DIRECTORY = False;   # If true, moves the files to the output directory :: WARNING!!!!! Cannot be undone!


#############################
##      Constants          ##
#############################

C__STRINGS_BASE_DIRECTORY = os.getenv('HSHOME') + "/CmyCasa/en.lproj/Base.lproj"
C__PROJECT_BASE_DIRECTORY = os.getenv('HSHOME') + "/CmyCasa/"
C__OUTPUT_DIRECTORY = os.getenv('HSHOME') + "/utils/verification_scripts/Assets/tmp"

#############################
##      PARAMETERS         ##
#############################


#############################
##      Whitelist          ##
#############################

# TODO: Extract to txt file
C__WHITE_LIST = ["Default-568h","homestyler_logo"];


#############################
##      GLOBALS            ##
#############################
g__print_to_console = False;
g__teamcity_messaging = None;


#############################
##      CLASSES            ##
#############################
 
class FileSystemAsset:
    def __init__(self, filePath = None, fileSize = None, assetRepresentaion = None):
        self.filePath = filePath;
        self.fileSize = fileSize;
        self.assetRepresentaion = assetRepresentaion;
       
class TeamcityServiceMessages:
    quote = {"'": "|'", "|": "||", "\n": "|n", "\r": "|r", ']': '|]'}

    def __init__(self, output=sys.stdout):
        self.output = output

    def escapeValue(self, value):
        return "".join([self.quote.get(x, x) for x in value])

    def message(self, messageName, **properties):
        self.output.write("\n##teamcity[" + messageName)
        for k in sorted(properties.keys()):
            self.output.write(" %s='%s'" % (k, self.escapeValue(properties[k])))
        self.output.write("]\n")

    def testSuiteStarted(self, suiteName):
        self.message('testSuiteStarted', name=suiteName)

    def testSuiteFinished(self, suiteName):
        self.message('testSuiteFinished', name=suiteName)

    def testStarted(self, testName):
        self.message('testStarted', name=testName)

    def testFinished(self, testName):
        self.message('testFinished', name=testName)

    def testIgnored(self, testName, message=''):
        self.message('testIgnored', name=testName, message=message)

    def testFailed(self, testName, message='', details=''):
        self.message('testFailed', name=testName,
                     message=message, details=details)

    def testStdOut(self, testName, out):
        self.message('testStdOut', name=testName, out=out)

    def testStdErr(self, testName, out):
        self.message('testStdErr', name=testName, out=out)

        
#___________________________________________________________________________________

#   Function: initLocalizationTool()
#
#   Initialized the tool by creating the appropriate needed directories
#
#   Returns: 
def initAssetsTool():
    
    global g__teamcity_messaging;
    g__teamcity_messaging = TeamcityServiceMessages();
    assert (g__teamcity_messaging != None);
    
    if (C__MOVE_FILES_TO_OUTPUT_DIRECTORY):
        if not os.path.exists(C__OUTPUT_DIRECTORY):
            os.makedirs(C__OUTPUT_DIRECTORY)
   
#   Function: printToConsole()
#
#   Returns:         
def printToConsole(l__msg):
    if (g__print_to_console == True):
        print l__msg


#_______________STORYBOARD HANDELING_______________________________________________________

#   Function: listStoryboardStringKeysAndValues()
#
#   Returns:
def listStoryboardStringsFiles(i__directory):
    l__list = [];
    files = os.listdir(i__directory)
    for file in files:
        if os.path.isdir(i__directory + file):
            raise Exception("A directory was located and it is a violation of the strings directory");
        
        if file.startswith('.'):
            continue;
        
        l__list.append(file);
    
    l__count_message = "There are %d storyboards in the project" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    
    return l__list;
    

    
#   Function: 
#
#   Returns:
def listAssetsFromFile(i__file):
    l__list = [];
    l__current_comment = None;
    # The following command open i__file source, looks for .png or .jpg files refreneces and extract them
    l__cmd  = 'cat ' + i__file +  "| grep -o '[a-z_A-Z0-9_\-]*.png\|[a-zA-Z0-9_\-]*.jpg'";
    file_content = os.popen(l__cmd).readlines()
    for l__asset in file_content:
        
        if (l__asset.strip() == ""):
            continue;
        
        l__asset = l__asset.replace(".png", "").replace(".jpg", "").rstrip('\r\n');
        l__list.append(l__asset);
        
    #l__count_message = "There are %d used assets in storyboard %s" % (len(l__list), os.path.basename(i__file));
    #g__teamcity_messaging.message(l__count_message);  
    return l__list;

#_______________PLIST HANDELING_______________________________________________________

#   Function: listPlistStringsFiles()
#
#   Returns:
def listPlistFiles(i__directory):
    l__list = [];
    # The following command search for all nested files under i__directory for plist files
    l__cmd = 'find  '+ i__directory +' -iname "*.plist" -type f | grep -v models | grep -v 3rd';
    assets_cmd_output = os.popen(l__cmd).readlines()
    for file in assets_cmd_output:
        
        if os.path.isdir(i__directory + file):
            continue;
        
        if file.startswith('.'):
            continue;
        
        l__list.append (file.rstrip('\r\n').replace(" ", "\ "))
    
    l__count_message = "There are %d plist files which are in the project root directory" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    return l__list;


#_______________XIB FILES HANDELING_______________________________________________________

#   Function: listPlistStringsFiles()
#
#   Returns:
def listXIBFiles(i__directory):
    l__list = [];
    # The following command search for all nested files under i__directory for xib files
    l__cmd = 'find  '+ i__directory +' -iname "*.xib" -type f | grep -v models | grep -v 3rd';
    assets_cmd_output = os.popen(l__cmd).readlines()
    for file in assets_cmd_output:
        
        if os.path.isdir(i__directory + file):
            continue;
        
        if file.startswith('.'):
            continue;
        
        l__list.append (file.rstrip('\r\n').replace(" ", "\ "))
    
    l__count_message = "There are %d xib files which are in the project root directory" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    return l__list;

#_______________SOURCE FILES ASSET LITERAL LOOKUP_______________________________________________________

#   Function: listSourceStrings()
#
#   Returns:
def listSourceStrings(i__src_directory):
    l__list = [];
    # The following command list all files nested under i__src_directory which are *.m or *.mm or *.h (a.k.a source files)
    l__cmd_list_files = 'find  '+ i__src_directory + " -iname '*.m' -or -iname '*.mm' -or -iname '*.h' -type f"
    l__file_list = os.popen(l__cmd_list_files).readlines()
    for file in l__file_list:
        if os.path.isdir(i__src_directory + file):
            continue;
        
        if file.startswith('.'):
            continue;
        
        # The following command open file source and look for all @"" literals using regex
        l__cmd_strip_literals =  'cat ' + file.strip().replace(" ", "\ ") +  "| egrep -o %s" % ('@\\"[a-z_A-Z0-9_\-].*?\\"');
        l__literal_list = os.popen(l__cmd_strip_literals).readlines()
        
        for literal in l__literal_list:
            if literal not in l__list:
                # Strip the literal so only the string remains
                literal = literal.replace("\"","").replace("@","").replace(".png", "").replace(".jpg", "").strip()
                if (literal != ""):
                    l__list.append(literal);
    
    l__count_message = "There are %d different literals in the project" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    return l__list;

#_______________PROCESSING FUNCTIONS_______________________________________________________

#   Function: listAssetFiles()
#
#   Returns:
def listAssetFiles(i__directory):
    l__list = [];
    # The following command list all files nested under i__directory which are .png or .jpg without all strings which are noted after each 'grep -v <string to reject>'
    assets_cmd_output = os.popen('find  '+ i__directory +' -iname "*.png" -or -iname "*.jpg" -type f | grep -v HSCusto | grep -v models | grep -v Effects | grep -v effects | grep -v 2X | grep -v 2x').readlines()
    for file in assets_cmd_output:
        if os.path.isdir(i__directory + file):
            continue;
        
        if file.startswith('.'):
            continue;
        
        l__filepath = file;
        l__assetname = os.path.basename(file).replace(".png", "").replace(".jpg", "").rstrip('\r\n');
        l__list.append (FileSystemAsset(l__filepath, os.stat(file.strip()).st_size, l__assetname));
    
    l__count_message = "There are %d assets which are in the project root directory" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    return l__list;
 
 
#   Function: listAssetFiles()
#
#   Returns:
def listRetinaAssetFiles(i__directory):
    l__list = [];
    # The following command list all files nested under i__directory which are .png or .jpg without all strings which are noted after each 'grep -v <string to reject>'
    assets_cmd_output = os.popen('find  '+ i__directory +' -iname "*.png" -or -iname "*.jpg" -type f | grep -v HSCusto | grep -v models | grep -v Effects | grep -v effects | grep 2x').readlines()
    for file in assets_cmd_output:
        if os.path.isdir(i__directory + file):
            continue;
        
        if file.startswith('.'):
            continue;
        
        l__filepath = file;
        l__assetname = os.path.basename(file).replace(".png", "").replace(".jpg", "").rstrip('\r\n');
        l__list.append (FileSystemAsset(l__filepath, os.stat(file.strip()).st_size, l__assetname));
    
    l__count_message = "There are %d retina assets which are in the project root directory" % (len(l__list));
    g__teamcity_messaging.message(l__count_message);
    return l__list;
    
def loadAssetRefrencesFromAllSources():
    l__final_assets = [];
    
    # Load all image files from storyboards
    l__storyboard_assets = [];
    if (C__LOOK_STORYBOARD_FILES):
        l__storyboard_files = listStoryboardStringsFiles (C__STRINGS_BASE_DIRECTORY);
        for l__storyboard in l__storyboard_files:
            l__assets = listAssetsFromFile(C__STRINGS_BASE_DIRECTORY + '/' + l__storyboard);
            l__storyboard_assets.extend (l__assets);
        
        l__count_message = "There are %d assets used in all storyboards" % (len(l__storyboard_assets));
        g__teamcity_messaging.message(l__count_message);
    l__final_assets.extend(l__storyboard_assets)
    
    # Load all image file names from PList files
    l__plist_assets = [];
    if (C__LOOK_PLIST_FILES):
        l__plist_files = listPlistFiles (C__PROJECT_BASE_DIRECTORY);
        for l__plist_file in l__plist_files:
            l__assets = listAssetsFromFile(l__plist_file);
            l__plist_assets.extend (l__assets);
        
        l__count_message = "There are %d assets used in all plist files" % (len(l__plist_assets));
        g__teamcity_messaging.message(l__count_message);
    l__final_assets.extend(l__plist_assets)
    
    # Load all image file names from XIB files
    l__xib_assets = [];
    if (C__LOOK_XIB_FILES):
        l__xib_files = listXIBFiles (C__PROJECT_BASE_DIRECTORY);
        for l__xib_file in l__xib_files:
            l__assets = listAssetsFromFile(l__xib_file);
            l__xib_assets.extend (l__assets);
        
        l__count_message = "There are %d assets used in all XIB files" % (len(l__xib_assets));
        g__teamcity_messaging.message(l__count_message);
    l__final_assets.extend(l__xib_assets)
        
    return l__final_assets;
    

def validateAssets():
    
    # Notify TeamCity that we start to test all storyboards
    l__testsuite_name = 'Unused Assets Test Suit';
    g__teamcity_messaging.testSuiteStarted (l__testsuite_name);
    
    # Prepare test message for TeamCity
    l__test_name = "test_unused_assets";
    
    # Notify TeamCity that we start to test this language
    g__teamcity_messaging.testStarted (l__test_name)
    
    # Load all asset files (.png or .jpg files)
    l__list_of_assets = listAssetFiles (C__PROJECT_BASE_DIRECTORY);
    
    # Load all retina asset files (.png or .jpg files)
    l__list_of_retina_assets = listRetinaAssetFiles (C__PROJECT_BASE_DIRECTORY);
    
    # Load all references to assets from the different sources (Storyboards, plist files, XIB files)
    l__final_assets = loadAssetRefrencesFromAllSources();
    
    # Load all strings withing the source code
    l__source_strings = listSourceStrings(C__PROJECT_BASE_DIRECTORY);
    
    # Search the list of assets and check if it is required by a storyboard or the source code
    l__counter = 0;
    l__total_size = 0;
    l__unused_assets = [];
    
    for asset in l__list_of_assets:
        if (asset.assetRepresentaion not in l__final_assets) and (asset.assetRepresentaion not in C__WHITE_LIST) and (asset.assetRepresentaion not in l__source_strings):
            printToConsole ("Unused asset:" + asset.assetRepresentaion)
            l__unused_assets.append(asset.filePath.strip())
            l__counter = l__counter + 1;
            l__total_size = l__total_size + asset.fileSize;
            
            # Check if there exists a retina sized file of the same size - Can also be removed
            l__file_2x = asset.filePath.strip().replace(asset.assetRepresentaion, asset.assetRepresentaion + "@2x")
            if os.path.isfile(l__file_2x):
                l__unused_assets.append(l__file_2x)
                l__counter = l__counter + 1;
                l__total_size = l__total_size + os.stat(l__file_2x.strip()).st_size;
                
    # Check if there are retina images with no non-retina image (mistakes)
    for asset in l__list_of_retina_assets:
        if (asset.assetRepresentaion.replace("@2x","") not in l__final_assets) and (asset.assetRepresentaion.replace("@2x","") not in l__source_strings):
            printToConsole ("Unused retina asset:" + asset.assetRepresentaion.replace("@2x",""))
            l__unused_assets.append(asset.filePath.strip())
            l__counter = l__counter + 1;
            l__total_size = l__total_size + asset.fileSize;
    
    # Iterate the unused assets and:
    # (1) In case the move flag is on, move the files to the output directory
    # (2) Build the outgoing message to TeamCity            
    l__details = "Unused files:\n"
    for l__unused_asset in l__unused_assets:
        if (C__MOVE_FILES_TO_OUTPUT_DIRECTORY):
            os.rename(l__unused_asset,  C__OUTPUT_DIRECTORY + "/" + os.path.basename(l__unused_asset))
        l__details = l__details + l__unused_asset.strip() + "\n"
        
    # If the unused counter is greater then 0, report a failure of the test
    if l__counter > 0:
        l__error_message = "There are %d different assets are not used in the project with total size: %d KB" % (l__counter, l__total_size / 1024); # Division by 1024 is to convert bytes to KB
        g__teamcity_messaging.testFailed (l__test_name, l__error_message , l__details)
    
    
    # Notify TeamCity that we finished the current TestSuite
    g__teamcity_messaging.testFinished (l__test_name)
    g__teamcity_messaging.testSuiteFinished (l__testsuite_name);
    
    return l__source_strings;
            
#___________________________________________________________________________________
# Main
if __name__ == "__main__":
    # Issue a warning if C__MOVE_FILES_TO_OUTPUT_DIRECTORY flag is on
    if C__MOVE_FILES_TO_OUTPUT_DIRECTORY:
        print "WARNING!!!! You are about to move all your assets to the temp folder. ";
        input = raw_input("Are you sure you want to continue ? [y\\n]");
        if not (input == "y"):
            sys.exit(0);
        
    
    # Init the tool
    initAssetsTool();
    
    # Run the tool
    validateAssets();
