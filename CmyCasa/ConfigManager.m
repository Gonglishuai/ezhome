//
//  ConfigManager.m
//  CmyCasa
//
//  Created by Berenson Sergei on 2/4/13.
//
//

#import "ConfigManager.h"
#import "Reachability.h"
#import "CoreRO.h"
#import "VersionControlDO.h"
#import "HSHashtag.h"
//#import "GAI.h"
#import "NSString+Contains.h"
#import "PackageManager.h"
#import "ReachabilityManager.h"
#import "FileDownloadManager.h"
#import "LocationManager.h"
#import <sys/utsname.h>
//#import <Analytics/SEGAnalytics.h>
#import "DataManager.h"

#define DEFAULT_CATALOG_PAGINATION_SIZE (90)
#define TIMEOUT_CODE -1001

static const NSString* CONFIG_ENVIRONMENT_PROD = @"apiProduction";
static const NSString* CONFIG_ENVIRONMENT_UAT = @"apiUAT";
static const NSString* CONFIG_PLIST_RESCUE_URL = nil;
static const NSString* HSM_CONFIG_INTRO_MESSAGE = @"START APP WITH APP_CONFIG_ENV_PRODUCTION CONFIG";
static const NSString* CONFIG_HD_FILENAME_KEY = @"plistData";
static const NSString* CONFIG_VC_CONFIG_VER_KEY = @"config_ver";
static const NSString* CONFIG_VC_AVILABLE_UPDATE_KEY = @"available_update";
static const NSString* CONFIG_VC_MUST_UPDATE_KEY = @"must_update";
static const NSString* CONFIG_JSON_CONFIG_VER_KEY = @"config_ver";
static const NSString* CONFIG_JSON_CONFIG_KEY = @"config";
static const NSString* CONFIG_JSON_ERR_ID_KEY = @"er";
static const NSString* CONFIG_JSON_ERR_MESSAGE_KEY = @"erMessage";


@interface ConfigManager ()
{
     NSMutableDictionary* _config;
     NSNumber* configVersion;
     NSString* _streamDirectoryPath;
}

@end

@implementation ConfigManager



static ConfigManager *sharedInstance = nil;


+ (ConfigManager *)sharedInstance {
     
     static dispatch_once_t pred;        // Lock
     dispatch_once(&pred, ^{             // This code is called at
          sharedInstance = [[ConfigManager alloc] init];
          [sharedInstance initConfiguration];
     });
          
     return sharedInstance;
}

/*
 * Retrieve a JSON response from a URL as an NSDictionary
 */
- (NSDictionary*)getJSONFromURLAsDictionary:(NSURL*)url error:(NSError**)error
{
     NSData * data = nil;
     NSError * curError = nil;
     
     BOOL shouldContinue = YES;
     if (url && ![[url absoluteString] isEqualToString:@""]) {
          NSLog(@"url: - %@", url);

          NSMutableURLRequest * mutableUrlRequest = [NSMutableURLRequest requestWithURL:url];
          NSURLResponse * response = nil;
          
          switch (self.retries) {
               case 0:
                    break;
               case 1:
               {
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"network_notification" object:NSLocalizedString(@"failed_slow_connection", @"Sorry! The internet connection is a bit slow at the moment. Thank you for your patience.")];
               }
                    break;
               case 2:
               {
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:@"network_notification" object:NSLocalizedString(@"failed_slow_connection", @"Sorry! The internet connection is a bit slow at the moment. Thank you for your patience.")];
                    break;
                    
               default:
                    shouldContinue = NO;
                    break;
               }
          }
          
          if (!shouldContinue) {
               return nil;
          }
          
          [mutableUrlRequest setHTTPMethod:@"GET"];
          [mutableUrlRequest addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
          
          // If offline mode is active, try to fetch configuration from the package
          if (![[ReachabilityManager sharedInstance] isConnentionAvailable] && [ConfigManager isOfflineModeActive])
          {
               data = [[PackageManager sharedInstance] getFileFromPackage:@"getConfigControl.json"];
          }
          else
          {
               data = [NSURLConnection sendSynchronousRequest:mutableUrlRequest
                                            returningResponse:&response
                                                        error:&curError];
          }
          
          if ( error && [curError code] == TIMEOUT_CODE ) {
               NSLog( @"Server timeout! (%ld)", (long)self.retries);
               if (self.retries == 0 || self.retries == 1 || self.retries == 2) {
                    self.retries++;
               }
          }
     }
     
     if (!data)
          return nil;
     
     NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:error];
     
     return dict;
}

/*
 * Checks with version control (VC) wither we should update our current configuration
 * parameters. The purpose of this method is to keep all VC's logic inside one method
 */
-(BOOL)shouldUpdateConfiguration:(NSError**)connectionError {
     // Connect to version control and request the current build's details
     NSError *errorObj = nil;
     NSMutableString *configVcURL = nil;
     NSString * configVersionControlUrl = [self getConfigVersionControlUrl];
     configVcURL = [configVersionControlUrl mutableCopy];
     NSURL *requestURL = [NSURL URLWithString:[configVcURL stringByAppendingString:(NSString*) self.configCurrentBuildId]];
     NSDictionary  *jsonResponse = [self getJSONFromURLAsDictionary:requestURL error:&errorObj];
     
     // Check that the JSON parsing was successful
     if (errorObj != nil)
          return true;
     
     // Check if the current response is legal
     if(jsonResponse == nil)
          return true;
     
     NSNumber *serverConfigVer = jsonResponse[CONFIG_VC_CONFIG_VER_KEY];
     self.versionUpdateExists = jsonResponse[CONFIG_VC_AVILABLE_UPDATE_KEY];
     self.versionUpdateRequired = jsonResponse[CONFIG_VC_MUST_UPDATE_KEY];
     
     // Check that the returned value of configuration version is an NSNumber object
     if (serverConfigVer == nil || ![serverConfigVer isKindOfClass:[NSNumber class]])
          return true;
     
     if ([serverConfigVer intValue] != [configVersion intValue])
          return true;
     
     return false;
}


/*
 * Save the current configuration dictionary
 */
-(void)saveConfig {
     NSArray* itemsToStore = @[configVersion, _config];
     NSString *filePath = [self getLocalConfigFilePath];
     [NSKeyedArchiver archiveRootObject:itemsToStore toFile:filePath];
}

/*
 * Loads the current configuration dictionary from disk
 */
-(BOOL)loadConfigFromDisk {
     
     if (![self localConfigExists]) // Returns false as no local config file exists.
          return false;
     
     // Get the local config file and unarchive it
     NSString *filePath = [self getLocalConfigFilePath];
     NSArray *unarchiver = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
     
     // Return false in case the first object is not the current version
     if (unarchiver[0] == nil || ![unarchiver[0] isKindOfClass:[NSNumber class]])
          return false;
     
     // Return false in case the second object is not a dictionary
     if (unarchiver[1] == nil || ![unarchiver[1] isKindOfClass:[NSDictionary class]])
          return false;
     
//      It is safe to insert the recovered items to the instance variables
     configVersion = unarchiver[0];
     _config = unarchiver[1];
     
//     NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
//     
//     if (jsonData) {
//          NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                    options:NSJSONReadingMutableContainers
//                                                      error:nil];
//          configVersion = dict[@"config_ver"];
//          _config = dict[@"config"];
//     }

     return true;
}

/*
 * Checks if a configuration files exists on disk
 */
-(BOOL)localConfigExists {
     return [[NSFileManager defaultManager] fileExistsAtPath:[self getLocalConfigFilePath]];
}

-(NSString*)getLocalConfigFilePath {
     
     
//     return [[NSBundle mainBundle] pathForResource:@"config.json" ofType:nil];
     
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *documentsDirectoryPath = [paths objectAtIndex:0];
     NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:(NSString*)CONFIG_HD_FILENAME_KEY];
     
     return filePath;
}

/*
 * Cleans the current configuration file
 */
-(BOOL)cleanConfigFromDisk {
     if ([self localConfigExists]) {
          NSError *error;
          [[NSFileManager defaultManager] removeItemAtPath:[self getLocalConfigFilePath] error:&error];
          if (!error)
               return NO;
     }
     return YES;
}

-(BOOL)loadConfigData
{
     HSMDebugLog(@"%@",(NSString*)HSM_CONFIG_INTRO_MESSAGE);
     NSMutableString* configURL = [[self getConfigURL] mutableCopy];
     _config = [self getConfigFile:[configURL stringByAppendingString:(NSString*) self.configCurrentBuildId]];
     
     if (_config) {
          [self fillFields];
          return YES;
     }
     
     return NO;
}

-(BOOL)isConfigLoaded{
     return sharedInstance.isConfigParsed;
}

- (void)reactToNetworkChange
{
     // Clear the cache whenever we switch between offline and online modes
     [[AppCore sharedInstance] clearApplicationCache];
     
     // Post a notification to refresh the data stream
     [[NSNotificationCenter defaultCenter] postNotificationName:@"invalidateAllContent" object:nil];
     
     if (![sharedInstance isConfigLoaded] && [ConfigManager isAnyNetworkAvailable]) {
          [sharedInstance initConfiguration];
          [[NSNotificationCenter defaultCenter] postNotificationName:@"configLoaded" object:nil];
     }
}

-(void)initConfiguration
{
     self.isConfigParsed = NO;
     NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                          NSUserDomainMask,
                                                          YES);
     if ([paths count] == 0)
          return;
     
     NSString *resolvedPath = [paths objectAtIndex:0];
     
     _streamDirectoryPath = [resolvedPath
                             stringByAppendingPathComponent:@"streams"];
     
     // Check for internet connection
     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(reactToNetworkChange)
                                                  name:@"NetworkStatusChanged" object:nil];
     
     //check if location based tenant feature active
     //if YES get county symbol and load config fi
     if ([ConfigManager isLocationBasedTenantActive]) {
          
          _countySymbol = [[DataManger sharedInstance] loadCountryFromDeviceStorage];
          if (_countySymbol) {
               [self startConfigLoadingLogic];
          }else{
               
               //call location api
               [[LocationManager sharedInstance] getLocationApi:^(id serverResponse, id error){
                    
                    NSDictionary * dict = (NSDictionary*)serverResponse;
                    if (dict && !error) {
                         NSString * symbole = [dict objectForKey:@"country_code"];
                         _countySymbol = [[DataManger sharedInstance] validateSymbole:symbole];
                         NSLog(@"country %@", _countySymbol);
                         [self startConfigLoadingLogic];
                    }else{
                         [[LocationManager sharedInstance] getLocation:^(id serverResponse, id error) {
                              CLPlacemark * mark = [[LocationManager sharedInstance] lastAddress];
                              NSString * symbole = [mark ISOcountryCode];
                              _countySymbol = [[DataManger sharedInstance] validateSymbole:symbole];
                              NSLog(@"country %@", _countySymbol);
                              [self startConfigLoadingLogic];
                         }];
                    }
               }];
          }
     }else{
          [self startConfigLoadingLogic];
     }
}

-(void)startConfigLoadingLogic{
     BOOL isDir;
     NSFileManager *fileManager= [NSFileManager defaultManager];
     if(![fileManager fileExistsAtPath:_streamDirectoryPath isDirectory:&isDir]) {
          if([fileManager createDirectoryAtPath:_streamDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL]) {}
     }
     
     // If we cannot load the data from disk we return nil as an error occured
     // We clear the bad config from disk to load the new file in the next iteration
     if(![self loadConfigFromDisk]) {
          [self cleanConfigFromDisk];
     }
     
     
     /*
      * In case we should update the configuration file or that we do not have a configuration on
      * disk, we download new configuration data from our servers. Else, load ConfigManager's fields
      * from the NSMutableDictionary config
      */
     if ([ConfigManager isLocationBasedTenantActive] ) {
          [self loadConfigData];
     }else{
          if ([self shouldUpdateConfiguration:nil] || ![self localConfigExists]) {
               // If we cannot load the config data we return nil - no connection can be found
               if(![self loadConfigData])
                    return;
               
               [self saveConfig];
          } else {
               [self fillFields];
          }
     }
}

-(id)init
{
     if ( self = [super init] )
     {
          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
          self.configCurrentBuildId = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
          return self;
     }
     return nil;
}

-(BOOL)refreshConfigWithSpecialUsage:(NSString*)confVersion {
     BOOL bRetVal = NO;
     
     NSMutableString* configURL = [[self getConfigURL] mutableCopy];
     
     _config = [self getConfigFile:[configURL stringByAppendingString:(NSString *) confVersion]];
     if (_config) {
          [self fillFields];
          bRetVal = YES;
     }
     
     //clear config data so it will not save
     [self cleanConfigFromDisk];
     return bRetVal;
}

- (NSMutableDictionary*) getConfigFile:(NSString*) configURL
{
     for (int i=0; i<3; i++) {
          NSMutableDictionary* ret = [self getConfigFileInternal:configURL];
          if (ret != nil)
               return ret;
     }
     
     return nil;
}

- (NSMutableDictionary*) getConfigFileInternal:(NSString*) configURL{
    @try {
        // Parse the JSON configuration from the new GetConfig API
        NSMutableDictionary *plist;
        NSError *errorObj = nil;
        NSDictionary *JSONplist = [self getJSONFromURLAsDictionary:[NSURL URLWithString:configURL] error:&errorObj];
         
         // Check for errors in JSON serialization
         if (errorObj != nil || nil == JSONplist) {
              HSMDebugLog(@"Error serializing JSON config file. Excpetion: %@", [errorObj localizedDescription]);
              return nil;
         }
         
         NSNumber* jsonErrorId = JSONplist[CONFIG_JSON_ERR_ID_KEY];
         NSString* jsonErrorMsg = JSONplist[CONFIG_JSON_ERR_MESSAGE_KEY];
         
         if ([jsonErrorId integerValue] != -1)
         {
              HSMDebugLog(@"Error in retrieving the configuration JSON response. Error ID: %@ Excpetion: %@", jsonErrorId, jsonErrorMsg);
              return nil;
          }
         
         // If all is correct then the configuration keys are present in the dictionary under CONFIG_JSON_CONFIG_KEYS_IDX key.
         plist = JSONplist[CONFIG_JSON_CONFIG_KEY];
         configVersion = JSONplist[CONFIG_JSON_CONFIG_VER_KEY];
        
          if(!plist){
               HSMDebugLog(@"Error: %@",errorObj);
          }
          return plist ;
     }
     @catch (NSException * e) {
          HSMDebugLog(@"getConfigFileInternal Exception: %@", e);
          return nil;
     }
}

-(NSString *)getNewBackendBaseUrl
{
     return [_config objectForKey:@"restkit_nbe_base_url"];
}

-(void)fillFields{
     
     _getLayoutsURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"getLayouts"]];
     _getItemsAtIndexURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"getItemsAtIndex"]];
     _actionGetRoomTypes = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"get_room_types_url"]];
     _actionGetProfsFilter = [[ApiAction alloc]initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"get_prof_filters_url"]];
     _LOGOUT_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"logout_url"]];
     _FORGOT_PASS_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"forgot_pass_url"]];
     _REGISTER_DEVICE_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"register_device_url"]];
     _UNREGISTER_DEVICE_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"unregister_device_url"]];
     _acceptTermsURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"acceptterms"]];
     _USER_LIKES_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"user_likes_url"]];
     _DUPLICATE_DESIGN_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"duplicate_design_url"]];
     _CHANGE_DESIGN_STATUS_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"change_design_status_url"]];
     _CHANGE_DESIGN_METADATA_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"change_design_metadata_url"]];
     _getPrivateGalleryItemURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"getPrivateGalleryItem"]];
     _getGalleryItemURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"getGalleryItem"]];
     _addLikeURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"addLike"]];
     _actionGetAssetLikes = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"get_likers_by_designId"]];
     _GET_PROFS_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_profs_url"]];
     _GET_PROF_BY_ID_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_prof_by_id_url"]];
     _FOLLOW_PROF_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"follow_prof_url"]];
     _GET_CATEGORIES_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_categories_url"] ];
     _getUserCombosURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"profile_combos"]];
     _getLikesURL = [[_config objectForKey:@"urls" ] objectForKey:@"getLikes"];
     _getWLMagazineURL = [[_config objectForKey:@"urls" ] objectForKey:@"getWLMagazineURL"];
     _SAVE_DESIGN_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"save_design_url"]];
     _uploadProfileImage = [[_config objectForKey:@"urls" ]objectForKey:@"upload_profile_image"];
     _GET_PRODUCT_BY_ID = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_product_by_Id"]];
     _GET_PROFESSIONALS_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_professionals_url"]];
     _g_uploadURL = [[_config objectForKey:@"urls" ]objectForKey:@"g_uploadURL"];
     _g_operationURL = [[_config objectForKey:@"urls" ]objectForKey:@"g_operationURL"];
     _externalLoginUrl = [[_config objectForKey:@"urls" ] objectForKey:@"web_login_url"];
     _UserLoginWebLoginRegisterString = [[_config objectForKey:@"urls" ] objectForKey:@"web_login_key"];
     _actionGetChangedModels = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"changed_models"]];
     _actionAddComment = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"addComment"]];
     _actionGetComments = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"getComments"]];
     _cacheValidationLink = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"cache_validation"]];
     _SHOPPING_LIST_EMAIL_BASE_URL = [[_config objectForKey:@"urls" ]objectForKey:@"shopping_list_email_base_url"];
     _REGISTER_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"register_url"]];
     _LOGIN_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"login_url"]];
     _actionMyProfile = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"my_profile_action"]];
     _actionUserProfile = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls"] objectForKey:@"public_profile_action"]];
     _actionUpdateProfile = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"user_update_action"]];
     _actionFollow = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"user_follow_action"]];
     _actionGetFollowings = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"user_followings_action"]];
     _actionGetFollowers = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"user_followers_action"]];
     _actionGetBackgrounds = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"opening_image"]];
     _searchHSUsersURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"find_users_url"]];
     _searchSocialUsersURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"find_social_users_url"]];
     _inviteFriendToHSURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"invite_users_url"]];
     _getBannerURL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"banner_image"]];
     _getMessagesInfo = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ] objectForKey:@"get_inapp_notifications"]];
     
     // The activity stream public URL is the URL to be used when viewing a public profile activity - Avoid's marking the "lastRead" flag
     _GET_ACTIVITY_STREAM_PUBLIC_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_activity_stream_public_url"]];
     _GET_ACTIVITY_STREAM_PUBLIC_URL.retryCallsDisabled = YES;
     
     // The activity stream private URL is the URL to be used when viewing a private profile activity - Updates the "lastRead" flag
     _GET_ACTIVITY_STREAM_PRIVATE_URL = [[ApiAction alloc] initWithDictionary:[[_config objectForKey:@"urls" ]objectForKey:@"get_activity_stream_private_url"]];
     _GET_ACTIVITY_STREAM_PRIVATE_URL.retryCallsDisabled = YES;
     
     _NBE_GET_CATEGORIES_URL = [[ApiAction alloc] initWithAction:@"rest/v2.0/category" https:NO cloud:YES serverV2:YES];
     _NBE_GET_PRODUCTS_BY_CATEGORY_URL = [[ApiAction alloc] initWithAction:@"rest/v3.0/products/search" https:NO cloud:YES serverV2:YES];
     _NBE_GET_FAMILIES_BY_FAMILY_IDS = [[ApiAction alloc] initWithAction:@"rest/v2.0/familyByIds" https:NO cloud:NO serverV2:YES];
     
     _getProductListForItems = [[ApiAction alloc]initWithAction:@"rest/v2.0/productList" https:NO cloud:YES serverV2:YES];
     _getWishListForEmail = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/list" https:NO cloud:NO serverV2:YES];
     _getProductForWishListId = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/{{ID}}" https:NO cloud:NO serverV2:YES];
     _getWishListUserId = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/user" https:NO cloud:NO serverV2:YES];
     _getCreateWishList = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/" https:NO cloud:NO serverV2:YES];
     _getAddProductToWishList = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/{{WID}}" https:NO cloud:NO serverV2:YES];
     _updateProductWishLists = [[ApiAction alloc] initWithAction: @"rest/v2.0/wishlists/" https:NO cloud:NO serverV2:YES];
     _getCompleteWishlistsProductMap  = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/full" https:NO cloud:NO serverV2:YES];
     _deleteWishlist = [[ApiAction alloc] initWithAction:@"rest/v2.0/wishlist/{{WID}}" https:NO cloud:NO serverV2:YES];
     _GET_PRODUCT_BY_ID = [[ApiAction alloc]initWithAction:@"rest/v3.0/products/search" https:NO cloud:YES serverV2:YES];
     _getSSOLogin = [[ApiAction alloc] initWithAction:@"cas-proxy/guest_user_account/api/v2/login" ssoserver:YES];
     _getSSOPassword = [[ApiAction alloc] initWithAction:@"cas-proxy/auth_user_account/api/v1/password" ssoserver:YES];
     
     _MODEL_ZIP_URL = [[_config objectForKey:@"models"] objectForKey:@"zip_url"];
     _MODEL_ZIP_URL_NO_CACHE = [[_config objectForKey:@"models"] objectForKey:@"zip_url_nocache"];
     _MODEL_ZIP_URL_WITH_VARIATION_ID = [[_config objectForKey:@"models"] objectForKey:@"variation_zip_url"];
     
     _CATEGORY_ICON_URL  = [[_config objectForKey:@"models"] objectForKey:@"category_url"];
     _CATEGORY_RETINA_ICON_URL = [[_config objectForKey:@"models"] objectForKey:@"categoryRetina_url"];
     _USE_IMAGE_RESIZER_FOR_SHOPPING_LIST_EMAIL = (Boolean)[_config objectForKey:@"UseImageResizerForShoppingListEmail"];
     _termsLink = [_config objectForKey:@"termslink"];
     _aboutLink = [_config objectForKey:@"aboutLink"] ;
     _privacyLink = [_config objectForKey:@"privacyLink"] ;
     _configEnvironment = [_config objectForKey:@"environment"] ;
     
     if ([_config objectForKey:@"appkeys"] != nil) {
          NSString * fappid=[[_config objectForKey:@"appkeys"] objectForKey:@"fappid"];
          if (fappid!=nil) {
//               [FBSDKAppEvents activateApp];
          }
          _gaAppIDKey = [[_config objectForKey:@"appkeys"] objectForKey:@"gaAppID"];
          _flurryAppID = [[_config objectForKey:@"appkeys"] objectForKey:@"flurryid"];
          _flurryAppIDIphone = [[_config objectForKey:@"appkeys"] objectForKey:@"flurryid_iphone"];
     }
     
     _imageCacheServiceType = [[_config objectForKey:@"imageresizer"] objectForKey:@"resizer_type"];
     _cacheServiceTShirts = [[_config objectForKey:@"imageresizer"] objectForKey:@"tshirts"];
     _tsBaseURL = [[_config objectForKey:@"imageresizer"] objectForKey:@"baseurl_ts"];
     _couldinaryBaseURL = [[_config objectForKey:@"imageresizer"] objectForKey:@"baseurl_cloudinary"];
     _versionUpdateExists = [[[_config objectForKey:@"versioncontrol"] objectForKey:@"available_update"] boolValue];
     _versionUpdateRequired = [[[_config objectForKey:@"versioncontrol"] objectForKey:@"must_upate"] boolValue];
     _versionStorelink = [[_config objectForKey:@"versioncontrol"] objectForKey:@"url"];
     _versionNumber = [[_config objectForKey:@"versioncontrol"] objectForKey:@"last_version"];
     _refreshRateGalleryStream = [[_config objectForKey:@"galleryStream"] objectForKey:@"refreshRate"];
     _modellersUserEmail = [_config objectForKey:@"modellers_email_list"];
     _catalogDefaultCategory = [_config objectForKey:@"defaultCatalogCategory"];
//     if (!_catalogDefaultCategory && ![ConfigManager isWhiteLabel])
//          _catalogDefaultCategory = @"new";
     
     _paginationSizeActivityStream  = [[_config objectForKey:@"activityStream"] objectForKey:@"paginationSize"];
     
     _catalogPaginiationSize  = [[_config objectForKey:@"prodcutsCatalog"] objectForKey:@"paginationSize"];
     if (!_catalogPaginiationSize)
          _catalogPaginiationSize = [NSNumber numberWithInt:DEFAULT_CATALOG_PAGINATION_SIZE];
     
     _activityStreamWelcomeArticleId  = (IS_IPAD) ? [_config objectForKey:@"iPad_articleHelpID"] : [_config objectForKey:@"iPhone_articleHelpID"];
     
     if ([_config objectForKey:@"plist_fallbacks"] && [[_config objectForKey:@"plist_fallbacks"] isKindOfClass:[NSArray class]]) {
          _secondaryPlistUrls = [_config objectForKey:@"plist_fallbacks"];
     }
     
     if ([_config objectForKey:@"api_failures"]) {
          _delayBetweenRetries= [[[_config objectForKey:@"api_failures"]objectForKey:@"delay_retrytime"] intValue];
          _serviceCallRetriesCount= [[[_config objectForKey:@"api_failures"]objectForKey:@"retry_times"] intValue];
          _loadingTimeout  = [[[_config objectForKey:@"api_failures"] objectForKey:@"loadingTimeout"] intValue];
     }
     
     if(_delayBetweenRetries == 0){
          _delayBetweenRetries= 1;
     }
     
     if(_serviceCallRetriesCount == 0){
          _serviceCallRetriesCount= 3;
     }
     
     if(_loadingTimeout == 0){
          _loadingTimeout = 90;
     }
     
     if ([_config objectForKey:@"articleCloud"]) {
          self.articleCloudSupported = [[[_config objectForKey:@"articleCloud"]objectForKey:@"enable"] boolValue];
          self.articleFindURL = [[_config objectForKey:@"articleCloud"]objectForKey:@"findUrl"];
          self.articleReplaceURL = [[_config objectForKey:@"articleCloud"]objectForKey:@"replaceUrl"];
     } else {
          self.articleCloudSupported = NO;
     }
     
     _articleHelpID = IS_IPAD ? [_config objectForKey:@"iPad_articleHelpID"]: [_config objectForKey:@"iPhone_articleHelpID"];
     _redirectorURL = [_config objectForKey:@"redirectorUrl"];
     
     
     _appBackgroundFadeTime = [[[_config objectForKey:@"app" ]objectForKey:@"opening_image_fade_time"] floatValue]; // 2.0;
     _appBackgroundInterval = [[[_config objectForKey:@"app" ]objectForKey:@"opening_image_timer"] floatValue ]; //8.0;
     
     // Handle the quick signup run count logic. Use default value of -1 to signal that the quick signup feature is disabled
     _appQuickSignupRunCount = -1;
     if ([[_config objectForKey:@"app"] objectForKey:@"quick_signup_popup_run_count"] != nil)
     {
          _appQuickSignupRunCount = [[[_config objectForKey:@"app"] objectForKey:@"quick_signup_popup_run_count"] intValue];
     }
     
     _backgroundColorFactor = [[[_config objectForKey:@"tool" ]objectForKey:@"backgroundColorFactor"] floatValue];//  0.3;
     if(_backgroundColorFactor == 0)
     {
          _backgroundColorFactor = 0.3;
     }
     
     _backgroundColorFactor =[[[_config objectForKey:@"tool" ]objectForKey:@"backgroundColorFactor"] floatValue];//  0.3;
     if(_backgroundColorFactor == 0)
     {
          _backgroundColorFactor = 0.3;
     }
     
     _backgroundBrightnessMinValue =[[[_config objectForKey:@"tool" ]objectForKey:@"backgroundBrightnessMinValue"] floatValue]; // 0.5;
     if(_backgroundBrightnessMinValue == 0)
     {
          _backgroundBrightnessMinValue = 0.5;
     }
     
     _backgroundBrightnessMaxValue =[[[_config objectForKey:@"tool" ]objectForKey:@"backgroundBrightnessMaxValue"] floatValue]; // 1.5;
     if(_backgroundBrightnessMaxValue == 0)
     {
          _backgroundBrightnessMaxValue = 1.5;
     }
     
     _productBrightnessMinValue =[[[_config objectForKey:@"tool" ]objectForKey:@"productBrightnessMinValue"] floatValue]; // 0.5;
     if(_productBrightnessMinValue == 0)
     {
          _productBrightnessMinValue = 0.5;
     }
     
     _productBrightnessMaxValue =[[[_config objectForKey:@"tool" ]objectForKey:@"productBrightnessMaxValue"] floatValue]; // 1.5;
     if(_productBrightnessMaxValue == 0)
     {
          _productBrightnessMaxValue = 1.5;
     }
     
     _userProfileRedirectorLink = [_config objectForKey:@"redirector_users_link"];
     _versionCheckURL = [[ApiAction alloc] initWithDictionary: [[_config objectForKey:@"versioncontrol"] objectForKey:@"checkurl"]];
     
     if ([_config objectForKey:@"contests"]) {
          if (IS_IPAD) {
               _contestArticleID = ([[[_config objectForKey:@"contests"]objectForKey:@"ipad_contestArticleID"] length]==0)?nil:[[_config objectForKey:@"contests"] objectForKey:@"ipad_contestArticleID"];
               _contestArticleImg = ([[[_config objectForKey:@"contests"]objectForKey:@"ipad_contest_img"] length]==0)?nil:[[_config objectForKey:@"contests"] objectForKey:@"ipad_contest_img"];
          }else{
               _contestArticleID = ([[[_config objectForKey:@"contests"] objectForKey:@"iphone_contestArticleID"] length]==0)?nil:[[_config objectForKey:@"contests"] objectForKey:@"iphone_contestArticleID"];
               _contestArticleImg = ([[[_config objectForKey:@"contests"]objectForKey:@"iphone_contest_img"] length]==0)?nil:[[_config objectForKey:@"contests"] objectForKey:@"iphone_contest_img"];
          }
     }

     _FBLikeBaseURL = [[_config objectForKey:@"share" ] objectForKey:@"fb_like_object"];
     _segmentKey = [[_config objectForKey:@"appkeys" ] objectForKey:@"segment"];
     _canFacebookLikeFlag = [[[_config objectForKey:@"share" ] objectForKey:@"fb_like_enabled"]boolValue];
     self.shareHashTags = [[_config objectForKey:@"share" ] objectForKey:@"hash_tags"];
     _localNotificationURL = [_config objectForKey:@"local_notification_url"];
     
     if ([[_config objectForKey:@"appkeys"] objectForKey:@"appsflyer"]) {
          NSDictionary * appsflyer = [[_config objectForKey:@"appkeys"] objectForKey:@"appsflyer"];
          _useAppsflyerTracking =[[appsflyer objectForKey:@"appsflyer_usage"] boolValue];
          _appsflyerappleAppId = [appsflyer objectForKey:@"appleAppId"];
          _appsflyerDevKey = [appsflyer objectForKey:@"devKey"];
     }
     
     if ([[_config objectForKey:@"share"] objectForKey:@"appsflyer_tracker"]) {
          _appsflyerShareTracker = [[_config objectForKey:@"share"] objectForKey:@"appsflyer_tracker"];
     }
     
     _designsCloudURL = [[_config objectForKey:@"imageresizer"] objectForKey:@"designs_cloud"];
     _assetsCloudURL = [[_config objectForKey:@"imageresizer"] objectForKey:@"assets_cloud"];
     _modellersAssetsCloudURL = [[_config objectForKey:@"imageresizer"] objectForKey:@"modellers_cloud"];
     _designsBaseDomain = [[_config objectForKey:@"imageresizer"] objectForKey:@"designs_base_domain"];
     _assetsBaseDomain =  [[_config objectForKey:@"imageresizer"] objectForKey:@"assets_base_domain"];
     _autoSaveDesignIntervalSeconds = [_config objectForKey:@"autosave_interval_sec"];
     
     if ([_config objectForKey:@"gallery_presentation"]){
          _numberOfDesignPerGalleryPage = [[[_config objectForKey:@"gallery_presentation"] objectForKey:@"items_per_page"] integerValue];
          _numCellsBeforeNextBulkGallery = [[[
                                              _config objectForKey:@"gallery_presentation"] objectForKey:@"offset_before_next_page"] integerValue];
     }else{
          _numberOfDesignPerGalleryPage = 300;
          _numCellsBeforeNextBulkGallery = 50;
     }
     
     _catalogShowRoomID = [_config objectForKey:@"catalog_preview_room_id"];
     _signupProffessionalsLink = [[_config objectForKey:@"signup_links"] objectForKey:@"proff_signup_link"];
     _signupBrandsLink =  [[_config objectForKey:@"signup_links"] objectForKey:@"brand_signup_link"];
     
     if ([_config objectForKey:@"redesign_undo_limit"])
     {
          _toolUndoStepsLimit = [NSNumber numberWithInt:[[_config objectForKey:@"redesign_undo_limit"] intValue]];
     }else{
          _toolUndoStepsLimit = [NSNumber numberWithInt:20];
     }
     
     if ([_config objectForKey:@"help_videos"]) {
          if (IS_IPAD)
               _concealHelpVideoLink = [[_config objectForKey:@"help_videos"] objectForKey:@"conceal_help"];
          else
               _concealHelpVideoLink = [[_config objectForKey:@"help_videos"] objectForKey:@"conceal_help_iphone"];
     }

     _catalogFontURL = [_config objectForKey:@"catalogCategories_icons"];
     
     [AppCore setupRestkit:_config];

     self.isConfigParsed = YES;
}

-(NSString*)getContentCopy{

     NSString * baseKey = @"contest_copy_";
     NSString * locale = [[NSLocale preferredLanguages] objectAtIndex:0];
     NSString * newKey = [NSString stringWithFormat:@"%@%@",baseKey,locale];
     
     if ([_config objectForKey:@"contests"]) {
          
          if (![[_config objectForKey:@"contests"] objectForKey:newKey]) {
               newKey = @"contest_copy_en";
          }
          
          if (![[_config objectForKey:@"contests"] objectForKey:newKey]) {
               return @"";
          }
          
          return [[_config objectForKey:@"contests"] objectForKey:newKey];
     }
     return @"";
}

-(BOOL)updateRequired{
     return _versionUpdateExists==true && _versionUpdateRequired==true;
}

-(void)validateVersionControl:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue{
     NSString *versionString =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
     
     [[CoreRO new]validateVersionControl:versionString ithCompletionBlock:^(id serverResponse) {
          
          VersionControlDO *response=(VersionControlDO*)serverResponse;
          if (response && [response isKindOfClass:[VersionControlDO class]]) {
               _versionUpdateExists=response.versionUpdateExists;
               _versionUpdateRequired=response.versionUpdateRequired;
          }else{
               _versionUpdateRequired=NO;
               _versionUpdateExists=NO;
          }
          completion(nil,nil);
          
     } failureBlock:^(NSError *error) {
          _versionUpdateRequired=NO;
          _versionUpdateExists=NO;
          
          completion(nil,nil);
     } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(BOOL)updateExists{
     return _versionUpdateExists==YES;
}

-(BOOL)canRemindAboutUpdate{
     return YES;
}

-(NSMutableDictionary*)getMainConfigDict{
     return  _config;
}

-(BOOL)isDebugMode{
    return [[_config objectForKey:@"debugmode"] boolValue];
}

- (void) cleanStreamsDirectory {
     NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_streamDirectoryPath error:nil];
     for (NSString *fileName in dirContents) {
          NSString* filePath = [_streamDirectoryPath stringByAppendingPathComponent:fileName];
          NSNumber * expireHours= [[ConfigManager sharedInstance] getCacheExpirationTimeForFileType:@"stream_cache_hours"];
          
          [self clearGalleryStreamImages:filePath withExpirationHours:expireHours];
     }
     
     [self cleanStreamsDirectoryComments];
}

- (void) cleanStreamsDirectoryWithoutTiemstamps {
     NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_streamDirectoryPath error:nil];
     for (NSString *fileName in dirContents) {
          NSString* filePath = [_streamDirectoryPath stringByAppendingPathComponent:fileName];
          [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
     }
}

- (void) cleanStreamsDirectoryComments {
     NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_streamDirectoryPath error:nil];
     for (NSString *fileName in dirContents) {
          NSString* filePath = [_streamDirectoryPath stringByAppendingPathComponent:fileName];
          if ( [fileName hasPrefix:@"commentrep_"] || [fileName hasPrefix:@"comment_"])
          {
               [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
          }
     }
}

-(void)clearGalleryStreamImages:(NSString *)filepath withExpirationHours:(NSNumber*)expHours {
     NSURL * fileUri=[NSURL fileURLWithPath:filepath];
     
     NSDictionary * attrs =  [self attributesForFile:fileUri];
     NSDate * createDate = [attrs objectForKey:@"fileCreationDate"];
     NSDate * now = [NSDate date];
     
     NSTimeInterval intrev=[expHours intValue]*3600;
     
     NSDate * expdate=[createDate dateByAddingTimeInterval:intrev];
     if ([now compare:expdate]==NSOrderedDescending ) {
          [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
     }
}

- (NSDictionary *) attributesForFile:(NSURL *)anURI {
     
     // note: singleton is not thread-safe
     NSFileManager *fileManager = [NSFileManager defaultManager];
     NSString *aPath = [anURI path];
     
     if (![fileManager fileExistsAtPath:aPath]) return nil;
     
     NSError *attributesRetrievalError = nil;
     NSDictionary *attributes = [fileManager attributesOfItemAtPath:aPath
                                                              error:&attributesRetrievalError];
     
     if (!attributes) {
          HSMDebugLog(@"Error for file at %@: %@", aPath, attributesRetrievalError);
          return nil;
     }
     
     NSMutableDictionary *returnedDictionary =
     [NSMutableDictionary dictionaryWithObjectsAndKeys:
      [attributes fileType], @"fileType",
      [attributes fileModificationDate], @"fileModificationDate",
      [attributes fileCreationDate], @"fileCreationDate",
      [NSNumber numberWithUnsignedLongLong:[attributes fileSize]], @"fileSize",
      nil];
     
     return returnedDictionary;
}

-(NSNumber*)getCacheExpirationTimeForFileType:(NSString*)filekey{
     
     if (_config && [_config objectForKey:@"cache"]) {
          
          return [[_config objectForKey:@"cache"] objectForKey:filekey];
     }
     
     return  [NSNumber numberWithInt:24];
}

- (NSString*) getStreamsPath {
     return _streamDirectoryPath;
}

- (NSString*) getStreamFilePath:(NSString*)filename {
     return [NSString stringWithFormat:@"%@/%@.jpg", _streamDirectoryPath, filename];
}

- (NSString*) getStreamFilePathWithoutExtension:(NSString*)filename {
     return [NSString stringWithFormat:@"%@/%@", _streamDirectoryPath, filename];
}

+ (BOOL)isAnyNetworkAvailable :(BOOL)isToShowAlert
{
     BOOL retVal = [ConfigManager isAnyNetworkAvailable];
     if(retVal == NO && isToShowAlert)
     {
          [ConfigManager errorMessageYouSeemToBeOffline:nil];
     }
     
     return  retVal;
}

+ (BOOL)isAnyNetworkAvailable
{
     return [[ReachabilityManager sharedInstance] isConnentionAvailable];
}

+ (BOOL)isAnyNetworkAvailableOrOffline
{
     return ([ConfigManager isOfflineModeActive] || [ConfigManager isAnyNetworkAvailable] );
}

+(BOOL)showMessageIfDisconnected
{
     return [ConfigManager showMessageIfDisconnectedWithDelegate:nil];
}

+(BOOL)showMessageIfDisconnectedWithDelegate:(id)delegate
{
     if (![ConfigManager isAnyNetworkAvailable]) {
          [ConfigManager errorMessageYouSeemToBeOffline:delegate];
          return YES;
     }
     
     return NO;
}

+(void)errorMessageYouSeemToBeOffline:(id)delegate{
     UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@""
                                                   message:NSLocalizedString(@"failed_action_no_network_found_start", @"You seem to be offline. Please check your internet connection and retry.")
                                                  delegate:delegate
                                         cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close")
                                         otherButtonTitles: nil];
     [alert show];
}

-(BOOL)isCloudinaryImageCacheUsed{
     
     if (_imageCacheServiceType==nil || [_imageCacheServiceType isEqualToString:@"ts"]==false) {
          return true;
     }
     //means we are using tshirt size
     return false;
}

-(NSString*)findCorrectTShirtSizeForWidth:(int)w andHeight:(int)h{
     
     int compared= w;
     if (h>w) {
          compared=h;
     }
     
     if (_cacheServiceTShirts!=nil) {
          
          for (NSString * key in   [_cacheServiceTShirts allKeys]) {
               
               int lower=[[[_cacheServiceTShirts objectForKey:key] objectForKey:@"lower"] intValue];
               int upper=[[[_cacheServiceTShirts objectForKey:key] objectForKey:@"upper"] intValue];
               if (lower<=compared && compared<=upper) {
                    return key;
               }
          }
     }
     
     return @"";
}

+ (BOOL)isPNGImageValid:(NSData *)data
{
     if (data==nil) {
          return NO;
     }
     BOOL val = YES;
     
     if ([data length] < 4)
          return NO;
     
     const unsigned char * bytes = (const unsigned char *)[data bytes];
     
     if (bytes[0] != 0x89 || bytes[1] != 0x50)
          val = NO;
     if (bytes[[data length] - 2] != 0x60 ||
         bytes[[data length] - 1] != 0x82)
          val = NO;
     
     return val; //return YES if valid
}

+ (BOOL)isJPGImageValid:(NSData *)data
{
     if (data==nil) {
          return NO;
     }
     BOOL val = YES;
     
     if ([data length] < 4)
          return NO;
     
     const unsigned char * bytes = (const unsigned char *)[data bytes];
     
     if (bytes[0] != 0xff || bytes[1] != 0xd8)
          val = NO;
     if (bytes[[data length] - 2] != 0xff ||
         bytes[[data length] - 1] != 0xd9)
          val = NO;
     
     return val; //return YES if valid
}


+(BOOL)deviceTypeIsIphone6Plus
{
     NSArray *arr = [[self machineName] componentsSeparatedByString:@","];
     return [arr[0] isEqualToString:@"iPhone7"];
}

+(BOOL)deviceTypeisIPhoneX {
     struct utsname systemInfo;
     uname(&systemInfo);
     NSString *machine = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
     if ([machine isEqualToString:@"iPhone10,3"] || [machine isEqualToString:@"iPhone10,6"]) {
          return YES;
     }else{
          return NO;
     }
}

// see devices machine names at the top of this file
+(NSString*)machineName{
     struct utsname systemInfo;
     uname(&systemInfo);
     NSString *result = [NSString stringWithCString:systemInfo.machine
                                           encoding:NSUTF8StringEncoding];
     return result;
}

-(NSString*)updateURLStringWithReferer:(NSString*)url{
     
     if (!url) {
          return url;
     }
     if ([url rangeOfString: @"file:" options:NSCaseInsensitiveSearch].location != NSNotFound)
     {
          return url;
     }
     
     if ([url rangeOfString: @"Referrer=homestyler.com" options:NSCaseInsensitiveSearch].location != NSNotFound)
     {
          return url;
     }
     
     if ([url rangeOfString: @"?" options:NSBackwardsSearch].location!=NSNotFound) {
          //contains params
          return [NSString stringWithFormat:@"%@&Referrer=homestyler.com/mobile",url];
     }else
     {
          return [NSString stringWithFormat:@"%@?Referrer=homestyler.com/mobile",url];
     }
}

-(NSString*)generateFacebookLikeLink:(NSString*)itemId withType:(NSString*) itemType{
     
     
     NSString * baseurl=[[ConfigManager sharedInstance] FBLikeBaseURL];
     
     baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{TYPE}}" withString:itemType];
     
     baseurl=[baseurl stringByReplacingOccurrencesOfString:@"{{GUID}}" withString:itemId];
     
     return baseurl;
}

- (NSString*) generateShareUrl:(NSString*) itemType :(NSString*) itemId
{
     if (!itemType || !itemId) {
          return nil;
     }
     
     NSString * baseurl = [[ConfigManager sharedInstance] redirectorURL];
     
     baseurl = [baseurl stringByReplacingOccurrencesOfString:@"{{TYPE}}" withString:itemType];
     
     baseurl = [baseurl stringByReplacingOccurrencesOfString:@"{{ID}}" withString:itemId];
     
     if (![NSString isNullOrEmpty:_appsflyerShareTracker]) {
          baseurl=[baseurl stringByAppendingString:[NSString stringWithFormat:@"&track=%@",_appsflyerShareTracker]];
     }
     
     return baseurl;
}

-(void)setShareHashTags:(NSArray *)sshareHashTags{
     
     NSMutableArray * arr=[NSMutableArray arrayWithCapacity:0];
     
     for (int i=0; i<[sshareHashTags count]; i++) {
          NSDictionary * dict=[sshareHashTags objectAtIndex:i];
          
          HSHashtag * tag=[[HSHashtag alloc] initWithText:[dict  objectForKey:@"title"]
                                                     type:[[dict  objectForKey:@"type"] intValue]
                                              andLocation:[[dict  objectForKey:@"location"] intValue]];
          [arr addObject:tag];
     }
     _shareHashTags = [arr copy];
}

-(void)init3dParties
{
#ifdef USE_GA
    if ([[ConfigManager sharedInstance] gaAppIDKey] && [[[ConfigManager sharedInstance]gaAppIDKey] length]>0) {
        // Optional: automatically send uncaught exceptions to Google Analytics.
//        [GAI sharedInstance].trackUncaughtExceptions = NO;
        // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//        [GAI sharedInstance].dispatchInterval = 20;
        // Optional: set Logger to VERBOSE for debug information.
//        [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
#if  APP_CONFIG_ENV == APP_CONFIG_ENV_PRODUCTION
          [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelNone];
#endif
          // Create tracker instance.
//          [[GAI sharedInstance] trackerWithTrackingId:[[ConfigManager sharedInstance]gaAppIDKey]];
         NSLog(@"GAI tracking Id:%@",[[ConfigManager sharedInstance]gaAppIDKey]);
     }
#endif

}

-(NSString*)getApplicationVersion{
     NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
     NSString *env = [self configEnvironment];
     NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
     
     NSString *build = @"";
     if ([[[NSBundle mainBundle] bundleIdentifier] rangeOfString:@"inhouse"].location != NSNotFound) {
          build = [infoDictionary objectForKey:@"CFBundleVersion"];
          version = [version stringByAppendingString:[NSString stringWithFormat:@".%@",build]];
     }
     
     NSString *country = [self countySymbol];
     NSString *label = @"";
     if (country) {
          label = [NSString stringWithFormat:@"v%@%@ %@",version, env, country];
     }else{
          label = [NSString stringWithFormat:@"v%@%@",version, env];
     }
     return label;
}

+(NSAttributedString*)getWelcomeAtributeString{
     
     NSMutableAttributedString * string = nil;
     UIColor * gray = [UIColor colorWithRed:171.0/255.0 green:171.0/255.0 blue:171.0/255.0 alpha:1.0];
     UIColor * white = [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];

     if ([[ConfigManager getAppName] isEqualToString:@"Homestyler"]) {
          string = [[NSMutableAttributedString alloc] initWithString:[ConfigManager getWelcomeSentence]];
          [string addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(0,6)];
          [string addAttribute:NSForegroundColorAttributeName value:white range:NSMakeRange(6,4)];
          [string addAttribute:NSForegroundColorAttributeName value:white range:NSMakeRange(10,5)];
          [string addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(15,4)];
          [string addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(19,2)];
          [string addAttribute:NSForegroundColorAttributeName value:white range:NSMakeRange(21,2)];
     }
     
     if ([[ConfigManager getAppName] isEqualToString:@"Ideal Standard"]) {
          string = [[NSMutableAttributedString alloc] initWithString:[ConfigManager getWelcomeSentence]];
          [string addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(0,6)];
          [string addAttribute:NSForegroundColorAttributeName value:white range:NSMakeRange(6,8)];
          [string addAttribute:NSForegroundColorAttributeName value:gray range:NSMakeRange(14,3)];
          [string addAttribute:NSForegroundColorAttributeName value:white range:NSMakeRange(17,7)];
     }

     return string;
}

///////////////////////////////////////////////////////
//              PLIST MANAGEMENT                     //
///////////////////////////////////////////////////////

#pragma mark - Bootstrap pList Management

+ (BOOL)isOptionActive:(NSString*)option inCategoryName:(NSString*)categoryName
{
     if (!option || [option isEqualToString:@""] || !categoryName || [categoryName isEqualToString:@""]) {
          return NO;
     }
     
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if(!bootstrapDict)
          return NO;
     
     NSDictionary *featuresDict = [bootstrapDict objectForKey:categoryName];
     
     if (!featuresDict)
          return NO;
     
     // The order in the array is important
     return [[featuresDict objectForKey:option] boolValue];
}

+ (NSDictionary*)getBootstrapDictionary
{
     // Path to the plist (in the application bundle)
     NSString *path = [[NSBundle mainBundle] pathForResource:@"Bootstrap" ofType:@"plist"];
     
     // Build the array from the plist
     NSDictionary *bootstrapDict = [[NSDictionary alloc] initWithContentsOfFile:path];
     
     if (!bootstrapDict)
          return nil;
     
     return bootstrapDict;
}

- (NSString*)getConfigVersionControlUrl
{
     NSDictionary * bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if(!bootstrapDict)
          return nil;
     
     NSDictionary *apiEnvironment;
     #if DEBUG
          apiEnvironment = [bootstrapDict objectForKey:CONFIG_ENVIRONMENT_UAT];
     #else
          apiEnvironment = [bootstrapDict objectForKey:CONFIG_ENVIRONMENT_PROD];
     #endif
     
     if (!apiEnvironment)
          return nil;
     
     NSString * configVersionUrl = nil;
     NSString * countrySymbol = [self countySymbol];
     configVersionUrl = [apiEnvironment objectForKey:@"getVersion"];
     
     if (countrySymbol) {
          //FR
          if ([countrySymbol isEqualToString:@"FR"]) {
               configVersionUrl = [configVersionUrl stringByReplacingOccurrencesOfString:@"ids" withString:@"ids-france"];
          }
     }
     
     return configVersionUrl;
}

- (NSString*)getConfigURL
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSDictionary *apiEnvironment;
     if ([[[NSBundle mainBundle] bundleIdentifier] rangeOfString:@"consumer"].location == NSNotFound) {//设计家生产环境
          apiEnvironment = [bootstrapDict objectForKey:CONFIG_ENVIRONMENT_PROD];
     } else {
          apiEnvironment = [bootstrapDict objectForKey:CONFIG_ENVIRONMENT_UAT];
     }
     
     if(!apiEnvironment)
          return nil;
     
     NSString * configUrl = nil;
     NSString * countrySymbol = [self countySymbol];
     configUrl = [apiEnvironment objectForKey:@"getConfig"];

     if (countrySymbol) {
          configUrl = [apiEnvironment objectForKey:@"getConfig"];
          //FR
          if ([countrySymbol isEqualToString:@"FR"]) {
               configUrl = [configUrl stringByReplacingOccurrencesOfString:@"ids" withString:@"ids-france"];
          }
     }
     
     return configUrl;
}

+(NSString*)getTenantIdName
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;

     NSString *appName = [bootstrapDict objectForKey:@"TenantID"];
     return appName;
}

+(NSString*)getHockeyAppIdKey
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appName = nil;
     
     if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.juran.homestyler.inhouse"]) {
          appName = [bootstrapDict objectForKey:@"HockeyAppIdDev"];
     }
     if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.juran.homestyler"]) {
          appName = [bootstrapDict objectForKey:@"HockeyAppIdProd"];
     }
     else if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.autodesk.homestylerDev"]) {
          appName = [bootstrapDict objectForKey:@"HockeyAppIdDev"];
     }
     else if([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.autodesk.ios.homestyler"]){
          appName = [bootstrapDict objectForKey:@"HockeyAppIdProd"];
     }
     
     return appName;
}

+(NSString*)getWeChatAppId
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *weChatAppId = [bootstrapDict objectForKey:@"WeChatAPPId"];
     return weChatAppId;
}

+(NSString*)getUMengAppId
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *uMengAppId = [bootstrapDict objectForKey:@"UMengAPPId"];
     return uMengAppId;
}

+(NSString*)getAppName
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appName = [bootstrapDict objectForKey:@"AppName"];
     return appName;
}

+(NSString*)getAppID
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appID = [bootstrapDict objectForKey:@"AppID"];
     return appID;
}

+(NSString*)getWelcomeSentence{
     
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];

     if (!bootstrapDict)
          return nil;
     
     NSString * type = IS_IPAD ? @"WelcomeSentenceIPad" : @"WelcomeSentenceIPhone";
     
     NSString *welcomeSentence = [bootstrapDict objectForKey:type];
     return welcomeSentence;
}

+(NSString*)getAppHelpArticleUrl
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appName = [bootstrapDict objectForKey:@"AppHelpArticleUrl"];
     return appName;
}

+(NSString*)getMarketPlaceUrl{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appName = [bootstrapDict objectForKey:@"MarketPlaceUrl"];
     return appName;

}


+(NSString*)getRedirectorIdentifier
{
     NSDictionary *bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return nil;
     
     NSString *appName = [bootstrapDict objectForKey:@"RedirectorIdentifier"];
     return appName;
}

+(NSString*)getCompanyDesignerUid {
     if ([[ConfigManager getTenantIdName] isEqualToString:@"ezhome"]){
          return @"MNKH7K2HFL0ZX78";
     }else{
          return @"b37878b2-32e4-4b9c-8236-f77a5b270054";
     }
}

+(BOOL)isWhiteLabel {
     NSDictionary * bootstrapDict = [ConfigManager getBootstrapDictionary];
     
     if (!bootstrapDict)
          return NO;
     
     // An App is a whitelabel if and only if its name is NOT "Homestyler"
     NSString *appName = [bootstrapDict objectForKey:@"AppName"];
     if (![appName isEqualToString:@"Homestyler"]) {
          return YES;
     }
     
     return NO;
}

+(BOOL)isWLMagazineActive {
     return [ConfigManager isOptionActive:@"WLMagazine"
                           inCategoryName:@"Features"];
}

+(BOOL)isMagazineActive {
     return [ConfigManager isOptionActive:@"Magazine"
                           inCategoryName:@"Features"];
}

+(BOOL)isProfessionalIndexActive {
     return [ConfigManager isOptionActive:@"ProffesionalIndex"
                           inCategoryName:@"Features"];
}

+(BOOL)is2DGalleryActive {
     return [ConfigManager isOptionActive:@"2DGallery"
                           inCategoryName:@"Features"];
}

+(BOOL)is3DGalleryActive {
     return [ConfigManager isOptionActive:@"3DGallery"
                           inCategoryName:@"Features"];
}

+(BOOL)isAddYourBrandActive {
     return [ConfigManager isOptionActive:@"AddYourBrand"
                           inCategoryName:@"Features"];
}

+(BOOL)isCatalogIconsActive{
     return [ConfigManager isOptionActive:@"CatalogIcons"
                           inCategoryName:@"Features"];
}

+(BOOL)isFaceBookActive {
     return [ConfigManager isOptionActive:@"Facebook"
                           inCategoryName:@"Features"];
}

+(BOOL)isNewsLetterActive {
     return [ConfigManager isOptionActive:@"NewsLetter"
                           inCategoryName:@"Features"];
}

+(BOOL)isPortraitModeActive {
     return [ConfigManager isOptionActive:@"PortraitCamera"
                           inCategoryName:@"Features"];
}

+(BOOL)isSegmentActive {
     return [ConfigManager isOptionActive:@"Segment"
                           inCategoryName:@"Features"];
}

+(BOOL)isPushNotifiactionActive {
     return [ConfigManager isOptionActive:@"PushNotification"
                           inCategoryName:@"Features"];
}

+(BOOL)isFindFriendsActive {
     return [ConfigManager isOptionActive:@"FindFriends"
                           inCategoryName:@"Features"];
}

+(BOOL)isFlurryActive {
     return [ConfigManager isOptionActive:@"Flurry"
                           inCategoryName:@"Features"];
}

+(BOOL)isFaceBookLoginActive {
     return [ConfigManager isOptionActive:@"FacebookLogin"
                           inCategoryName:@"Login"];
}

+(BOOL)isEmailLoginActive {
     return [ConfigManager isOptionActive:@"EmailLogin"
                           inCategoryName:@"Login"];
}

+(BOOL)isForgotPasswordActive {
     return [ConfigManager isOptionActive:@"ForgotPassword"
                           inCategoryName:@"Login"];
}

+(BOOL)isOfflineModeActive {
     return [ConfigManager isOptionActive:@"OfflineMode"
                           inCategoryName:@"Features"];
}

+(BOOL)isWishListActive{
     return [ConfigManager isOptionActive:@"WishList"
                           inCategoryName:@"Features"];
}

+(BOOL)isSwapableVariationActive{
     return [ConfigManager isOptionActive:@"SwapableVariation"
                           inCategoryName:@"Features"];
}

+(BOOL)isCollectionsActive{
     return [ConfigManager isOptionActive:@"Collections"
                           inCategoryName:@"Features"];
}

+(BOOL)isSignInWebViewActive{
     return [ConfigManager isOptionActive:@"SignInWebView"
                           inCategoryName:@"Features"];
}

+(BOOL)isSignInSSOActive{
     return [ConfigManager isOptionActive:@"SignInSSO"
                           inCategoryName:@"Features"];
}

+(BOOL)isFamiliesActive {
     return [ConfigManager isOptionActive:@"Families"
                           inCategoryName:@"Features"];
}

+(BOOL)isProductInfoLeftRightActive {
     return [ConfigManager isOptionActive:@"ProductInfoLeftRight"
                           inCategoryName:@"Features"];
}

+(BOOL)isDesignLayersActive {
     return [ConfigManager isOptionActive:@"DesignLayers"
                           inCategoryName:@"Features"];
}

+(BOOL)isNewCategoryActive{
     return [ConfigManager isOptionActive:@"NewCategory"
                           inCategoryName:@"Features"];
}

+(BOOL)isShowCompaniesPaintActive{
     return [ConfigManager isOptionActive:@"ShowCompaniesPaint"
                           inCategoryName:@"Features"];
}

+(BOOL)isShowConcealerHelpActive{
     return [ConfigManager isOptionActive:@"ShowConcealerHelp"
                           inCategoryName:@"Features"];
}

+(BOOL)isReDirectToMarketPlaceActive{
     return [ConfigManager isOptionActive:@"ReDirectToMarketPlace"
                           inCategoryName:@"Features"];
}

+(BOOL)isStopOnWallActive{
     return [ConfigManager isOptionActive:@"StopOnWall"
                           inCategoryName:@"Features"];
}

+(BOOL)isLevitateButtonActive{
     return [ConfigManager isOptionActive:@"LevitateButton"
                           inCategoryName:@"Features"];
}

+(BOOL)isLocationBasedTenantActive{
     return [ConfigManager isOptionActive:@"LocationBasedTenant"
                           inCategoryName:@"Features"];
}

+(BOOL)isWeChatActive{
     return [ConfigManager isOptionActive:@"WeChat"
                           inCategoryName:@"Features"];
}

+(BOOL)isChineseOnlyActive{
     return [ConfigManager isOptionActive:@"ChineseOnly"
                           inCategoryName:@"Features"];
}

+(BOOL)isSetPassWord{
     return [ConfigManager isOptionActive:@"SetPassWord"
                           inCategoryName:@"Features"];
}

+(BOOL)isMoreInfoDisplay{
     return [ConfigManager isOptionActive:@"MoreInfoDisplay"
                           inCategoryName:@"Features"];
}

+(BOOL)isFromDIY {
     return [[NSUserDefaults standardUserDefaults] boolForKey:@"AppState"];
}

-(void)setCurrentApp:(ESAppState)appName {
     [[NSUserDefaults standardUserDefaults] setBool:appName == APP_DIY ? YES : NO forKey:@"AppState"];
     [[NSUserDefaults standardUserDefaults] synchronize];
}

//**********************************************************************
// LOG
//**********************************************************************

+(BOOL)isDesginManagerLogActive{
     return [ConfigManager isOptionActive:@"DesignManagerLog"
                           inCategoryName:@"Debug"];
}

+(BOOL)isPackageManagerLogActive{
     return [ConfigManager isOptionActive:@"PackageManagerLog"
                           inCategoryName:@"Debug"];
}

+(BOOL)isFileDownloadManagerLogActive{
     return [ConfigManager isOptionActive:@"FileDownloadManagerLog"
                           inCategoryName:@"Debug"];
}

+(BOOL)isProductSnappingToWallActive {
     return [ConfigManager isOptionActive:@"ProductSnappingToWalls"
                           inCategoryName:@"ToolFeatures"];
}

+(BOOL)isShowGridActive {
     return [ConfigManager isOptionActive:@"ShowGrid"
                           inCategoryName:@"ToolFeatures"];
}

@end
