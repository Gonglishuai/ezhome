//
//  UMengServices.m
//  ESFoundation
//
//  Created by jiang on 2017/11/7.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import "UMengServices.h"
#import <UMMobClick/MobClick.h>
#import "SHSecurity.h"
#import "JRNetEnvConfig.h"

@implementation UMengServices

+ (void)setupUMengServices {
        UMConfigInstance.appKey = [JRNetEnvConfig sharedInstance].netEnvModel.umengAppKey;
        UMConfigInstance.channelId = [JRNetEnvConfig sharedInstance].netEnvModel.umengChannelId;
        UMConfigInstance.bCrashReportEnabled = NO;
        UMConfigInstance.ePolicy = BATCH;
        NSString *version = XcodeAppVersion;
        [MobClick setAppVersion:version];
//        [MobClick setLogEnabled:NO];
//        [MobClick setEncryptEnabled:YES];
        [MobClick startWithConfigure:UMConfigInstance];
}
    
+ (void)eventWithEventId:(NSString *)eventId {
    [MobClick event:eventId];
}
    
+ (void)eventWithEventId:(NSString *)eventId label:(NSString *)label {
    [MobClick event:eventId label:label];
}
    
+ (void)eventWithEventId:(NSString *)eventId attributes:(NSDictionary *)parameters {
    [MobClick event:eventId attributes:parameters];
}

+ (void)eventLoginWithAccount:(NSString *)account {
    if(!account                                  ||
       ![account isKindOfClass:[NSString class]] ||
       account.length <= 0)
        return;
    
    NSString *md5Account = [SHSecurity md5String:account
                                       isShorter:YES];
    if (!md5Account) return;
    [MobClick profileSignInWithPUID:md5Account];
}
+ (void)eventLogout {
    [MobClick profileSignOff];
}

+ (void)beginLogPageViewWithPageName:(NSString *)pageName {
    [MobClick beginLogPageView:pageName];
}
    
+ (void)endLogPageViewWithPageName:(NSString *)pageName {
    [MobClick endLogPageView:pageName];
}
    
@end
