//
//  ConfigManager.h
//  CmyCasa
//
//  Created by Berenson Sergei on 2/4/13.
//
//

#import <Foundation/Foundation.h>
#import "ApiAction.h"
#import "UIManager.h"
#import "ReachabilityManager.h"
#import "GalleryBaseViewController.h"

#define API_VERSION @"1.4"
#define DESIGN_VERSION @"1.6"

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ConfigManager : NSObject

+(id)sharedInstance;
+(BOOL)isJPGImageValid:(NSData *)data;
+(BOOL)isPNGImageValid:(NSData *)data;
+(BOOL)isAnyNetworkAvailable;
+(BOOL)isAnyNetworkAvailableOrOffline;
+(BOOL)isAnyNetworkAvailable :(BOOL)isToShowAlert;
+(BOOL)showMessageIfDisconnected;
+(BOOL)showMessageIfDisconnectedWithDelegate:(id)delegate;
+(BOOL)deviceTypeIsIphone6Plus;
+(BOOL)deviceTypeisIPhoneX;

-(NSMutableDictionary*)getMainConfigDict;
-(NSDictionary *)attributesForFile:(NSURL *)anURI ;
-(NSNumber*)getCacheExpirationTimeForFileType:(NSString*)filekey;
-(NSString*)getStreamFilePath:(NSString*)filename;
-(NSString*)getStreamFilePathWithoutExtension:(NSString*)filename;
-(void)cleanStreamsDirectory;
-(NSString*)getStreamsPath ;
-(void)cleanStreamsDirectoryWithoutTiemstamps;
-(BOOL)isCloudinaryImageCacheUsed;
-(NSString*)findCorrectTShirtSizeForWidth:(int)w andHeight:(int)h;
-(BOOL)loadConfigData;
-(BOOL)updateExists;
-(BOOL)updateRequired;
-(BOOL)canRemindAboutUpdate;
-(BOOL)isConfigLoaded;
-(BOOL)refreshConfigWithSpecialUsage:(NSString*)confVersion;
-(void)init3dParties;
-(NSString*)updateURLStringWithReferer:(NSString*)url;
-(NSString*)generateShareUrl:(NSString*) itemType :(NSString*) itemId;
-(NSString*)generateFacebookLikeLink:(NSString*)itemId withType:(NSString*) itemType;
-(void)validateVersionControl:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue;
-(NSString*)getContentCopy;
-(NSString *)getNewBackendBaseUrl;
+(NSAttributedString*)getWelcomeAtributeString;
-(NSString*)getApplicationVersion;

///////////////////////////////////////////////////////
//              PLIST MANAGEMENT                     //
///////////////////////////////////////////////////////

+(NSString*)getTenantIdName;
+(NSString*)getAppName;
+(NSString*)getAppID;
+(NSString*)getAppHelpArticleUrl;
+(NSString*)getWelcomeSentence;
+(NSString*)getMarketPlaceUrl;
+(NSString*)getHockeyAppIdKey;
+(NSString*)getWeChatAppId;
+(NSString*)getUMengAppId;
+(NSString*)getRedirectorIdentifier;
+(NSString*)getCompanyDesignerUid;
+(BOOL)isWhiteLabel;
+(BOOL)isMagazineActive;
+(BOOL)isProfessionalIndexActive;
+(BOOL)is2DGalleryActive;
+(BOOL)is3DGalleryActive;
+(BOOL)isAddYourBrandActive;
+(BOOL)isFaceBookActive;
+(BOOL)isNewsLetterActive;
+(BOOL)isWLMagazineActive;
+(BOOL)isPortraitModeActive;
+(BOOL)isSegmentActive;
+(BOOL)isPushNotifiactionActive;
+(BOOL)isFindFriendsActive;
+(BOOL)isFlurryActive;
+(BOOL)isFaceBookLoginActive;
+(BOOL)isEmailLoginActive;
+(BOOL)isForgotPasswordActive;
+(BOOL)isOfflineModeActive;
+(BOOL)isDesginManagerLogActive;
+(BOOL)isPackageManagerLogActive;
+(BOOL)isFileDownloadManagerLogActive;
+(BOOL)isWishListActive;
+(BOOL)isProductSnappingToWallActive;
+(BOOL)isSwapableVariationActive;
+(BOOL)isCollectionsActive;
+(BOOL)isShowGridActive;
+(BOOL)isSignInWebViewActive;
+(BOOL)isSignInSSOActive;
+(BOOL)isCatalogIconsActive;
+(BOOL)isReDirectToMarketPlaceActive;
+(BOOL)isProductInfoLeftRightActive;
+(BOOL)isDesignLayersActive;
+(BOOL)isNewCategoryActive;
+(BOOL)isShowCompaniesPaintActive;
+(BOOL)isShowConcealerHelpActive;
+(BOOL)isStopOnWallActive;
+(BOOL)isLevitateButtonActive;
+(BOOL)isLocationBasedTenantActive;
+(BOOL)isFamiliesActive;
+(BOOL)isWeChatActive;
+(BOOL)isChineseOnlyActive;
+(BOOL)isSetPassWord;
+(BOOL)isMoreInfoDisplay;
+(BOOL)isFromDIY;
-(void)setCurrentApp:(ESAppState)appName;

// Device capabilities

@property(nonatomic, readonly) ApiAction* REGISTER_URL ;
@property(nonatomic, readonly) ApiAction* LOGIN_URL ;
@property(nonatomic, readonly) ApiAction* LOGOUT_URL ;
@property(nonatomic, readonly) ApiAction* FORGOT_PASS_URL;
@property(nonatomic, readonly) ApiAction* USER_LIKES_URL;
@property(nonatomic, readonly) ApiAction* SAVE_DESIGN_URL;
@property(nonatomic, readonly) ApiAction* GET_PROFS_URL;
@property(nonatomic, readonly) ApiAction* GET_PROF_BY_ID_URL;
@property(nonatomic, readonly) ApiAction* DUPLICATE_DESIGN_URL ;
@property(nonatomic, readonly) ApiAction* CHANGE_DESIGN_STATUS_URL ;
@property(nonatomic, readonly) ApiAction* CHANGE_DESIGN_METADATA_URL ;
@property(nonatomic, readonly) ApiAction* GET_PROFESSIONALS_URL ;
@property(nonatomic, readonly) ApiAction* FOLLOW_PROF_URL ;
@property(nonatomic, readonly) ApiAction* GET_CATEGORIES_URL;
@property(nonatomic, readonly) ApiAction* NBE_GET_CATEGORIES_URL;
@property(nonatomic, readonly) ApiAction* NBE_GET_PRODUCTS_BY_CATEGORY_URL;
@property(nonatomic, readonly) ApiAction* NBE_GET_FAMILIES_BY_FAMILY_IDS;
@property(nonatomic, readonly) ApiAction* GET_ACTIVITY_STREAM_PUBLIC_URL;
@property(nonatomic, readonly) ApiAction* GET_ACTIVITY_STREAM_PRIVATE_URL;
@property(nonatomic, readonly) ApiAction* GET_PRODUCT_BY_ID;
@property(nonatomic, readonly) ApiAction* REGISTER_DEVICE_URL;
@property(nonatomic, readonly) ApiAction* UNREGISTER_DEVICE_URL;
@property(nonatomic, readonly) ApiAction* addLikeURL;
@property(nonatomic, readonly) ApiAction* actionGetAssetLikes;
@property(nonatomic, readonly) ApiAction* actionGetRoomTypes;
@property(nonatomic, readonly) ApiAction* actionGetProfsFilter;
@property(nonatomic, readonly) ApiAction* getLayoutsURL;
@property(nonatomic, readonly) ApiAction* getItemsAtIndexURL;
@property(nonatomic, readonly) ApiAction* cacheValidationLink;
@property(nonatomic, readonly) ApiAction* actionMyProfile;
@property(nonatomic, readonly) ApiAction* actionUserProfile;
@property(nonatomic, readonly) ApiAction* actionUpdateProfile;
@property(nonatomic, readonly) ApiAction* actionFollow;
@property(nonatomic, readonly) ApiAction* actionGetFollowings;
@property(nonatomic, readonly) ApiAction* actionGetFollowers;
@property(nonatomic, readonly) ApiAction* actionGetBackgrounds;
@property(nonatomic, readonly) ApiAction* actionGetChangedModels;
@property(nonatomic, readonly) ApiAction* actionGetComments;
@property(nonatomic, readonly) ApiAction* getGalleryItemURL;
@property(nonatomic, readonly) ApiAction* actionAddComment;
@property(nonatomic, readonly) ApiAction* searchSocialUsersURL;
@property(nonatomic, readonly) ApiAction* searchHSUsersURL;
@property(nonatomic, readonly) ApiAction* inviteFriendToHSURL;
@property(nonatomic, readonly) ApiAction* getPrivateGalleryItemURL;
@property(nonatomic, readonly) ApiAction* getProductListForItems;
@property(nonatomic, readonly) ApiAction* acceptTermsURL ;
@property(nonatomic, readonly) ApiAction* versionCheckURL;
@property(nonatomic, readonly) ApiAction* getUserCombosURL;
@property(nonatomic, readonly) ApiAction* getWishListForEmail;
@property(nonatomic, readonly) ApiAction* getProductForWishListId;
@property(nonatomic, readonly) ApiAction* getWishListUserId;
@property(nonatomic, readonly) ApiAction* getCreateWishList;
@property(nonatomic, readonly) ApiAction* getAddProductToWishList;
@property(nonatomic, readonly) ApiAction* updateProductWishLists;
@property(nonatomic, readonly) ApiAction* getCompleteWishlistsProductMap;
@property(nonatomic, readonly) ApiAction* deleteWishlist;
@property(nonatomic, readonly) ApiAction* getSSOLogin;
@property(nonatomic, readonly) ApiAction* getSSOPassword;
@property(nonatomic, readonly) ApiAction* getBannerURL;
@property(nonatomic, readonly) ApiAction* getMessagesInfo;
    
@property(nonatomic) BOOL isConfigParsed;
@property(strong, nonatomic,readonly) NSString *activityStreamWelcomeArticleId;        // The article ID which will the welcome article redirect to
@property(nonatomic,copy) NSNumber *paginationSizeActivityStream;
@property(nonatomic,copy) NSNumber *catalogPaginiationSize;
@property(nonatomic,readonly) NSString*  MODEL_ZIP_URL;
@property(nonatomic,readonly) NSString*  MODEL_ZIP_URL_NO_CACHE;
@property(nonatomic,readonly) NSString*  MODEL_ZIP_URL_WITH_VARIATION_ID;
@property(nonatomic,readonly) NSString*  CATEGORY_ICON_URL;
@property(nonatomic,readonly) NSString*  CATEGORY_RETINA_ICON_URL;
@property(nonatomic,readonly) NSString* g_uploadURL ;
@property(nonatomic,readonly) NSString* g_operationURL;
@property(nonatomic,readonly) NSString* SHOPPING_LIST_EMAIL_BASE_URL;
@property(nonatomic) BOOL USE_IMAGE_RESIZER_FOR_SHOPPING_LIST_EMAIL;
@property(nonatomic,readonly) NSString* getLikesURL ;
@property(nonatomic,readonly) NSString* termsLink ;
@property(nonatomic,readonly) NSString* aboutLink ;
@property(nonatomic,readonly) NSString* privacyLink ;
@property(nonatomic,readonly) NSString* configEnvironment ;
@property(nonatomic,readonly) NSString* flurryAppID;
@property(nonatomic,readonly) NSString* flurryAppIDIphone;
@property(nonatomic,readonly) NSString* imageCacheServiceType;
@property(nonatomic,readonly) NSMutableDictionary* cacheServiceTShirts;
@property(nonatomic,readonly) NSString * couldinaryBaseURL;
@property(nonatomic,readonly) NSString * tsBaseURL;
@property(nonatomic) BOOL versionUpdateExists;
@property(nonatomic) BOOL versionUpdateRequired;
@property(nonatomic, readonly) NSString *   versionStorelink;
@property(nonatomic, readonly) NSString *   versionNumber;
@property(nonatomic, readonly) NSString * getWLMagazineURL ;
@property(nonatomic, copy) NSNumber *   refreshRateGalleryStream;
@property(nonatomic, copy) NSArray *   secondaryPlistUrls;
@property(nonatomic) int delayBetweenRetries;
@property(nonatomic) int   serviceCallRetriesCount;
@property(nonatomic) NSTimeInterval   loadingTimeout;
@property(nonatomic) BOOL articleCloudSupported;
@property(nonatomic, copy) NSString *   articleFindURL;
@property(nonatomic, copy) NSString *   articleReplaceURL;
@property(nonatomic, copy) NSString *   articleHelpID;
@property(nonatomic, copy) NSString *   redirectorURL;
@property(nonatomic, readonly) CGFloat appBackgroundInterval;
@property(nonatomic, readonly) CGFloat appBackgroundFadeTime;
@property(nonatomic, readonly) NSInteger appQuickSignupRunCount;
@property(nonatomic, readonly) NSString* userProfileRedirectorLink;
@property(nonatomic, readonly) NSString* contestArticleID;
@property(nonatomic, readonly) NSString* contestArticleImg;
@property(nonatomic, readonly) NSString * gaAppIDKey;
@property(nonatomic, readonly) CGFloat backgroundColorFactor;
@property(nonatomic, readonly) CGFloat productBrightnessMinValue;
@property(nonatomic, readonly) CGFloat productBrightnessMaxValue;
@property(nonatomic, readonly) CGFloat backgroundBrightnessMinValue;
@property(nonatomic, readonly) CGFloat backgroundBrightnessMaxValue;
@property(nonatomic, readonly) NSString * FBLikeBaseURL;
@property(nonatomic, readonly) NSString * segmentKey;
@property(nonatomic, readonly) NSArray * shareHashTags;
@property(nonatomic) BOOL canFacebookLikeFlag;
@property(nonatomic, readonly) NSString* localNotificationURL;
@property(nonatomic, readonly) BOOL useAppsflyerTracking;
@property(nonatomic, readonly) NSString* appsflyerappleAppId;
@property(nonatomic, readonly) NSString* appsflyerDevKey;
@property(nonatomic, readonly) NSString *appsflyerShareTracker;
@property(nonatomic, readonly) NSString * designsCloudURL;
@property(nonatomic, readonly) NSString * assetsCloudURL;
@property(nonatomic, readonly) NSString * modellersAssetsCloudURL;
@property(nonatomic, readonly) NSString *designsBaseDomain;
@property(nonatomic, readonly) NSString *assetsBaseDomain;
@property(nonatomic, readonly) NSNumber * autoSaveDesignIntervalSeconds;
@property(nonatomic) NSInteger numberOfDesignPerGalleryPage;
@property(nonatomic) NSInteger numCellsBeforeNextBulkGallery;
@property(nonatomic, readonly) NSString * catalogShowRoomID;
@property(nonatomic, readonly) NSString * signupBrandsLink;
@property(nonatomic, readonly) NSNumber * toolUndoStepsLimit;
@property(nonatomic, readonly) NSString * concealHelpVideoLink;
@property(nonatomic, readonly) NSString * catalogFontURL;
@property(nonatomic, readonly) NSString *catalogDefaultCategory;
@property(nonatomic, assign) NSInteger retries;
@property(nonatomic, readonly) NSString *externalLoginUrl;
@property(nonatomic, readonly) NSString *UserLoginWebLoginRegisterString;
@property(nonatomic, readonly) NSString *modellersUserEmail;

@property(nonatomic) NSString *countySymbol;
@property(nonatomic, readonly) NSString* uploadProfileImage;
@property(nonatomic, readonly) NSString * signupProffessionalsLink;
@property(nonatomic, strong) NSString * configCurrentBuildId;



@end
