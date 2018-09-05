//
//  ESAppConfigManager.m
//  Mall
//
//  Created by 焦旭 on 2017/9/18.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESAppConfigManager.h"
#import "SHHttpRequestManager.h"
#import "ESHTTPSessionManager.h"
#import "ESDesignCaseAPI.h"
#import <ESNetworking/JRNetEnvConfig.h>

#define REFRESH_TIPS_KEY @"espot_refreshTips_key"

@implementation ESAppConfigManager

+ (instancetype)sharedManager {
    static ESAppConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ESAppConfigManager alloc] init];
    });
    return instance;
}

- (void)start {
    // 获取Xcode config
    [self getXcconfig];
    
    // app config 初始化
    [self appConfigRequest];
    
    // 获取初始化数据
    [self homePageRefreshTips];
}

- (void)getXcconfig {
    JRNetEnvModel *envModel = [[JRNetEnvModel alloc] init];
    envModel.host = [NSString stringWithFormat:@"https://%@", SHEJIJIA_HOST];
    envModel.mServer = [NSString stringWithFormat:@"https://%@", M_SHEJIJIA_HOST];
    envModel.WebHost = [NSString stringWithFormat:@"https://%@", SHEJIJIA_WEB_HOST];
    envModel.imgHost = [NSString stringWithFormat:@"https://%@", SHEJIJIA_IMG_HOST];
    envModel.appType = APP_TYPE;
    envModel.envFlag = ENV_FLAG;
    envModel.bbsURL = [NSString stringWithFormat:@"https://%@", BBS_URL];
    envModel.mapServicesApiKey = AMAP_KEY;
    envModel.weiboAppKey = WEIBO_KEY;
    envModel.weiboRedirectURI = [NSString stringWithFormat:@"https://%@", WEIBO_REDIRECT_URI];
    envModel.wxAppKey = WX_APP_KEY;
    envModel.umengAppKey = UMENG_APP_KEY;
    envModel.umengChannelId = UMEMNG_CHANNEL_ID;
    envModel.schemeForUPAPay = UPAPAY_SCHEME;
    envModel.signStatus = true;
    
    BOOL isRelease = NO;
    if ([envModel.umengChannelId isEqualToString:@"App Store"]) {
        isRelease = YES;
    }
    
    [JRNetEnvConfig sharedInstance].netEnvModel = envModel;
    [JRNetEnvConfig sharedInstance].isReleaseModel = isRelease;
}

- (void)appConfigRequest {
    
    
    self.appConfig = [[ESAppConfig alloc] init];
    self.appConfig.bbs_home_url = [NSString stringWithFormat:@"https://%@",BBS_HOME_URL];
    self.appConfig.diary_url = [NSString stringWithFormat:@"https://%@",DIARY_URL];
    self.appConfig.design_url = [NSString stringWithFormat:@"https://%@",DESIGN_URL];
    self.appConfig.pay_the_contract_html = [NSString stringWithFormat:@"https://%@",PAY_THE_CONTRACT_HTML];
    
//    NSString *url;
//    url = [NSString stringWithFormat:@"https://%@", APP_CONFIG_URL];
    
//    url = [NSString stringWithFormat:@"%@?key=%lf",url,[[NSDate date] timeIntervalSince1970]];
//    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
//        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:responseData
//                                                             options:NSJSONReadingMutableContainers
//                                                               error:nil];
//
//        self.appConfig = [ESAppConfig objFromDict:dic];
//    } andFailure:^(NSError * _Nullable error) {
//        SHLog(@"获取动态App Config失败：%@", error.description);
//        @try {
//            self.appConfig = [ESAppConfig objFromDict:[self getConfig]];
//        } @catch (NSException *exception) {
//            SHLog(@"获取本地App Default Config失败：%@", exception.description);
//        }
//    }];
}

- (void)homePageRefreshTips
{
    if (![self getRefreshStatus])
    {
        return;
    }
    
    self.refreshTips = @[@"装房子 买家具 我都来设计家"];
    WS(weakSelf);
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [baseUrl stringByAppendingString:@"espot/refreshTips"];
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * dic = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingMutableContainers
                              error:nil];
        ESAppConstantInfo *info = [[ESAppConstantInfo alloc] initWithDict:dic];
        NSArray *arrTips = @[@"装房子 买家具 我都来设计家"];
        if (info
            && [info isKindOfClass:[ESAppConstantInfo class]]
            && [info.tips isKindOfClass:[NSArray class]]
            && info.tips.count > 0
            && [[info.tips firstObject] isKindOfClass:[NSString class]])
        {
            arrTips = info.tips;
        }
        weakSelf.refreshTips = arrTips;
        
        [weakSelf saveAppConstant:info];
    } andFailure:^(NSError * _Nullable error) {
        SHLog(@"获取数据信息失败");
    }];
}

- (NSDictionary *)getConfig {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"ESAppDefaultConfig" ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return data;
}

- (void)saveAppConstant:(ESAppConstantInfo *)info
{
    if (!info
        || ![info isKindOfClass:[ESAppConstantInfo class]]
        || ![info.tips isKindOfClass:[NSArray class]]
        || info.tips.count <= 0
        || ![[info.tips firstObject] isKindOfClass:[NSString class]])
    {
        return;
    }
    
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setObject:@([[NSDate date] timeIntervalSince1970]) forKey:@"savetime"];
    [dictM setObject:[NSString stringWithFormat:@"%@", info.validDays] forKey:@"validdays"];
    [dictM setObject:info.tips forKey:@"tips"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[dictM copy] forKey:REFRESH_TIPS_KEY];
    [userDefaults synchronize];
}

- (BOOL)getRefreshStatus
{
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:REFRESH_TIPS_KEY];
    if (!dict
        || ![dict isKindOfClass:[NSDictionary class]]
        || !dict[@"savetime"]
        || !dict[@"validdays"]
        || !dict[@"tips"])
    {
        return YES;
    }
    
    NSTimeInterval savetime = [dict[@"savetime"] doubleValue];
    NSInteger validdays = [dict[@"validdays"] integerValue];
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval spacetime = currentTime - savetime;
    if (spacetime < validdays * 24 * 60 * 60)
    {
        self.refreshTips = @[@"装房子 买家具 我都来设计家"];
        if ([dict[@"tips"] isKindOfClass:[NSArray class]]
            && [[dict[@"tips"] firstObject] isKindOfClass:[NSString class]])
        {
            self.refreshTips = dict[@"tips"];
        }
        return NO;
    }
    
    return YES;
}

- (NSArray *)refreshTips
{
    if (!_refreshTips)
    {
        _refreshTips = @[@"装房子 买家具 我都来设计家"];
    }
    return _refreshTips;
}

@end
