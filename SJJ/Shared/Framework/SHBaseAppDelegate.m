//
//  AppDelegate.m
//  MarketPlace
//
//  Created by xuezy on 15/12/15.
//  Copyright © 2015年 xuezy. All rights reserved.
//

#import "SHBaseAppDelegate.h"
#import "SHAppGlobal.h"
#import "SHFileUtility.h"
#import "SHPushNotificationHandler.h"
#import <ESFoundation/UMengServices.h>
#import "SHVersionTool.h"
#import "JRKeychain.h"
#import "ESJPushManager.h"
#import "SHAlertView.h"
#import "ESDeviceUtil.h"

@interface SHBaseAppDelegate ()
<UITabBarControllerDelegate
//JPUSHRegisterDelegate
>

@end


@implementation SHBaseAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:@(NO) forKey:@"isOpenReachable"];
    [userDefaults synchronize];
    
    // 启动友盟
    [UMengServices setupUMengServices];
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
    
//    [self initTabbar];

//    [SHAppGlobal AppGlobal_SetNetworkDetectionEnable:YES];
#pragma mark - 版本检测存在问题（待修复）
//    [SHVersionTool requestForCheckVersion];

    // JPush相关
    [ESJPushManager setupWithOption:launchOptions];
    
    // check if this launched when user taps on push notification
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo)
        [self handlePushNotification:userInfo];
    
    UILocalNotification *localNotifi = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotifi) {
        [self handleLocalNotification:localNotifi.userInfo];
    }
    
    return YES;
}

-(void)initTabbar
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //清除网络请求失败的status
    [SHAlertView removeNetErrorStatus];
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // SHVersionTool 取消本地通知
    [SHVersionTool cancelLocalNotificationForVersionUpdate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // SHVersionTool 注册本地通知
    [SHVersionTool registerLocalNotificationForVersionUpdate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //清除网络请求失败的status
    [SHAlertView removeNetErrorStatus];
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return YES;
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}


#pragma mark - push notifications

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    SHLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    SHLog(@"%@",deviceToken);
    
    NSString *deviceTokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenString = [deviceTokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    SHLog(@"Sending Device registration request to Marketplace:%@",deviceTokenString);
    
    // JPush 上传Device Token
    [JPUSHService registerDeviceToken:deviceToken];
    
    // 添加并且关联设备
    [ESDeviceUtil addDeviceAndLinked];
}


- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    SHLog(@"Failed to get APNS token, error: %@", error);
}


- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    // 收到远程推送
//    [JPUSHService handleRemoteNotification:userInfo];

    if ( application.applicationState == UIApplicationStateActive )
    {
        SHLog(@"Received push notification while active in foreground: %@", userInfo);
        
        [self handlePushNotificationInForeground:userInfo];
    }
    else
    {
        SHLog(@"Received push notification while active in background: %@", userInfo);
        
        [self handlePushNotification:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ( application.applicationState == UIApplicationStateActive )
        SHLog(@"Received local notification while active in foreground: %@", notification.userInfo);
    else
    {
        SHLog(@"Received local notification while active in background: %@", notification.userInfo);
        
        [self handleLocalNotification:notification.userInfo];
    }
}

// derived class can override this to handle received push notifications
- (void)handlePushNotification:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return;
}

- (void)handlePushNotificationInForeground:(NSDictionary *)userInfo
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return;
}

- (void)handleLocalNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        if ([userInfo[@"key"] isEqualToString:@"local_notification_version_update"])
            [SHVersionTool openApplicationStoreWithUrl:userInfo[@"download_url"]];
    });
    return;
}

- (void) setTabBarItemSelected{
    
}

- (void)resetTabViews
{
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    
    if ([tabBarController presentedViewController])
    {
        UIViewController *presentedView = [tabBarController presentedViewController];
        [presentedView dismissViewControllerAnimated:NO completion:nil];
    }
    
    for(UIViewController *tabBarView in tabBarController.viewControllers)
    {
        if([tabBarView isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *bar = (UINavigationController*)tabBarView;
            [bar popToRootViewControllerAnimated:NO];
            [self.tbVC setSelectedIndex:0];
        }
        else if ([tabBarView presentedViewController])
        {
            [tabBarView dismissViewControllerAnimated:NO completion:nil];
        }
    }
    
    // 不可缺少.
    [self.tbVC dismissViewControllerAnimated:NO
                                  completion:nil];
}

- (UIImage *) getDefaultUserAvatarImage
{
    return nil;
}

@end
