#!/bin/sh
set -e
set -u
set -o pipefail

if [ -z ${UNLOCALIZED_RESOURCES_FOLDER_PATH+x} ]; then
    # If UNLOCALIZED_RESOURCES_FOLDER_PATH is not set, then there's nowhere for us to copy
    # resources to, so exit 0 (signalling the script phase was successful).
    exit 0
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

XCASSET_FILES=()

# This protects against multiple targets copying the same framework dependency at the same time. The solution
# was originally proposed here: https://lists.samba.org/archive/rsync/2008-February/020158.html
RSYNC_PROTECT_TMP_FILES=(--filter "P .*.??????")

case "${TARGETED_DEVICE_FAMILY:-}" in
  1,2)
    TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
    ;;
  1)
    TARGET_DEVICE_ARGS="--target-device iphone"
    ;;
  2)
    TARGET_DEVICE_ARGS="--target-device ipad"
    ;;
  3)
    TARGET_DEVICE_ARGS="--target-device tv"
    ;;
  4)
    TARGET_DEVICE_ARGS="--target-device watch"
    ;;
  *)
    TARGET_DEVICE_ARGS="--target-device mac"
    ;;
esac

install_resource()
{
  if [[ "$1" = /* ]] ; then
    RESOURCE_PATH="$1"
  else
    RESOURCE_PATH="${PODS_ROOT}/$1"
  fi
  if [[ ! -e "$RESOURCE_PATH" ]] ; then
    cat << EOM
error: Resource "$RESOURCE_PATH" not found. Run 'pod install' to update the copy resources script.
EOM
    exit 1
  fi
  case $RESOURCE_PATH in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .storyboard`.storyboardc" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.xib)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile ${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib $RESOURCE_PATH --sdk ${SDKROOT} ${TARGET_DEVICE_ARGS}" || true
      ibtool --reference-external-strings-file --errors --warnings --notices --minimum-deployment-target ${!DEPLOYMENT_TARGET_SETTING_NAME} --output-format human-readable-text --compile "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$RESOURCE_PATH\" .xib`.nib" "$RESOURCE_PATH" --sdk "${SDKROOT}" ${TARGET_DEVICE_ARGS}
      ;;
    *.framework)
      echo "mkdir -p ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      mkdir -p "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" $RESOURCE_PATH ${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}" || true
      rsync --delete -av "${RSYNC_PROTECT_TMP_FILES[@]}" "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH"`.mom\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd\"" || true
      xcrun momc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"$RESOURCE_PATH\" \"${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm\"" || true
      xcrun mapc "$RESOURCE_PATH" "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$RESOURCE_PATH" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ABSOLUTE_XCASSET_FILE="$RESOURCE_PATH"
      XCASSET_FILES+=("$ABSOLUTE_XCASSET_FILE")
      ;;
    *)
      echo "$RESOURCE_PATH" || true
      echo "$RESOURCE_PATH" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
if [[ "$CONFIGURATION" == "Debug" ]]; then
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Alipay/AlipaySDK.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/CPQRFunction.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/JRBundle.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/MADPPluginSDKResource.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickMBProgressHUD.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickMJRefresh.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickTZImagePickerController.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/libWeiboSDK/WeiboSDK.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/ESFoundation/ESFoundation.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/ESMall/ESMall.bundle"
  install_resource "${PODS_ROOT}/IQKeyboardManager/IQKeyboardManager/Resources/IQKeyboardManager.bundle"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/NIMKit/NIMKit/Resources/NIMKitEmoticon.bundle"
  install_resource "${PODS_ROOT}/NIMKit/NIMKit/Resources/NIMKitResource.bundle"
  install_resource "${PODS_ROOT}/NUI/NUI/Resources/NUIViewBackground.png"
  install_resource "${PODS_ROOT}/NUI/NUI/NUIStyle.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Blue.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Default.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Googolplex.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Round.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Route.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/SkyBlue.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Switchboard.NUI.nss"
  install_resource "${PODS_ROOT}/TZImagePickerController/TZImagePickerController/TZImagePickerController/TZImagePickerController.bundle"
fi
if [[ "$CONFIGURATION" == "Release" ]]; then
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Alipay/AlipaySDK.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/CPQRFunction.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/JRBundle.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/MADPPluginSDKResource.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickMBProgressHUD.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickMJRefresh.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/Finance/NickTZImagePickerController.bundle"
  install_resource "${PODS_ROOT}/ESFoundation/ESFoundation/ExtManager/libWeiboSDK/WeiboSDK.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/ESFoundation/ESFoundation.bundle"
  install_resource "${PODS_CONFIGURATION_BUILD_DIR}/ESMall/ESMall.bundle"
  install_resource "${PODS_ROOT}/IQKeyboardManager/IQKeyboardManager/Resources/IQKeyboardManager.bundle"
  install_resource "${PODS_ROOT}/MJRefresh/MJRefresh/MJRefresh.bundle"
  install_resource "${PODS_ROOT}/NIMKit/NIMKit/Resources/NIMKitEmoticon.bundle"
  install_resource "${PODS_ROOT}/NIMKit/NIMKit/Resources/NIMKitResource.bundle"
  install_resource "${PODS_ROOT}/NUI/NUI/Resources/NUIViewBackground.png"
  install_resource "${PODS_ROOT}/NUI/NUI/NUIStyle.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Blue.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Default.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Googolplex.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Round.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Route.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/SkyBlue.NUI.nss"
  install_resource "${PODS_ROOT}/NUI/NUI/Themes/Switchboard.NUI.nss"
  install_resource "${PODS_ROOT}/TZImagePickerController/TZImagePickerController/TZImagePickerController/TZImagePickerController.bundle"
fi

mkdir -p "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]] && [[ "${SKIP_INSTALL}" == "NO" ]]; then
  mkdir -p "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ -n "${XCASSET_FILES:-}" ]
then
  # Find all other xcassets (this unfortunately includes those of path pods and other targets).
  OTHER_XCASSETS=$(find "$PWD" -iname "*.xcassets" -type d)
  while read line; do
    if [[ $line != "${PODS_ROOT}*" ]]; then
      XCASSET_FILES+=("$line")
    fi
  done <<<"$OTHER_XCASSETS"

  if [ -z ${ASSETCATALOG_COMPILER_APPICON_NAME+x} ]; then
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
  else
    printf "%s\0" "${XCASSET_FILES[@]}" | xargs -0 xcrun actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${!DEPLOYMENT_TARGET_SETTING_NAME}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}" --app-icon "${ASSETCATALOG_COMPILER_APPICON_NAME}" --output-partial-info-plist "${TARGET_TEMP_DIR}/assetcatalog_generated_info_cocoapods.plist"
  fi
fi
