#!/bin/bash
# 
 
xcode-select --print-path
 
VERSION_NUMBER="$(agvtool mvers -terse1)_$(agvtool vers -terse)"
PRODUCT_NAME="Homestyler"
#ARTEFACTS="$PWD/Artefacts"

CONFIGURATION=$1
 
SIGNING_IDENTITY="Itamar Berger (9267KE4376)"

DIR=$(cd $(dirname "$0"); pwd)
PROJECT_ROOT="$DIR/.."
WORKSPACE="$PROJECT_ROOT/Homestyler.xcworkspace"
#BUILDDIR="$PROJECT_ROOT/utils/archive"
PROVISIONING_PROFILE="$PROJECT_ROOT/utils/external_files/Homestyler_Dev.mobileprovision"

SCHEME="Homestyler"
SDK="iphoneos"
APPNAME="Homestyler"


DATE=$( /bin/date +"%Y-%m-%d" )

DESTINATION_DIR="$PROJECT_ROOT/utils/archive/$CONFIGURATION"
BUILD_DIR="$PROJECT_ROOT/utils/Build"



echo $DESTINATION_DIR
echo $BUILD_DIR

#exit 0


cd $PROJECT_ROOT

echo "********************"
echo "*     Cleaning     *"
echo "********************"
#xcodebuild -alltargets clean

echo "********************"
echo "*     Archiving     *"
echo "********************" 
# compile
echo "##teamcity[compilationStarted compiler='xcodebuild']"

xcodebuild \
-workspace "$WORKSPACE" \
-scheme "$SCHEME" \
-configuration $CONFIGURATION \
DEPLOYMENT_LOCATION=YES \
DEPLOYMENT_POSTPROCESSING=YES \
STRIP_INSTALLED_PRODUCT=YES \
SYMROOT="$BUILD_DIR/symroot" \
OBJROOT="$BUILD_DIR/objroot" \
SEPARATE_STRIP=YES \
COPY_PHASE_STRIP=YES \
CONFIGURATION_BUILD_DIR="$BUILD_DIR/itermediate" \
CONFIGURATION_TEMP_DIR="$BUILD_DIR/temp" \
DSTROOT="$BUILD_DIR/distribution" \
DWARF_DSYM_FOLDER_PATH="$BUILD_DIR/dwarf" \
archive

buildSucess=$?
 
if [[ $buildSucess != 0 ]] ; then
echo "##teamcity[message text='compiler error $buildSucess' status='ERROR']"
echo "##teamcity[compilationFinished compiler='xcodebuild']"
exit $buildSucess
fi
 
echo "##teamcity[compilationFinished compiler='xcodebuild']"
 
#ipa
echo "##teamcity[progressMessage 'Creating .ipa for ${PRODUCT_NAME}']"
 



APPLICATION_FILE=$(find "$BUILD_DIR/distribution/Applications/" -name "*.app" | head -1)
DSYM_FILE=$(find "$BUILD_DIR/dwarf/" -name "*.dSYM" | head -1)

# Seperate file names from full paths
APPLICATION_FILE_NAME=$(basename "$APPLICATION_FILE")
APPLICATION_NAME=${APPLICATION_FILE_NAME%.*}
DSYM_FILE_NAME=$(basename "$DSYM_FILE")

echo "##teamcity[progressMessage 'Creating ZIP for $DSYM_FILE.zip $DSYM_FILE']"
zip -r -9 "$DSYM_FILE.zip" "$DSYM_FILE"

echo "******************************"
echo "*     Signing - IPA FILE     *"
echo "******************************"
# Package and verify application (turn off verbose information to clear temporary files after)
xcrun -sdk iphoneos PackageApplication -v "$APPLICATION_FILE" \
-o "$DESTINATION_DIR/$APPLICATION_NAME.ipa" \
--sign "$SIGNING_IDENTITY" \
--embed "$PROVISIONING_PROFILE"

# Create destination directory if not exist
echo "Moving to distribution dir: $DESTINATION_DIR"

echo $APPLICATION_FILE
exit 
# Copy application and dSYM file (needs to be recursive becuse some files actually are directories)
cp -rf "$APPLICATION_FILE" "$DESTINATION_DIR"
cp -rf "$DSYM_FILE" "$DESTINATION_DIR"
cp -f "$DSYM_FILE.zip" "$DESTINATION_DIR"

# Print sign information
#echo "Sign information:"
#codesign -dvvv "$APPLICATION_FILE"






 

echo "*******************************"
echo "*     TestFlight UPLOAD       *"
echo "*******************************"



