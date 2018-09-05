//
//  ESMemberIdAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMemberIdAPI.h"
#import "JRNetEnvConfig.h"

@implementation ESMemberIdAPI

+ (void)getMemberIdWithUid:(NSString *)uid
                andSuccess:(void(^)(NSDictionary *dict))success
                andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.nimService;
    NSString *url = [NSString stringWithFormat:@"%@nim/user/createByUmsId/%@", baseUrl, uid];

    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        if (success) {
            success(returnDict);
        }

    } andFailure:failure];
}

+ (void)getNimIdWithDealerId:(NSString *)dealerId
                  andSuccess:(void(^)(NSDictionary *dict))success
                  andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.manufacturer;
    NSString *url = [NSString stringWithFormat:@"%@nim/createByIos/%@", baseUrl, dealerId];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        if (success) {
            success(dict);
        };
    } andFailure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}
@end
