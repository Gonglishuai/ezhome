//
//  AppCore.m
//  HomestylerCore
//
//  Created by Berenson Sergei on 4/7/13.
//  Copyright (c) 2013 Berenson Sergei. All rights reserved.
//

#import "AppCore.h"
#import "ProfsManager.h"
#import "GalleryItemDO.h"
#import "ProfProjectAssetDO.h"
#import "CoreRO.h"
#import "UserManager.h"
#import "SDWebImageManager.h"
#import "SDImageCacheNew.h"
#import "WallpapersManager.h"
#import "FloortilesManager.h"
#import "ModelsHandler.h"
#import "NotificationNames.h"
#import "ARConfigManager.h"

@interface AppCore ()



@end

@implementation AppCore
@synthesize _homeMan;
@synthesize _profsMan;
@synthesize _comMan;
@synthesize _galMan;

static RKObjectManager * _httpRKManager;
static RKObjectManager * _httpsRKManager;
static RKObjectManager * _httpsCloudlessRKManager;
static RKObjectManager * _httpCloudlessRKManager;
static RKObjectManager * _httpRKManagerV2;
static RKObjectManager * _httpCloudlessRKManagerV2;
static RKObjectManager * _httpSSORKManager;

static AppCore *sharedInstance = nil;

+ (AppCore *)sharedInstance {
    
    static dispatch_once_t pred;        // Lock
    dispatch_once(&pred, ^{             // This code is called at most once per app
        sharedInstance = [[AppCore alloc] init];
        sharedInstance._profsMan=[ProfsManager sharedInstance];
        sharedInstance._galMan=[GalleryStreamManager sharedInstance];
        sharedInstance._comMan=[[CommentsManager alloc] init];
        sharedInstance._homeMan=[HomeManager sharedInstance];
    });
    
    return sharedInstance;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    return self;
}

-(void)logoutUser{

    [[UserManager sharedInstance] userLogoutWithCompletionBlock:nil queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [[UIMenuManager sharedInstance] logoutWithUI];
    [[GalleryStreamManager sharedInstance] logout];
    [_homeMan logout];
    [_profsMan logout];
    [[UserManager sharedInstance]clearUserInfo];
    [[[AppCore sharedInstance]getProfsManager]clearFollowingData];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
    [NSNotification notificationWithName:@"refreshUI" object:nil userInfo:@{ @"isSuccess" : @YES}]];
    [[NSNotificationCenter defaultCenter] postNotificationOnMainThread:
    [NSNotification notificationWithName:kNotificationUserDidFailLogin object:nil userInfo:nil]];
}

-(void)load{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *myEncodedObject = [defaults objectForKey:@"appcore_v1"];
    if (myEncodedObject==nil) {
        
    }else
   sharedInstance = (AppCore *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
}

-(void)save{
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:sharedInstance];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myEncodedObject forKey:@"appcore_v1"];
    [defaults synchronize];
}

-(BOOL)needCacheRefreshForHomeScreenImage:(ImageInfo*)img{
    NSMutableDictionary * storedBgs=(NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"stored_home_bg"];
    
    if (storedBgs==nil) {
        return YES;
    }
    
    if ([storedBgs objectForKey:img.url]) {
        //ids not equal,means image changed
        if ([[storedBgs objectForKey:img.url] isEqual:img.imageId]==true) {
            //update the new id
            return NO;
        }
    }

    return YES;
}

-(void)Initialize
{
    if (![ConfigManager isAnyNetworkAvailable] || [[ConfigManager sharedInstance]isConfigLoaded]==NO)
    {
        return;
    }
    
    //update autosave interval
    NSNumber * interval = [[ConfigManager sharedInstance] autoSaveDesignIntervalSeconds];
    [self getDesignsManager].autoSaveInterval = ([interval intValue] == 0) ? 30 : [interval intValue];
    
    
    [[CoreRO new] getAppBackgroundsWithCompletionBlock:^(id serverResponse) {
        
        self.appBackgrounds = serverResponse;
        
        if (self.appBackgrounds && self.appBackgrounds.count && ((ImageInfo*)self.appBackgrounds[0]).url.length)
        {
            //store image id if not stored yet
            
            NSMutableDictionary * storedBgs=(NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"stored_home_bg"];
            
            if (!storedBgs) {
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                
                for (int i=0; i<[self.appBackgrounds count]; i++) {
                    ImageInfo *img=[self.appBackgrounds objectAtIndex:i];
                    [dict setObject:img.imageId forKey:img.url];
                    img.needClearCache=YES;
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"stored_home_bg"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }else{
                //we had previous ids stored
                
                for (int i=0; i<[self.appBackgrounds count]; i++) {
                    ImageInfo *img=[self.appBackgrounds objectAtIndex:i];
                    
                    
                    if ([self  needCacheRefreshForHomeScreenImage:img]) {
                        NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:storedBgs];
                        [temp setObject:img.imageId forKey:img.url];
                        img.needClearCache = YES;
                        storedBgs = temp;
                    }
                }
                
                //finally restore the dictionary
                [[NSUserDefaults standardUserDefaults] setObject:storedBgs forKey:@"stored_home_bg"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            //首页替换图片完成通知
            [[NSNotificationCenter defaultCenter] postNotificationName:@"APP_BACKGROUNDS_FINISH" object:nil];
        }
        
        
    } failureBlock:^(NSError *error) {
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        //preload combo options for professions,styles etc..
        [[UserManager sharedInstance] getUserComboOptionsWithCompletionBlock:Nil queue:dispatch_get_main_queue()];
        
        [[GalleryStreamManager sharedInstance] refreshBanner];
        
    });
    //Will load catalog icons file from server
    [ModelsHandler sharedInstance];
    
    [ColorsManager sharedInstance];
    [[WallpapersManager sharedInstance] prefetchWallpapersData];
    [[FloortilesManager sharedInstance] prefetchFloortilesData]; 
}

-(void)InitializeContent:(UIViewController<HSSplashScreen>*) splash
{
    if (![ConfigManager isAnyNetworkAvailable] || [[ConfigManager sharedInstance]isConfigLoaded]==NO)
    {
        [splash showApp];
        return;
    }
    
    if ([[UserManager sharedInstance] isLoggedIn]) {
        [sharedInstance._profsMan getUserFollowedProfessionalsWithFinishBlock:nil];
    }
        
    //update autosave interval
    NSNumber * interval = [[ConfigManager sharedInstance] autoSaveDesignIntervalSeconds];
    [self getDesignsManager].autoSaveInterval = ([interval intValue] == 0) ? 30 : [interval intValue];
    
    
    [[CoreRO new] getAppBackgroundsWithCompletionBlock:^(id serverResponse) {
      
        self.appBackgrounds = serverResponse;
        
        if (self.appBackgrounds && self.appBackgrounds.count && ((ImageInfo*)self.appBackgrounds[0]).url.length)
        {
            //store image id if not stored yet
            
            NSMutableDictionary * storedBgs=(NSMutableDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"stored_home_bg"];
            
            if (!storedBgs) {
                NSMutableDictionary * dict = [NSMutableDictionary dictionary];
                
                for (int i=0; i<[self.appBackgrounds count]; i++) {
                    ImageInfo *img=[self.appBackgrounds objectAtIndex:i];
                    [dict setObject:img.imageId forKey:img.url];
                    img.needClearCache=YES;
                }
                
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"stored_home_bg"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }else{
                //we had previous ids stored
                
                for (int i=0; i<[self.appBackgrounds count]; i++) {
                    ImageInfo *img=[self.appBackgrounds objectAtIndex:i];
                    
                    
                    if ([self  needCacheRefreshForHomeScreenImage:img]) {
                        NSMutableDictionary * temp = [NSMutableDictionary dictionaryWithDictionary:storedBgs];
                        [temp setObject:img.imageId forKey:img.url];
                        img.needClearCache = YES;
                        storedBgs = temp;
                    }
                }
                
                //finally restore the dictionary
                [[NSUserDefaults standardUserDefaults] setObject:storedBgs forKey:@"stored_home_bg"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            
            [splash showApp];
        }
        else
        {
            [splash showApp];
        }
        
    } failureBlock:^(NSError *error) {
        [splash showApp];
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{ //preload combo options for professions,styles etc..
                       [[UserManager sharedInstance] getUserComboOptionsWithCompletionBlock:Nil queue:dispatch_get_main_queue()];
                   });
    //Will load catalog icons file from server
    [ModelsHandler sharedInstance];
}

- (BOOL)backgroundImagesAvailable
{
    return self.appBackgrounds!=nil && self.appBackgrounds.count>1;
    
}

-(void)clearApplicationCache
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nag_about_contact"];
    [[WallpapersManager sharedInstance] clearCache];
    [[FloortilesManager sharedInstance] clearCache];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    [[ConfigManager sharedInstance] cleanStreamsDirectoryWithoutTiemstamps];
    [[ModelsHandler sharedInstance] deleteAllModelsData];
    [[ModelsHandler sharedInstance] clearMetadata];
    [[HelpManager sharedInstance] resetToShowHelp];
    [[SDImageCacheNew sharedImageCache] clearDisk];
    [[SDImageCacheNew sharedImageCache] clearMemory];
    [[ARConfigManager sharedInstance] clearArModelsData];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}


#pragma mark- 
#pragma mark Sub managers acess

-(ProfsManager*)getProfsManager{
    
    return  sharedInstance._profsMan;
}
-(GalleryStreamManager*)getGalleryManager{
    return sharedInstance._galMan;
}

-(CommentsManager*)getCommentsManager{
    return sharedInstance._comMan;
}

-(HomeManager*)getHomeManager{
    return sharedInstance._homeMan;
}
-(DesignsManager*)getDesignsManager{
    return sharedInstance._designsMan;
}
#pragma mark- Start RestKIT

+(void)setupRestkit:(NSDictionary*)config
{
   NSNumber *  apiCallTimeoutSeconds=[[config objectForKey:@"api_failures"]objectForKey:@"api_call_timeout"];
    
    if (!apiCallTimeoutSeconds) {
        apiCallTimeoutSeconds=[NSNumber numberWithInt:30];
    }
    
    ApiAction * h1=[[ApiAction alloc] init];
    h1.isHttps=NO;
    h1.isCloud=YES;
    RKObjectManager *objectManager = [BaseRO managerForAction:h1 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_base_url_cloud"]] andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpRKManager:objectManager];
    
    ApiAction * h2=[[ApiAction alloc] init];
    h2.isHttps=NO;
    h2.isCloud=NO;
    RKObjectManager *objectManager2 = [BaseRO managerForAction:h2 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_base_url"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager2 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpCloudlessRKManager:objectManager2];
    
    
    ApiAction * h3=[[ApiAction alloc] init];
    h3.isHttps=YES;
    h3.isCloud=NO;
    RKObjectManager *objectManager3 = [BaseRO managerForAction:h3 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_base_url_https"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager3 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpsCloudlessRKManager:objectManager3];
    
    
    ApiAction * h4=[[ApiAction alloc] init];
    h4.isHttps=YES;
    h4.isCloud=YES;
    RKObjectManager *objectManager4 = [BaseRO managerForAction:h4 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_base_url_https_cloud"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager4 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpsRKManager:objectManager4];
    
    ApiAction * h5=[[ApiAction alloc] init];
    h5.isHttps=NO;
    h5.isCloud=NO;
    RKObjectManager *objectManager5 = [BaseRO managerForAction:h5 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_nbe_base_url"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager5 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpCloudlessRKManagerV2:objectManager5];
    
    ApiAction * h6=[[ApiAction alloc] init];
    h6.isHttps = NO;
    h6.isCloud = YES;
    RKObjectManager *objectManager6 = [BaseRO managerForAction:h6 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_nbe_base_url_cloud"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager6 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpRKManagerV2:objectManager6];
    
    ApiAction * h7=[[ApiAction alloc] init];
    RKObjectManager *objectManager7 = [BaseRO managerForAction:h7 withBaseUrl:[NSURL URLWithString:[config objectForKey:@"restkit_sso_url"]]  andTimeout:[apiCallTimeoutSeconds intValue]];
    [[objectManager7 HTTPClient] setDefaultHeader:@"Accept-Encoding" value:@"gzip, deflate"];
    
    [AppCore setHttpSSORKManager:objectManager7];
}

+ (RKObjectManager *)httpRKManager{
    return _httpRKManager;
}
+ (void)setHttpRKManager:(RKObjectManager *)httpRKManager{
    _httpRKManager = httpRKManager;
}
+ (RKObjectManager *)httpsRKManager{
    return _httpsRKManager;
}
+ (void)setHttpsRKManager:(RKObjectManager *)httpsRKManager{
    _httpsRKManager = httpsRKManager;
}
+ (RKObjectManager *)httpsCloudlessRKManager{
    return _httpsCloudlessRKManager;
}
+ (void)setHttpsCloudlessRKManager:(RKObjectManager *)httpsCloudlessRKManager{
    _httpsCloudlessRKManager = httpsCloudlessRKManager;
}
+ (RKObjectManager *)httpCloudlessRKManager{
    return _httpCloudlessRKManager;
}
+ (void)setHttpCloudlessRKManager:(RKObjectManager *)httpCloudlessRKManager{
    _httpCloudlessRKManager = httpCloudlessRKManager;
}
+ (RKObjectManager *)httpRKManagerV2{
    return _httpRKManagerV2;
}
+ (void)setHttpRKManagerV2:(RKObjectManager *)httpRKManagerV2{
    _httpRKManagerV2 = httpRKManagerV2;
}
+ (RKObjectManager *)httpCloudlessRKManagerV2{
    return _httpCloudlessRKManagerV2;
}
+ (void)setHttpCloudlessRKManagerV2:(RKObjectManager *)httpCloudlessRKManagerV2{
    _httpCloudlessRKManagerV2 = httpCloudlessRKManagerV2;
}
+ (RKObjectManager *)httpSSORKManager{
    return _httpSSORKManager;
}
+ (void)setHttpSSORKManager:(RKObjectManager *)httpSSORKManager{
    _httpSSORKManager = httpSSORKManager;
}
@end

