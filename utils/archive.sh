#!/bin/bash

xcode-select --print-path

# add file permissions if needed
# chmod u+x archive.sh

DIR=$(cd $(dirname "$0"); pwd)

PROJECT_ROOT="$DIR/.."
<<<<<<< HEAD
DEVELOPER_NAME="Avihay Assouline (TD43LB338Y)"
PROVISIONING_PROFILE="$PROJECT_ROOT/utils/external_files/Homestyler_Dev.mobileprovision"
=======
DEVELOPER_NAME="Avihay Assouline (H9DZ972ZT3)"
PROVISIONING_PROFILE="$PROJECT_ROOT/utils/external_files/Homestyler_Internal_Development.mobileprovision"
>>>>>>> Development_NBE

WORKSPACE="$PROJECT_ROOT/Homestyler.xcworkspace"
SCHEME=$3
CONFIGURATION=$1;#"Production_release"
BUMPVERSION=$2
SDK="iphoneos"
APPNAME="Homestyler"



#********** Testflight Params**************
TF_NOTES="CI Build $CONFIGURATION"
TF_SEND_GROUP="CI group"

#********** Testflight Params**************

echo $PROVISIONING_PROFILE
echo $WORKSPACE
echo $BUILDDIR
echo "Current Configuration is $CONFIGURATION"
echo "Current Scheme is $SCHEME"


cd $PROJECT_ROOT

# echo "*************************"
# echo "* update version number *"
# echo "*************************"
# agvtool bump -all
agvtool new-version -all $BUMPVERSION


VERSION_NUMBER="$(agvtool mvers -terse1)_$(agvtool vers -terse)"
BUILDDIR="$PROJECT_ROOT/archive/$VERSION_NUMBER"
OUTPUTDIR="$BUILDDIR/Applications"

echo "##teamcity[progressMessage 'Clear output folders']"
rm -rf $OUTPUTDIR
mkdir -p $OUTPUTDIR


IPA_NAME="$APPNAME$VERSION_NUMBER$CONFIGURATION"
echo "********************"
echo "*     Cleaning     *"
echo "********************"
echo "##teamcity[progressMessage 'Clean all targets']"
xcodebuild -alltargets clean
echo "##teamcity[progressMessage 'Finished Clean all targets']"


echo "********************"
echo "*     Archiving     *"
echo "********************"
echo "##teamcity[progressMessage 'Started archiving Project']"
xcodebuild -workspace $WORKSPACE -scheme $SCHEME -configuration $CONFIGURATION DSTROOT=$BUILDDIR DWARF_DSYM_FOLDER_PATH=$OUTPUTDIR archive
echo "##teamcity[progressMessage 'Finished archiving Project']"

# # echo "********************"
# # echo "*     Building     *" 
# # echo "********************"
# # xcodebuild -sdk "$SDK" -target $TARGET -configuration "$CONFIG" OBJROOT=$BUILDDIR SYMROOT=$BUILDDIR

echo "********************"
echo "*     Dsym link    *"
echo "********************"
echo "##teamcity[progressMessage 'Started generating DSYM file zip']"
DSYM_FILE="$OUTPUTDIR/Homestyler.app.dSYM"
zip -r -9 "$DSYM_FILE.zip" "$DSYM_FILE"
echo "##teamcity[progressMessage 'Finished generating DSYM file zip']"

echo "********************"
echo "*     Signing      *"
echo "********************"
echo "##teamcity[progressMessage 'Started signing .IPA file']"
xcrun -log -sdk iphoneos PackageApplication -v "$OUTPUTDIR/$APPNAME.app" -o "$OUTPUTDIR/$IPA_NAME.ipa" -sign "$DEVELOPER_NAME" -embed "$PROVISIONING_PROFILE"
echo "##teamcity[progressMessage 'Finished signing .IPA file']" 
# # # comment the file version
# #  /usr/libexec/PlistBuddy -c "Add :Comment string \"HomeStyler Version \"" $OUTPUTDIR/$APPNAME.ipa


echo "***********************"
echo "*     TestFlight      *"
echo "***********************"
echo "##teamcity[progressMessage 'Started Testflight Upload']"
./utils/testflight_upload.sh "$OUTPUTDIR/$IPA_NAME.ipa" "$DSYM_FILE.zip" "$TF_NOTES"  "$TF_SEND_GROUP"
echo "##teamcity[progressMessage 'Finished Testflight Upload']"


