//
//  ESMemberSearchAPI.m
//  ESNetworking
//
//  Created by 焦旭 on 2017/11/22.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESMemberSearchAPI.h"
#import "JRNetEnvConfig.h"

@implementation ESMemberSearchAPI

+ (void)getDesignersListWithParam:(NSDictionary *)paramDict
                           header:(NSDictionary *)headerDict
                             body:(NSDictionary *)bodyDict
                       andSuccess:(void(^) (NSDictionary *dict))success
                       andFailure:(void(^) (NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@designers/search",[JRNetEnvConfig sharedInstance].netEnvModel.memberSearch];
    
    headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:headerDict];
    [SHHttpRequestManager Get:url withParameters:paramDict withHeader:headerDict withBody:bodyDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * designersDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"设计师信息：%@",designersDict);
        if (success) {
            success(designersDict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
