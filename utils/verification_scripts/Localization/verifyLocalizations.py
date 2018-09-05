#!/usr/bin/env python

############################################################################################
# verifyLocalizations.py
# v1.0
#
# iOS Dev Team
# 
# This tool compares the different localization of Homestyler and produce new localization
# files that are aligned with a given base version.
############################################################################################


#############################
##      Libs               ##
#############################
import plistlib
import os, sys

#############################
##      SETTINGS           ##
#############################
C__CHECK_LOCALIZABLE_STRINGS = True;   # Check and verify all Localizable.strings files
C__CHECK_STORYBOARD_LABELS = True;      # Check and verify all storyboard files
C__CHECK_KEYS_MATCHINGS = False;        # Check if a given key is exactly the same as base and counts it as an error


#############################
##      Constants          ##
#############################
C__STRINGS_BASE_DIRECTORY = os.getcwd() + "/CmyCasa/en.lproj/"
C__OUTPUT_BASE_DIRECTORY = os.getcwd() + "/utils/verification_scripts/Localization/output/"
C__LOCALIZABLE_STRINGS_FILENAME = "Localizable.strings"
C__MARKER_LINE = "/* ========================== MARKER TO START HERE ==========================*/\n\n"

#############################
##      PARAMETERS         ##
#############################
C__BASE_LANGUAGE = "en.lproj"
C__LANGUAGES_DIRECTORIES = {"fr.lproj", "zh-Hans.lproj", "ru.lproj", "pt.lproj", "ja.lproj", "it.lproj", "es.lproj", "de.lproj"}

#############################
##      GLOBALS            ##
#############################
g__print_to_console = False;
g__teamcity_messaging = None;

#___________________________________________________________________________________

#############################
##      CLASSES            ##
#############################
class LocalizableItem:
    def __init__(self, header=None, key=None, value=None):
        self.header = header;
        self.key = key;
        self.value = value;
        
    def __str__(self):
        return str(self.header.replace("\r\n","")) + "\n" + str(self.key.replace("\r\n","")) + " = " + str(self.value.replace("\r\n","")) + "\n" + "\n"
        
class CompareResults:
    def __init__(self, items_missing_in_base = None, items_missing_in_foreign = None):
        self.items_missing_in_base = items_missing_in_base;
        self.items_missing_in_foreign = items_missing_in_foreign;
        
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
def initLocalizationTool():
    
    global g__teamcity_messaging;
    g__teamcity_messaging = TeamcityServiceMessages();
    assert (g__teamcity_messaging != None);
    
    
    
    # Prepare output directories
    for l__language in C__LANGUAGES_DIRECTORIES:
        if not os.path.exists(C__OUTPUT_BASE_DIRECTORY + l__language):
            os.makedirs(C__OUTPUT_BASE_DIRECTORY + l__language)
   
#   Function: printToConsole()
#
#   Returns:         
def printToConsole(l__msg):
    if (g__print_to_console == True):
        print l__msg

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
    return l__list;

#   Function: listStoryboardStringKeysAndValues()
#
#   Returns:
def listStoryboardStringKeysAndValues(i__storyboard):
    l__list = {};
    l__current_comment = None;
    file_content = os.popen('cat ' + str(i__storyboard) + '| grep -v "^[[:space:]]*$"').readlines()
    for line_string in file_content:
        
        if (line_string.strip() == ""):
            continue;

        if len(line_string.split(' = ')) != 2:
            l__current_comment = line_string.rstrip();
            continue;
       
        key = line_string.split(' = ')[0];
        value = line_string.split(' = ')[1];
        
        if (l__current_comment == None or l__current_comment == ""):
            raise AssertionError("Cannot happen. Bad format of file in line" + line_string);
        
        l__list[key] = LocalizableItem(l__current_comment, key, value);
        
        l__current_comment = None;
        
    return l__list;

#   Function: listLocalizableStringKeysAndValues()
#
#   Returns: 
def listLocalizableStringKeysAndValues(i__localizable_file):
    l__list = {};
    l__current_comment = None;
    file_content = os.popen('cat ' + str(i__localizable_file) + ' | grep -v "////" | grep -v "^[[:space:]]*$"').readlines()
    for line_string in file_content:
        
        # On empty line continue
        if (line_string.strip() == ""):
            continue;
        
        # Following a split on ' = ' characters, a key item will have 2 items while a comment will have none
        if len(line_string.split(' = ')) != 2:
            l__current_comment = line_string;
            continue;
       
        # Splits the line into (key, value) pairs
        key = line_string.split(' = ')[0];
        value = line_string.split(' = ')[1];
        
        # Missing headline is possible in Localizable files
        if (l__current_comment == None or l__current_comment == ""):
            l__current_comment = "/* %s */" % (key.strip());
        
        l__list[key] = LocalizableItem(l__current_comment, key, value);
        l__current_comment = None;
    return l__list;
    

#   Function: compareBaseAndForeignDictionaries()
#
#   Returns:  
def compareBaseAndForeignDictionaries(i__base_dict, i__foreign_dict, i__foreign_name):
    
    l__items_missing_in_base = [];
    l__items_missing_in_language = [];
    
    # Check the first way -> No missing keys in base from other language
    for key in i__foreign_dict:
        if (key not in i__base_dict):
            printToConsole ("Error found. Key: " + str(key) + " was not found in base version")
            l__items_missing_in_base.append(i__foreign_dict[key]);
            continue;
            
        if (C__CHECK_KEYS_MATCHINGS):
            if i__foreign_dict[key].value == i__base_dict[key].value:
                printToConsole ("Error found. Key: " + str(key) + " is exactly as base version (perhaps there is a missing translation)")
                l__items_missing_in_base.append(i__foreign_dict[key]);

    # Check the second way -> No missing keys in other language from base
    for key in i__base_dict:
        if (key not in i__foreign_dict):
            printToConsole ("Error found. Key: " + str(key) + " was not found in language:" + i__foreign_name)
            l__items_missing_in_language.append(i__base_dict[key]);
            continue;
            
        if (C__CHECK_KEYS_MATCHINGS):
            if i__foreign_dict[key].value == i__base_dict[key].value:
                printToConsole ("Error found. Key: " + str(key) + " is exactly as base version (perhaps there is a missing translation)")
                l__items_missing_in_language.append(i__base_dict[key]);
    
    return CompareResults (l__items_missing_in_base, l__items_missing_in_language);

#   Function: processResults()
#
#   Returns:  
def processResults(i__compare_result, i__full_keyitems_dict ,i__language, i__output_filename):
    
    # Create the output file and open it in write mode
    f = open(i__output_filename, 'w');
    
    for key in i__full_keyitems_dict:
        if (key not in i__compare_result.items_missing_in_foreign) and (key not in i__compare_result.items_missing_in_base):
            f.write( str(i__full_keyitems_dict[key]) )
    
    
    if len(i__compare_result.items_missing_in_foreign) > 0:
        f.write( str(C__MARKER_LINE) ) ;
        for item in i__compare_result.items_missing_in_foreign:
            f.write( (str(item)) );
    
    # Close the file after all writing actions
    f.close()

#   Function: verifyLocalizationStringsFiles()
#
#   Returns: nothing     
def verifyStoryboardLocalizations():
    
    # Notify TeamCity that we start to test all storyboards
    l__testsuite_name = 'Storyboards localization test suite';
    g__teamcity_messaging.testSuiteStarted (l__testsuite_name);
    
    l__storyboards_strings_list = listStoryboardStringsFiles(C__STRINGS_BASE_DIRECTORY + C__BASE_LANGUAGE)
    
    # Execute for every given storyboard:
    # (1) Load the base version for comparison as a dictionary
    # (2) For each language, test that all keys exists
    for l__storyboard_string_file in l__storyboards_strings_list:
        
        # Notify TeamCity that we start to test this language
        g__teamcity_messaging.message ("Checking storyboard file:" + l__storyboard_string_file);
        
        # Step (1)
        l__base_storyboard_key_vals = listStoryboardStringKeysAndValues(C__STRINGS_BASE_DIRECTORY + C__BASE_LANGUAGE + '/' + l__storyboard_string_file)
        
        # Step (2)
        for l__language in C__LANGUAGES_DIRECTORIES:
            
            # Prepare messages for TeamCity
            l__test_name = "test_storyboard_%s_lang_%s" % (os.path.basename(l__storyboard_string_file).replace(" ",""), l__language)
            l__error_message = " Language discreprency for language: %s" % (l__language)
            l__error_description = "Testing Storyboard: %s on language: %s failed. Please check output" % (os.path.basename(l__storyboard_string_file), l__language);
            
            # Notify TeamCity that we start to test this language
            g__teamcity_messaging.testStarted (l__test_name)
            
            l__storyboard_key_vals = listStoryboardStringKeysAndValues(C__STRINGS_BASE_DIRECTORY + l__language + '/' + l__storyboard_string_file)
            
            # Compare the dictionaries to find discreprencies
            compare_results = compareBaseAndForeignDictionaries(l__base_storyboard_key_vals, l__storyboard_key_vals, l__language)
            
            if (compare_results == None):
                return;
                
             # Notify TeamCity that there is an error with this language 
            if len (compare_results.items_missing_in_foreign) > 0:
                g__teamcity_messaging.testFailed (l__test_name, l__error_message , l__error_description)
            
            l__output_filename = C__OUTPUT_BASE_DIRECTORY + l__language + "/" + l__storyboard_string_file;
            processResults(compare_results, l__storyboard_key_vals ,l__language, l__output_filename);
            
            # Notify TeamCity that we finished to test this language (even if there was an error)
            g__teamcity_messaging.testFinished(l__test_name);
    
    # Notify TeamCity that we finished to test all storyboards
    g__teamcity_messaging.testSuiteFinished (l__testsuite_name);

#   Function: verifyLocalizationStringsFiles()
#
#   Returns: nothing       
def verifyLocalizationStringsFiles():
    
    # Notify TeamCity that we start to test all storyboards
    l__testsuite_name = 'Localizable.strings test suite';
    g__teamcity_messaging.testSuiteStarted (l__testsuite_name);
    
    # Step (1) - Load the base localizable strings file
    l__base_localizable_file = listLocalizableStringKeysAndValues(C__STRINGS_BASE_DIRECTORY + '/' + C__LOCALIZABLE_STRINGS_FILENAME)
        
    # Step (2)
    for l__language in C__LANGUAGES_DIRECTORIES:
    
        # Prepare messages for TeamCity
        l__test_name = "test_localizable_strings_lang_%s" % (l__language)
        l__error_message ="Language discreprency in localizable.strings for language: %s" % (l__language)
        l__error_description = "Testing Localizable.strings on language: %s failed. Please check output" % (l__language);
        
        # Notify TeamCity that we start to test this language
        g__teamcity_messaging.testStarted (l__test_name)
    
        l__localizable_key_vals = listLocalizableStringKeysAndValues(C__STRINGS_BASE_DIRECTORY + l__language + '/' + C__LOCALIZABLE_STRINGS_FILENAME)
        
        # Compare the dictionaries to find discreprencies
        compare_results = compareBaseAndForeignDictionaries(l__base_localizable_file, l__localizable_key_vals, l__language)
        
        assert (compare_results != None);
        
         # Notify TeamCity that there is an error with this language 
        if len (compare_results.items_missing_in_foreign) > 0:
            g__teamcity_messaging.testFailed (l__test_name, l__error_message , l__error_description)
        
        l__output_filename = C__OUTPUT_BASE_DIRECTORY + l__language + "/" + C__LOCALIZABLE_STRINGS_FILENAME;
        processResults(compare_results, l__localizable_key_vals ,l__language, l__output_filename);
        
        g__teamcity_messaging.testFinished (l__test_name)
    
    g__teamcity_messaging.testSuiteFinished (l__testsuite_name);
            
#___________________________________________________________________________________
# Main
if __name__ == "__main__":
    
    # Init the tool
    initLocalizationTool();
    
    if (C__CHECK_STORYBOARD_LABELS):
        verifyStoryboardLocalizations();
    
    if (C__CHECK_LOCALIZABLE_STRINGS):
        verifyLocalizationStringsFiles();