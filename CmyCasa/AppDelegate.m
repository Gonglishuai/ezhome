//
//  AppDelegate.m
//  CmyCasa
//
//  Copyright (c) 2012 CmyCasa Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "ExternalLaunchManager.h"
#import "SDImageCache.h"
#import "WXApi.h"
#import "WXApiManager.h"
//#import "UMMobClick/MobClick.h"
#import <HockeySDK/HockeySDK.h>
//#import <Analytics/SEGAnalytics.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <TwitterKit/TwitterKit.h>
#import "NUISettings.h"
#import "NSBundle+Language.h"
#import "NSString+Time.h"
#import <StoreKit/StoreKit.h>

//SJJ 环境配置
#import "ESNIMManager.h"
#import "CoTabBarControllerManager.h"
#import "CoLinkPageTool.h"
#import "SHQRCodeTool.h"
#import "ESAppConfigManager.h"
#import "ESRegionManager.h"
#import "JRLocationServices.h"
#import "ESMainURLServices.h"
#import "ESWxServices.h"
#import "ESWeiboServices.h"
#import "ESFinanceServices.h"
#import "ESMasterialHomeController.h"
#import "ESDeviceUtil.h"
#import "ESHTTPSessionManager.h"
#import "ESAlipayServices.h"
#import "ESUPAServices.h"
#import "ESPromotionUtil.h"
#import "SHLoginTool.h"
#import "ESOrientationManager.h"
#import "ESNavigationController.h"
#import "ESUniversalLinkManager.h"
#import <ESFoundation/ESPublicMethods.h>
#import "ControllersFactory.h"
#import "CustomNavigationController.h"
#import "GalleryBaseViewController.h"

@interface AppDelegate()<UITabBarControllerDelegate, SHQRCodeToolDelegate, ESLoginManagerDelegate,GalleryBaseDelegate>
@property (strong, nonatomic) CoTabBarControllerManager *tabBarManager;
@property (assign, nonatomic) ESLoginType loginType;
@property (nonatomic, strong) ESNIMManager *nimManager;
@end

@implementation AppDelegate
{
    UIDeviceOrientation prevOrientation;
    NSDate* lastRefreshTime;
    int storeReviewEvents;
    int storeReviewDays;
    int storeReviewLaunchs;
}

- (void) setDrawableMultisample
{
    [self glkView].drawableMultisample = GLKViewDrawableMultisample4X;
}

-(void)specialCaseLogin:(NSString *)confVersion completionBlock:(HSCompletionBlock)completion queue:(dispatch_queue_t)queue
{
    BOOL needToCallcompletionCalled = YES;
    
    if (confVersion) {
        //clean process
        //1. Clear local Cache
        [[ConfigManager sharedInstance] cleanStreamsDirectoryWithoutTiemstamps];
        //2. Update config file
        if([[ConfigManager sharedInstance] refreshConfigWithSpecialUsage:confVersion])
        {
            //3. silent relogin
            
            needToCallcompletionCalled = NO;
            
            [[UserManager sharedInstance] userSilentLoginWithCompletionBlock:^(id serverResponse, id error) {
                //4. Move to designStream
                //on main thread navigate back to menu and refresh stream
                
                if(completion)
                    completion(serverResponse,nil);
                
            } queue:dispatch_get_main_queue()];
        }
    }
    
    if(needToCallcompletionCalled == YES)
    {
        completion(nil,nil);
    }
}

-(void)startLoadingProcess{
    
    prevOrientation = UIDeviceOrientationUnknown;
#ifdef USE_FLURRY
    if (IS_IPAD) {
        NSString * key=[[ConfigManager sharedInstance] flurryAppID];
//        [Flurry startSession:key];
    }else{
        NSString * key=[[ConfigManager sharedInstance] flurryAppIDIphone];
//        [Flurry startSession:key];
    }
    
    
    NSDictionary *dictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:@"IOS",FLURRY_DEVICE_TYPE,
     nil];
    if(ANALYTICS_ENABLED){
//        [HSFlurry logEvent:FLURRY_TIME withParameters:dictionary timed:YES];
    }
#endif
    
    //Just until we will have the help button, force showing help screen.
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"UnitSelected"] == nil){
            [standardUserDefaults setObject:@YES forKey:@"UnitSelected"];
        }
        
        [UserSettingsPreferences initPreferences];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:@"AppRunningCount"] == nil){
            NSNumber* numAppRunningCount = [NSNumber numberWithInt:1];
            [standardUserDefaults setObject:numAppRunningCount forKey:@"AppRunningCount"];
        }
        else
        {
            int useCount = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:@"AppRunningCount"] intValue];
            
            if(useCount == 1)
            {
                //check for ios version, dont show alert if above ios 8 ,TODO://need to check after upgrade to ios 8
                if (!IS_IOS8_OR_GREATER)
                {
                    [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:YES];
                }
            }
            useCount++;

            NSNumber* numAppRunningCount = [NSNumber numberWithInt:useCount];
            [standardUserDefaults setObject:numAppRunningCount forKey:@"AppRunningCount"];
            
        }

        [standardUserDefaults synchronize];
    }
    
    self.glkView = [[GLKView alloc] initWithFrame:[UIScreen currentScreenBoundsDependOnOrientation]];
    
	self.glkVC = [[GLKViewController alloc] init];
	self.glkVC.view = self.glkView;
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.glkView.context = aContext;
	self.glkView.opaque = NO;
    self.glkView.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
	self.glkView.drawableStencilFormat = GLKViewDrawableStencilFormat8;
    [self setDrawableMultisample];
    self.glkVC.preferredFramesPerSecond = 60;
	self.glkVC.pauseOnWillResignActive = YES;
	self.glkVC.resumeOnDidBecomeActive = YES;
    
	self.textureLoader = [[GLKTextureLoader alloc] initWithSharegroup:aContext.sharegroup];
    
    lastRefreshTime = [NSDate date];
    
    [[SDImageCache sharedImageCache] setMaxMemoryCost:1209600]; // two weeks
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    storeReviewEvents = 3;
    storeReviewDays = 7;
    storeReviewLaunchs = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDIYUserInfo) name:@"SJJ_LOGOUT" object:nil];
}

-(void)showAlert{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:@"Analytics"
                                                  message:NSLocalizedString(@"analytics_msg", @"In order to improve this app, we recieve non-personal, aggregated product usage data. You can turn this off in app settings.")
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"OK")
                                        otherButtonTitles: nil];
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( 0 == buttonIndex ){ //cancel button
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if([url.scheme isEqualToString:[JRNetEnvConfig sharedInstance].netEnvModel.wxAppKey]) {
        return [ESWxServices handleOpenURL:url];
    } else if([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@", [JRNetEnvConfig sharedInstance].netEnvModel.weiboAppKey]]) {
        return [ESWeiboServices handleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        return [ESAlipayServices handleOpenURL:url];
    } else if([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@", [JRNetEnvConfig sharedInstance].netEnvModel.weiboAppKey]]) {
        return [ESWeiboServices handleOpenURL:url];
    } else if ([url.scheme isEqualToString:[JRNetEnvConfig sharedInstance].netEnvModel.schemeForUPAPay]){
        [ESUPAServices handleOpenURL:url];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        return [ESAlipayServices handleOpenURL:url];
    } else if([url.scheme isEqualToString:[JRNetEnvConfig sharedInstance].netEnvModel.wxAppKey]) {
        return [ESWxServices handleOpenURL:url];
    } else if([url.scheme isEqualToString:[NSString stringWithFormat:@"wb%@", [JRNetEnvConfig sharedInstance].netEnvModel.weiboAppKey]]) {
        return [ESWeiboServices handleOpenURL:url];
    } else if ([url.scheme isEqualToString:[JRNetEnvConfig sharedInstance].netEnvModel.schemeForUPAPay]){
        [ESUPAServices handleOpenURL:url];
    }
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *token = [deviceToken description];
	token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [[ExternalLaunchManager sharedInstance] setPushNotificationToken:token];
	
    [[ExternalLaunchManager sharedInstance] checkRegistration];
    
    HSMDebugLog(@"My token is: %@", deviceToken);
    
    #pragma mark - RemoteNotifications
    [[ESNIMManager sharedManager] updateApnsToken:deviceToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	HSMDebugLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	HSMDebugLog(@"Received notification: %@", userInfo);
    [[ExternalLaunchManager sharedInstance] launchedFromPushNotification:userInfo];
   
	//app is already running, for the time being do nothing
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [self configNetwork];
    
    //获取App Config
    [[ESAppConfigManager sharedManager] start];
    
    //获取行政区信息
    [ESRegionManager retrieveNewDistrict];
    
    [[JRLocationServices sharedInstance] setUpApiKey];
    [[JRLocationServices sharedInstance] requestLocation:^(JRCityInfo *city) {
        SHLog(@"%@", city);
    }];
    //开启登录服务
    [[ESLoginManager sharedManager] addLoginDelegate:self];
    
    //URL路由注册
    [ESMainURLServices registerESMainURLServices];
    
    //微信注册
    [[ESWxServices sharedInstance] setUpApiKey];
    
    [self setDelegate];
    
    [self initNIM];
    
    [[ESWeiboServices sharedInstance] setUpApiKey];
    
    [ESFinanceServices sharedInstance];
    
#ifndef UNIT_TESTS
    if (IS_IPAD)
    {
        [NUISettings initWithStylesheet:@"HSStyle"];
    }
    else
    {
        [NUISettings initWithStylesheet:@"HSStyle-iPhone"];
    }
#endif
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"design_id_load_request"]) {
        NSLog(@"Param passed %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"design_id_load_request"]);
    }
    
#ifdef SERVER_RENDERING    
self.forceHighQualityRender = YES;
#else
    self.forceHighQualityRender = NO;
#endif
    NSString *deviceType = [UIDevice currentDevice].model;
    if ([[deviceType lowercaseString] rangeOfString:@"simulator"].location==NSNotFound) {
        
        if ([ConfigManager isPushNotifiactionActive]) {
            if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
            {
                // iOS 8 Notifications
                [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
                
                [application registerForRemoteNotifications];
            }
        }
    }

    if (launchOptions != nil)
	{
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			HSMDebugLog(@"Launched from push notification: %@", dictionary);
            [[ExternalLaunchManager sharedInstance] launchedFromPushNotification:dictionary];
		}
        
        // Handle launching from a notification
        UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        if (locationNotification) {
            HSMDebugLog(@"Launched from local notification: %@", locationNotification);
            [[ExternalLaunchManager sharedInstance] launchedFromLocalNotification:locationNotification];
        }
	}
    
    [self setApplicationLocal];

    [self segmentAppLunch];
    
    @try {
        [JRKeychain loadSingleUserInfo:UserInfoCodeName];
    } @catch (NSException *exception) {
        NSString *domain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domain];
    } @finally {
        [NSThread sleepForTimeInterval:0.5];
        return [super application:application didFinishLaunchingWithOptions:launchOptions];
    }
    
    return YES;
}


-(void)setApplicationLocal
{
    NSArray *  localizationsArray = [[NSBundle mainBundle] localizations];
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([ConfigManager isChineseOnlyActive]) {
        [defaults setObject:@"zh-Hans" forKey:@"lang_symbole"];
        [defaults synchronize];
    }
    
    NSString * langSymbol = [defaults objectForKey:@"lang_symbole"];

    if (!langSymbol) {
        BOOL isLangSupport = NO;
        //check if the device lang is support by the app
        for (NSString * curLocal in localizationsArray) {
            if ([language isEqualToString:curLocal]) {
                langSymbol = curLocal;
                break;
            }
        }
    }

    if (langSymbol) {
        [NSBundle setLanguage:langSymbol];
    }
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)locationNotification {
    HSMDebugLog(@"Received local notification: %@", locationNotification);
    if (application.applicationState != UIApplicationStateActive) {
        [[ExternalLaunchManager sharedInstance] launchedFromLocalNotification:locationNotification];
    }
}

#pragma mark - 是否横屏
- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    return [ESOrientationManager getUIInterfaceOrientationMask];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    [self.glkVC setPaused:YES];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    BOOL isConfigLoaded = [[ConfigManager sharedInstance] isConfigLoaded];
    
    if (isConfigLoaded == NO)
    {
        [[ConfigManager sharedInstance] loadConfigData];
    }
    
    if (self.tbVC.selectedIndex == 3
        || [self.tbVC.selectedViewController isKindOfClass:[ESMasterialHomeController class]])
    {
        [self.tbVC.selectedViewController viewWillAppear:YES];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    [FBSDKAppEvents activateApp];
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [self.glkVC setPaused:NO];

    NSString * userID = [[[UserManager sharedInstance] currentUser] userID];
//    [HSFlurry logAnalyticEvent:EVENT_NAME_APP_ACTIVATED withParameters:@{EVENT_PARAM_USER_ID:(userID)?userID:@"none"}];
    
    if (![ESLoginManager sharedManager].isLogin) return;
    
    [SHLoginTool checkMemberTypeWithUpdate:^(NSString *newMemberType)
     {
         // 如果用户类型发生改变, 则刷新首页
         if (newMemberType) {
             [[ESLoginManager sharedManager] logout];
             [[ESLoginManager sharedManager] login];
         }
     }];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        NSDictionary *dictionary =
        [NSDictionary dictionaryWithObjectsAndKeys: @"IOS",@"DeviceType",
         nil];
//        [Flurry endTimedEvent:@"Total time spent" withParameters:dictionary];
    }
#endif
    
#ifdef USE_UMENG
//    [MobClick endLogPageView:[ConfigManager getAppName]];
#endif
}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    if (!self.forceHighQualityRender) {
        self.glkView.drawableMultisample = GLKViewDrawableMultisampleNone;
        self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    }
}

void uncaughtExceptionHandler(NSException *exception) {
//    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

- (UIDeviceOrientation )getSavedDesignOrientation
{
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(  orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp &&
       orientation != UIDeviceOrientationFaceDown ) {
        prevOrientation = orientation;
    }
    return UIDeviceOrientationLandscapeLeft;
}

-(UIDeviceOrientation)getPrevOrientation{
    return prevOrientation;
}

- (void) RefreshGaleryStream{
    NSDate* now = [NSDate date];
    NSNumber* refreshRate =  [[ConfigManager sharedInstance] refreshRateGalleryStream];
    if(refreshRate > 0)
    {
        NSTimeInterval timeInterRefreshRate=[refreshRate intValue]*60;//*3600;
        
        NSDate * expdate=[lastRefreshTime dateByAddingTimeInterval:timeInterRefreshRate];
        if ([now compare:expdate]==NSOrderedDescending )
        {
            lastRefreshTime = now;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDataStream"  object:nil];
            
        }
    }
}

- (void)setReviewEvents:(int) events {
    storeReviewEvents = events;
}

- (void)setReviewDays:(int) days {
    storeReviewDays = days;
}

- (void)updateReviewEvent {
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReviewEvent"];
    if (count == nil) {
        count = [NSNumber numberWithInt:0];
    }
    count = [NSNumber numberWithInt:[count intValue] + 1];
    [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"StoreReviewEvent"];
    
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReivewDate"];
    if (date == nil) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"StoreReivewDate"];
    }
    
    if ([self needStoreReview]) {
        [self openStoreReview];
    }
}

- (void)updateReviewLogins {
    NSNumber *count = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReviewLaunch"];
    if (count == nil) {
        count = [NSNumber numberWithInt:0];
    }
    count = [NSNumber numberWithInt:[count intValue] + 1];
    [[NSUserDefaults standardUserDefaults] setObject:count forKey:@"StoreReviewLaunch"];
}

- (BOOL)needStoreReview {
    NSNumber *event = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReviewEvent"];
    NSNumber *launch = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReviewLaunch"];
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"StoreReivewDate"];
    
    int eventNum = [event intValue];
    int launchNum = [launch intValue];
    int dayNum = (int)[NSDate daysBetweenDate:lastDate andDate:[NSDate date]];
    return eventNum >= storeReviewEvents && dayNum >= storeReviewDays && launchNum >= storeReviewLaunchs;
}

- (void)openStoreReview {
    if ([SKStoreReviewController class]){
        [SKStoreReviewController requestReview] ;
    } else {
        NSString *nsStringToOpen = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review",[ConfigManager getAppID]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nsStringToOpen]];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"StoreReviewEvent"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"StoreReivewDate"];
}

#pragma mark - SEGMENT
-(void)segmentAppLunch{

    BOOL firstAppLunch = [[[NSUserDefaults standardUserDefaults] objectForKey:@"first_app_launch"] boolValue];
    if (!firstAppLunch) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"first_app_launch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

//    [HSFlurry segmentTrack:@"first app launch" withParameters:@{@"first app launch":!firstAppLunch ? @"YES" : @"NO"}];
//
//    [HSFlurry segmentTrack:@"app launch" withParameters:nil];
}

#pragma mark - 设计家环境配置
- (CoTabBarControllerManager *)tabBarManager
{
    if (_tabBarManager == nil)
    {
        _tabBarManager = [CoTabBarControllerManager tabBarManager];
    }
    return _tabBarManager;
}

- (void)configNetwork {
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *token = [JRKeychain loadSingleUserInfo:UserInfoCodeXToken];
    NSString *channel = @"10103";
    NSString *device = [ESDeviceUtil getUUID];
    
    //TODO 拆端前暂时这样处理
    NSString *platform;
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode]) {
        platform = @"designer";
    }else {
        platform = @"proprietor";
    }
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *system = @"iOS";
    NSString *region = [JRLocationServices sharedInstance].locationCityInfo.cityCode;
    
    
    NSDictionary *header = @{@"X-Member-Id" :jMemberId ? jMemberId : @"0",
                             @"X-Token"     :token ? token : @"",
                             @"X-Channel"   :channel,
                             @"X-Session-Id":device ? device : @"",
                             @"platform"    :platform,
                             @"version"     :version,
                             @"system"      :system,
                             @"X-Region"    :region ? region : @""};
    
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *status = [userDefaults objectForKey:@"app_location_key"];
    if (status
        && [status isKindOfClass:[NSString class]]
        && [status isEqualToString:@"NO"])
    {
        NSMutableDictionary *headerM = [header mutableCopy];
        [headerM setObject:@"110100" forKey:@"X-Region"];
        header = [headerM copy];
    }
    
    [[ESHTTPSessionManager sharedInstance] initDefaultHeader:header];
    
}

- (void)setDelegate
{
    [SHQRCodeTool sharedInstance].delegate = self;
}

- (void)initNIM {
    self.nimManager = [ESNIMManager sharedManager];
    [self.nimManager initNIM];
}

-(void)initTabbar
{
    [super initTabbar];
    
    if (![ESLoginManager sharedManager].isLogin)
    {
        BOOL roleChooseStatus = [CoLinkPageTool showRoleChoose];
        if (roleChooseStatus) return;
    }
    
    if (self.tbVC == nil)
    {
        self.tbVC = [[UITabBarController alloc]init];
        self.tbVC.delegate = self;
        [self.tabBarManager tabBarController:self.tbVC];
    }
    
    [self updateTabMode];
    
    self.window.rootViewController = self.tbVC;
    [self.window.window makeKeyAndVisible];
}

- (void)updateTabMode
{
    if (self.loginType == ESLoginTypeMasterialHome)
    {
        self.tbVC.selectedIndex = 3;
        self.loginType = ESLoginTypeHomePage;
    }
    else
    {
        [self resetTabsWithIndex:0];
    }
}

-(void)setTabBarItemSelected
{
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode])
    {
        self.tbVC.selectedIndex = 2;
    }else {
        self.tbVC.selectedIndex = 1;
    }
    
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [super tabBarController:tabBarController didSelectViewController:viewController];
    
    
    BOOL status = [ESLoginManager sharedManager].isLogin;
    if (status == NO && tabBarController.selectedIndex > 3)
    {
        tabBarController.selectedIndex = 0;
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    } else if (status == NO && [SHAppGlobal AppGlobal_GetIsDesignerMode] && tabBarController.selectedIndex == 2) {
        tabBarController.selectedIndex = 0;
        [MGJRouter openURL:@"/UserCenter/LogIn"];
    } else {
        [_tabBarManager changeTabBarSelectedIndex:tabBarController.selectedIndex];
    }
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    [_tabBarManager selectedTabBar:tabBarController viewController:viewController];
    
    return YES;
}

- (void)handlePushNotificationInForeground:(NSDictionary *)userInfo
{
    [super handlePushNotificationInForeground:userInfo];
    
    NSString *key = [userInfo objectForKey:@"messageType"];
    SHPushNotificationTargetType type = [self getPushNotificationType:key];
    if (type == SHPushNotificationTargetTypeActivity)
    {
        [ESPromotionUtil showPromotionAlert:userInfo];
    }
}

- (void)handlePushNotification:(NSDictionary *)userInfo
{
    [super handlePushNotification:userInfo];
    
    NSDictionary *customData = [userInfo objectForKey:@"customData"];
    NSString *projectId = nil;
    if (customData                                      &&
        [customData isKindOfClass:[NSDictionary class]] &&
        [customData objectForKey:@"project_id"])
        projectId = [customData objectForKey:@"project_id"];
    
    NSString *key = [userInfo objectForKey:@"messageType"];
    SHPushNotificationTargetType type = [self getPushNotificationType:key];
    switch (type)
    {
        case SHPushNotificationTargetTypeActivity:
        {
            [self showTabAtIndexType:CoTabIndexTypeHome];
            
            if ([customData isKindOfClass:[NSDictionary class]])
            {
                [ESPromotionUtil showPromotionViewWithUrl:customData[@"url"]
                                                     type:ESPromotionTypeBackground];
            }
        }
            
        default:
            break;
    }
}

- (void)updateApp
{
    [self resetTabViews];
    [self updateTabMode];
}

- (void)resetTabsWithIndex:(NSInteger)index
{
    if (self.tbVC.viewControllers
        && [self.tbVC.viewControllers isKindOfClass:[NSArray class]]
        && index >= self.tbVC.viewControllers.count)
    {
        return;
    }
    
    if (([SHAppGlobal AppGlobal_GetIsDesignerMode]
         && self.tabBarManager.tabType == ESTabTypeConsumer)
        || (![SHAppGlobal AppGlobal_GetIsDesignerMode]
            && self.tabBarManager.tabType == ESTabTypeDesigner)
        || self.tabBarManager.tabType == ESTabTypeUnKnow)
    {
        if ([SHAppGlobal AppGlobal_GetIsDesignerMode])
        {
            [self.tabBarManager chageToDesignerMode];
        }
        else
        {
            [self.tabBarManager chageToConsumerMode];
        }
    }
    
    self.tbVC.selectedIndex = index;
}

- (SHPushNotificationTargetType)getPushNotificationType:(NSString *)message
{
    if (!message)
    {
        return SHPushNotificationTargetTypeUnknown;
    }
    if ([message caseInsensitiveCompare:@"MESSAGE_PROMOTION"] == NSOrderedSame)
    {
        return SHPushNotificationTargetTypeActivity;
    }
    
    return SHPushNotificationTargetTypeUnknown;
}
#pragma mark - ESLoginManagerDelegate

/**
 这里主要处理第三方服务的注册/登录、注销/登出
 */

- (void)onLogin {
    [self configNetwork];
    [self resetTabViews];
    [[ESNIMManager sharedManager] manualLogin];
    if (![ConfigManager isFromDIY]) {
        [self initTabbar];
    }
    [ESDeviceUtil addDeviceAndLinked];
}

- (void)onLogout {
    [self resetTabViews];
    [[ESNIMManager sharedManager] logout];
    if (![ConfigManager isFromDIY]) {
        [self initTabbar];
    }
    [SHAlertView removeNetErrorStatus];
    
    // 删除关联
    [ESDeviceUtil deleteDeviceCallback:nil];
}

#pragma mark - SHQRCodeToolDelegate
- (void)showTabAtIndexType:(CoTabIndexType)indexType
{
    [self updateApp];
    
    [self.tbVC setSelectedIndex:indexType];
}

- (UIImage *)getDefaultUserAvatarImage
{
    return [UIImage imageNamed:@"default_avatar_design"];
}

#pragma mark - SHQRCodeToolDelegate
- (BOOL)setQRButtonShown
{
    if ([SHAppGlobal AppGlobal_GetIsDesignerMode])
    {
        return YES;
    }
    return NO;
}

// Universal Link 处理
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    SHLog(@"%@",userActivity.webpageURL);
    if ([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
        MPBaseViewController *vc = [ESUniversalLinkManager createNativeDetailsController:userActivity.webpageURL.absoluteString];
        if (vc != nil) {
            ESNavigationController *nav = [ESPublicMethods getCurrentNavigationController];
            [nav pushViewController:vc animated:YES];
        }
    }
    return YES;
}

#pragma mark -切换app事件-

-(void)changeApp:(ESAppState)state {
    if (state == APP_SJJ) {
        [self gotoSJJ];
    }else{
        [self gotoDIY];
    }
}

-(void)gotoSJJ {
    [[ConfigManager sharedInstance] setCurrentApp:APP_SJJ];
    [self configNetwork];
    [self resetTabViews];
    [self initTabbar];
}

-(void)gotoDIY {
    [[ConfigManager sharedInstance] setCurrentApp:APP_DIY];
    [[UserManager sharedInstance] loadUserInfo];
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIViewController *ghVC = [ControllersFactory instantiateViewControllerWithIdentifier:@"GalleryHomeViewControllerID" inStoryboard:kGalleryStoryboard];
    CustomNavigationController *mainVc = [[CustomNavigationController alloc] initWithRootViewController:ghVC];
    self.window.rootViewController = mainVc;
    [self.window makeKeyAndVisible];
}

-(void)clearSJJUserInfo {
    [[ESLoginManager sharedManager] logout];
}

-(void)clearDIYUserInfo {
    [[AppCore sharedInstance] logoutUser];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SJJ_LOGOUT" object:nil];
}
@end
