//
//  ESCommentAPI.m
//  Consumer
//
//  Created by jiang on 2017/11/14.
//  Copyright © 2017年 EasyHome. All rights reserved.
//

#import "ESCommentAPI.h"
#import "SHHttpRequestManager.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"

@implementation ESCommentAPI

/**
 点赞
 
 @param resourceId 资源id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addLikeWithResourceId:(NSString *)resourceId
                         type:(NSString *)type
                  withSuccess:(void(^)(NSDictionary *dict))success
                   andFailure:(void(^)(NSError *error))failure {
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@like/save",baseUrl];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    NSDictionary *body = @{@"resourceIdStr": resourceId,
                           @"type":type,
                           };
    [SHHttpRequestManager Post:url withParameters:nil withHeader:header  withBody:body withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"返回数据：%@",dict);
        if (success) {
            success(dict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


/**
 取消点赞
 
 @param resourceId 资源id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteLikeWithResourceId:(NSString *)resourceId
                            type:(NSString *)type
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@like/%@/%@",baseUrl, type, resourceId];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Delete:url withParameters:nil withHeader:header  withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"返回数据：%@",dict);
        if (success) {
            success(dict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


/**
 关注
 
 @param followId 被关注id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)addFollowWithFollowId:(NSString *)followId
                         type:(NSString *)type
                  withSuccess:(void(^)(NSDictionary *dict))success
                   andFailure:(void(^)(NSError *error))failure {
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@follow/save/%@/%@",baseUrl, followId, type];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Post:url withParameters:nil withHeader:header  withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"返回数据：%@",dict);
        if (success) {
            success(dict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 取消关注
 
 @param followId 被关注id
 @param type 资源类型  0设计师,1.案例,2.商品,3.其他
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteFollowWithFollowId:(NSString *)followId
                            type:(NSString *)type
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.commentService;
    NSString *url = [NSString stringWithFormat:@"%@follow/delete/%@/%@",baseUrl, followId, type];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Delete:url withParameters:nil withHeader:header  withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"返回数据：%@",dict);
        if (success) {
            success(dict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


/**
 获取关注列表
 
 @param pageNum 页码 1开始
 @param pageSize 每页数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getMyFollowListWithPageNum:(NSInteger)pageNum
                          pageSize:(NSInteger)pageSize
                       withSuccess:(void(^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@follow/list/%ld/%ld",baseUrl, (long)pageNum, (long)pageSize];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"返回数据：%@",dict);
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
