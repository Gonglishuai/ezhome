//
//  JRHomeAPI.m
//  Consumer
//
//  Created by jiang on 2017/5/22.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JRHomeAPI.h"
#import "SHHttpRequestManager.h"
#import "SHRequestTool.h"
#import "JRDesignInfomodel.h"
#import "JRNetEnvConfig.h"
#import "JRLocationServices.h"

@interface JRHomeAPI()

@end

@implementation JRHomeAPI

//首页
+ (void)getHomePageWithType:(NSString *)type loginStatus:(BOOL)loginStatus Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSString *url = [NSString stringWithFormat:@"%@espot/appIndex/%@",[JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer, type];
    //    url = [NSString stringWithFormat:@"http://52.80.80.57:8080/api/v1/espot/appIndex/%@", type];
    NSMutableDictionary *header = [[self getDefaultHeader] mutableCopy];
    if (!loginStatus)
    {
        [header setObject:@"" forKey:@"X-Token"];
        [header setObject:@"0" forKey:@"X-Member-Id"];
    }
    [SHHttpRequestManager Get:url  withParameters:nil withHeader:header withBody:nil  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**论坛*/
+ (void)getBBSUrlWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSString *url = [JRNetEnvConfig sharedInstance].netEnvModel.bbsURL;

    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@?%ld", url, (long)[[NSDate date] timeIntervalSince1970]]  withParameters:nil withHeader:[self getDefaultHeader] withBody:nil  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**完善信息*/
+ (void)getPerfectInfoOrNotWithJid:(NSString *)jid
                       withSuccess:(void (^)(NSDictionary * dict))success
                        andFailure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@designers/perfectStatus/%@",[JRNetEnvConfig sharedInstance].netEnvModel.memberService, jid] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end

