//
//  ESDesignAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/11/13.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESDesignAPI.h"
#import "JRNetEnvConfig.h"

@implementation ESDesignAPI

+ (void)getProprietorProjectList:(NSString *)j_member_id
                      withOffset:(NSString *)offset
                       withLimit:(NSString *)limit
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure {
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@design/construct/project/list/%@", baseUrl, j_member_id];
    NSDictionary *param = @{@"offset" : offset ?: @"0",
                            @"limit"  : limit  ?: @"10"};
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:param withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"业主项目列表：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getDemandListWithDispatchType:(NSString *)dispatchType
                       withDesignerId:(NSString *)designerId
                           withOffset:(NSString *)offset
                            withLimit:(NSString *)limit
                          withSuccess:(void(^)(NSDictionary *dict))success
                           andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.designUrl;
    NSString *url = [NSString stringWithFormat:@"%@designer/demand/%@/%@", baseUrl, designerId, dispatchType];
    NSDictionary *param = @{@"offset" : offset ?: @"0",
                            @"limit"  : limit  ?: @"10"};
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:param withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"设计师- %@ -项目列表：%@",dispatchType, dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 项目详情
 
 @param demandId 项目id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDemandDetailWithDemandId:(NSString *)demandId
                          andSuccess:(void(^)(NSDictionary *dict))success
                          andFailure:(void(^)(NSError *error))failure {
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.designUrl;
    NSString *url = [NSString stringWithFormat:@"%@demand/member/%@/detail", baseUrl, demandId];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
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

+ (void)getDesignerInfoWithDesignerId:(NSString *)designerId
                         success:(void (^)(NSDictionary *dict))success
                         failure:(void(^) (NSError *error))failure {
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@design/designer/%@", baseUrl, designerId];
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@", dict);
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
