//
//  ESMemberAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/18.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMemberAPI.h"
#import "SHHttpRequestManager.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"

@implementation ESMemberAPI

+ (void)getMemberInfoWithID:(NSString *)j_member_id
                andSucceess:(void(^)(NSDictionary *dict))success
                 andFailure:(void(^)(NSError *error))failure {
    
    NSString *url =[NSString stringWithFormat:@"%@member/%@",[JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer, j_member_id];
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header  withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * designersDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"当前用户信息：%@",designersDict);
        if (success) {
            success(designersDict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)updateMemberAvatarWithFile:(NSData *)file
                        witSuccess:(void (^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure {
    
    NSString *url = [NSString stringWithFormat:@"%@/member/upload/image",[JRNetEnvConfig sharedInstance].netEnvModel.host];
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    NSDictionary *fileDic = [NSDictionary dictionaryWithObjectsAndKeys:file,@"data",@"file",@"name",@"file.png",@"fileName",@"image/png",@"type", nil];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:header withFiles:[NSArray arrayWithObject:fileDic] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLResponse * _Nullable response, NSData * _Nullable responseData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData
                                                             options:0
                                                               error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)updataMemberInfoWithID:(NSString *)j_member_id
                      withDict:(NSDictionary *)dict
                   withSuccess:(void(^)(NSDictionary *dict))success
                    andFailure:(void(^)(NSError *error))failure {
    
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@member/%@", baseUrl, j_member_id];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:header withBody:dict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
        if (success) {
            success(dict);
        };
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getDesignerTagsWithSuccess:(void(^)(NSDictionary *dict))success
                        andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@member/designerFilterInfo", baseUrl];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"设计师筛选tags：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getIndividuationImagesWithSuccess:(void(^)(NSDictionary *dict))success
                               andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@member/master/banner", baseUrl];
    NSDictionary *header = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:header withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSLog(@"个性定制海报推片tags：%@",dict);
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getMyMessageListWithParam:(NSDictionary *)paramDict
                       andSuccess:(void(^) (NSDictionary *dict))success
                       andFailure:(void(^) (NSError *error))failure
{
    
    NSString *url = [NSString stringWithFormat:@"%@message/page",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl];
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Get:url withParameters:paramDict withHeader:headerDict withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * designersDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(designersDict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)updateMyMessageStatus:(NSDictionary *)paramDict
                       andSuccess:(void(^) (NSDictionary *dict))success
                       andFailure:(void(^) (NSError *error))failure
{
    
    NSString *url = [NSString stringWithFormat:@"%@message/update",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl];
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    [SHHttpRequestManager Get:url withParameters:paramDict withHeader:headerDict withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * designersDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
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
