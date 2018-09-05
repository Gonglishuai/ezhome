
#############################
##      Libs               ##
#############################
import plistlib
from plistlib import *


#############################
##      Constants          ##
#############################
C__PLIST_FILE = "android.plist"
C__APP_VERSION_BUILD_ID = '1.3.2'
C__APP_CONFIG_VERSION_ID = '6'
C__APP_TYPE = 2 # iOS app type
C__TRUE_STRING = 'YES'
C__DEFAULT_PARENT = 'NULL'
C__EMPTY_KEY  = 'NULL'


#############################
# PLIST DATABASE DATA TYPES #
#############################
C__TYPE_ARRAY_ID = 0
C__TYPE_INT_ID = 1
C__TYPE_STRING_ID = 2
C__TYPE_BOOL_ID = 3
C__TYPE_DICT_ID = 4
C__TYPE_FLOAT_ID = 5


#############################
##        Globals          ##
#############################
g__current_parent_id = 0;


#############################
## MySQL Connection Config ##
#############################
# MySQLconfig = {
#   'user': 'hsmroot',
#   'password': 'hsm123**',
#   'host': 'hsmdb.alpha.homestyler.com',
#   'port':'3306',
#   'database': 'hsmdbp',
#   'raise_on_warnings': True,
# }

def key2String(key):
    a = str('\'' + str(key) + '\'')
    return a


def printInsertStatement(i__arg_a, i__arg_b, i__arg_c, i__arg_d, i__arg_e, i__arg_f):
    print 'INSERT INTO hsmdb.AppConfig (AppConfigVersionID, AppConfigID, ConfigValueTypeID,AppConfigDesc,AppConfigValue,AppConfigParentID) VALUES (%s, %s, %s, %s, %s, %s);' %  (i__arg_a, i__arg_b, i__arg_c, i__arg_d, i__arg_e, i__arg_f)

def parseSubItemList(i__dict, i__parent_id, i__item_fh):
    global g__current_parent_id;
    l__local_parent_id = g__current_parent_id;
    for key in range(0, len(i__dict)):
        g__current_parent_id += 1;
        i__item_fh.write(str(g__current_parent_id) +": " + "Item "+ str(key) + "\n")
        
        if isinstance(i__dict[key], bool):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_BOOL_ID, key2String("Item "+ str(key)), key2String(i__dict[key]), i__parent_id)
            continue
        if isinstance(i__dict[key], basestring):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_STRING_ID, key2String("Item "+ str(key)),key2String(i__dict[key]), i__parent_id)
            continue  
        elif isinstance(i__dict[key], int):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_INT_ID, key2String("Item "+ str(key)), str(i__dict[key]), i__parent_id)
            continue   
        elif isinstance(i__dict[key], float):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_FLOAT_ID, key2String("Item "+ str(key)), str(i__dict[key]), i__parent_id)
            continue   
        elif isinstance(i__dict[key], list):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_ARRAY_ID, key2String("Item "+ str(key)), C__EMPTY_KEY, i__parent_id)
            parseSubItemList(i__dict[key], g__current_parent_id, i__item_fh)
            continue
        elif isinstance(i__dict[key], plistlib._InternalDict):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_DICT_ID, key2String("Item "+ str(key)), C__EMPTY_KEY, i__parent_id)
            parseSubItemDict(i__dict[key], g__current_parent_id, i__item_fh)
            continue
        
        else:
            print "ERROR PARSING PLIST FILE :: UNKNOWN TYPE FOR TYPE %s" % str(type(i__dict[key]))

def parseSubItemDict(i__dict, i__parent_id, i__item_fh):
    global g__current_parent_id;
    l__local_parent_id = g__current_parent_id;
    for key in i__dict:
        g__current_parent_id += 1;
        i__item_fh.write(str(g__current_parent_id) +": " + str(key) + "\n")
        
        if isinstance(i__dict[key], bool):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_BOOL_ID, key2String(key), key2String(i__dict[key]), i__parent_id)
            continue
        if isinstance(i__dict[key], basestring):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_STRING_ID, key2String(key), key2String(i__dict[key]), i__parent_id)
            continue
        elif isinstance(i__dict[key], int):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_INT_ID, key2String(key), str(i__dict[key]), i__parent_id)
            continue
        elif isinstance(i__dict[key], float):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_FLOAT_ID, key2String(key), str(i__dict[key]), i__parent_id)
            continue
        elif isinstance(i__dict[key], list):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_ARRAY_ID, key2String(key), C__EMPTY_KEY, i__parent_id)
            parseSubItemList(i__dict[key], g__current_parent_id, i__item_fh)
            continue
        elif isinstance(i__dict[key], plistlib._InternalDict):
            printInsertStatement(C__APP_CONFIG_VERSION_ID, g__current_parent_id, C__TYPE_DICT_ID, key2String(key), C__EMPTY_KEY, i__parent_id)
            parseSubItemDict(i__dict[key], g__current_parent_id, i__item_fh)
            continue
       
        else:
            print "ERROR PARSING PLIST FILE :: UNKNOWN TYPE FOR TYPE %s" % str(type(i__dict[key]))
    

def parsePlist(i__plist_filename):
    l__items_fh = open('items.log', 'w')
    l__plist = readPlist(i__plist_filename)
    print "INSERT INTO AppVersion (AppType, AppVersionBuildID, AppConfigVersionID ) VALUES (%s, %s, %s);" % (C__APP_TYPE, C__APP_VERSION_BUILD_ID, C__APP_CONFIG_VERSION_ID)
    parseSubItemDict(l__plist, "NULL", l__items_fh)
    l__items_fh.close()
    
def initPlist():
    print "INSERT INTO hsmdb.AppConfigVersions VALUES ();"
    print "SELECT LAST_INSERT_ID();"

if __name__ == "__main__":
    parsePlist(C__PLIST_FILE)