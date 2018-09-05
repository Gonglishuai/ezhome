//
//  AppController.m
//  MarketPlace
//
//  Created by zzz on 16/1/21.
//  Copyright © 2016年 xuezy. All rights reserved.
//

#import "SHAppGlobal.h"
#import "MBProgressHUD.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"
#import <Reachability/Reachability.h>
#import <MGJRouter/MGJRouter.h>

#define OVERDUE_STATUSCODE 401


@interface SHAppGlobal()

@end

@implementation SHAppGlobal

+ (NSString*)AppGlobal_GetAppMainVersion
{
    NSString *boudleId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *version=[NSString stringWithFormat:@"Version %@",boudleId];
    return version;
}

+ (BOOL) AppGlobal_GetIsDesignerMode
{
    NSString *type = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
    return ([type isEqualToString:@"designer"])?(YES):(NO);
}

+(BOOL) AppGlobal_GetIsConsumerMode
{
    NSString *type = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
    return ([type isEqualToString:@"member"])?(YES):(NO);
}

+ (BOOL) AppGlobal_GetIsInspectorMode
{
    NSString *type = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
    return ([type isEqualToString:@"inspector"])?(YES):(NO);
}

+ (BOOL) AppGlobal_GetIsClientmanagerMode
{
    NSString *type = [JRKeychain loadSingleUserInfo:UserInfoCodeType];
    return ([type isEqualToString:@"clientmanager"])?(YES):(NO);
}

+ (void)openSettingPrivacy
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}


+ (void)clearCookie
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

+ (BOOL)isHaveNetwork
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status == NotReachable)
    {
        return NO;
    }
    return YES;
}

@end
