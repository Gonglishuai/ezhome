//
//  ESLoginManager.m
//  Mall
//
//  Created by 焦旭 on 2017/8/30.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESLoginManager.h"
#import "JRKeychain.h"
#import "JRNetEnvConfig.h"
#import "SHHttpRequestManager.h"
#import "ESHTTPSessionManager.h"
#import <MGJRouter/MGJRouter.h>

#define ESLOGIN_STATUS @"ESLoginStatus"

@interface ESLoginManager()
@property (nonatomic, strong) NSHashTable *delegates;
@property (nonatomic, readwrite, assign) BOOL isLogin;
@end

@implementation ESLoginManager

+ (instancetype)sharedManager
{
    static ESLoginManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ESLoginManager alloc] init];
        instance.isLogin = [instance getLoginStatus];
    });
    return instance;
}

- (NSHashTable *)delegates
{
    if (_delegates == nil) {
        _delegates = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    }
    return _delegates;
}

- (void)addLoginDelegate:(id<ESLoginManagerDelegate>)delegate {
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

- (void)removeLoginDelegate:(id<ESLoginManagerDelegate>)delegate {
    if (self.delegates.count > 0 && [self.delegates containsObject:delegate]) {
        [self.delegates removeObject:delegate];
    }
}

- (void)login {
    [MGJRouter openURL:@"/UserCenter/LogIn"];
}

- (void)loginComplete:(NSDictionary *)dict {
    [self saveLoginStatus:YES];
    
    [JRKeychain saveAllUserInfo:dict];
    
    for (id<ESLoginManagerDelegate> obj in self.delegates) {
        if ([obj respondsToSelector:@selector(onLogin)]) {
            [obj onLogin];
        }
    }
}

- (void)logout {
    [self saveLoginStatus:NO];
    
    //登出cas_proxy
    [self logoutCAS_Proxy];
    
    [JRKeychain deleteUserInfo];
    
    [self clearCookie];
    
    //其他第三方服务登出交给上游处理
    for (id<ESLoginManagerDelegate> obj in self.delegates) {
        if ([obj respondsToSelector:@selector(onLogout)]) {
            [obj onLogout];
        }
    }
}

#pragma mark - Private
- (void)logoutCAS_Proxy {
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",[JRNetEnvConfig sharedInstance].netEnvModel.host,@"cas-proxy-sign/guest_user_account/api/v2/logout"];
    NSDictionary *header = @{@"X-Token": [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]};
    [SHHttpRequestManager Get:url
               withParameters:nil
                   withHeader:header
                     withBody:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:nil
                   andFailure:nil];
}

- (void)clearCookie {
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}

- (void)saveLoginStatus:(BOOL)isLogin {
    @try {
        self.isLogin = isLogin;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:isLogin forKey:ESLOGIN_STATUS];
        [defaults synchronize];
    } @catch (NSException *exception) {
        NSLog(@"ESLoginManager 存储登录状态异常：%@", exception.description);
    }
}

- (BOOL)getLoginStatus {
    BOOL result = NO;
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        result = [defaults boolForKey:ESLOGIN_STATUS];
    } @catch (NSException *exception) {
        NSLog(@"ESLoginManager 读取登录状态异常：%@", exception.description);
    } @finally {
        return result;
    }
   
}
@end
