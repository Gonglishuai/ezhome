//
//  ESAddrerssAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/6/27.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESAddrerssAPI.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"
@interface ESAddrerssAPI()

@end

@implementation ESAddrerssAPI

#pragma mark - APIs
+ (void)getAddressListWithSuccess: (void(^)(NSArray *array))success
                       andFailure: (void(^)(NSError *error))failure{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.memberService;
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *url = [NSString stringWithFormat:@"%@address/member/%@", baseUrl, jMemberId];
    
    NSDictionary *headerDict = [self getDefaultHeader];
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSMutableArray * array = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        NSArray *result = [NSArray array];
        if (array && [array isKindOfClass:[NSArray class]]) {
            result = array;
        }
        
        if (success) {
            success(result);
        }
    } andFailure:failure];
}

+ (void)setDefaultAddressWithAddressID:(NSString *)addressId
                           withSuccess:(void(^)(void))success
                            andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.memberService;
    NSString *url = [NSString stringWithFormat:@"%@address/primary/%@", baseUrl, addressId];
    
    NSDictionary *headerDict = [self getDefaultHeader];
    [SHHttpRequestManager Put:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:failure];
}

+ (void)deleteAddressWithAddressID:(NSString *)addressId
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.memberService;
    NSString *url = [NSString stringWithFormat:@"%@address/%@", baseUrl, addressId];
    
    NSDictionary *headerDict = [self getDefaultHeader];
    [SHHttpRequestManager Delete:url withParameters:nil withHeaderField:headerDict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:failure];
}

+ (void)updateAddressWithAddressID:(NSString *)addressId
                   withAddressInfo:(NSDictionary *)addressInfo
                       withSuccess:(void(^)(void))success
                        andFailure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:addressInfo];
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    [dict setObject:jMemberId forKey:@"memberId"];
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.memberService;
    NSString *url = [NSString stringWithFormat:@"%@address/%@", baseUrl, addressId];
    
    NSDictionary *headerDict = [self getDefaultHeader];
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:dict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)createNewAddress:(NSDictionary *)addressInfo
             withSuccess:(void(^)(void))success
              andFailure:(void(^)(NSError *error))failure {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:addressInfo];
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    [dict setObject:jMemberId forKey:@"memberId"];
    NSString *url = [NSString stringWithFormat:@"%@address",[JRNetEnvConfig sharedInstance].netEnvModel.memberService];
    
    NSDictionary *headerDict = [self getDefaultHeader];
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:dict withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 根据cityName获取详细位置信息
 
 @param cityName 城市名字
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getLocationDetailWithCityName:(NSString *)cityName Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.mdmService;
    [SHHttpRequestManager Get:[[NSString stringWithFormat:@"%@region/all?city=%@", baseUrl, cityName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

+ (void)retrieveNewDistrictWithSuccess:(void(^)(NSDictionary *content, NSDictionary *responseHeader))success
                            andFailure:(void(^)(NSError *error))failure {
    NSString *url = [NSString stringWithFormat:@"%@district",[JRNetEnvConfig sharedInstance].netEnvModel.mdmService];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:[self getDefaultHeader] withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        
        NSDictionary *header = ((NSHTTPURLResponse *)task.response).allHeaderFields;
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
        
        if (success) {
            success(returnDict, header);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getOrderDefaultAddressWithRegionId:(NSString *)regionId
                               withSuccess:(void(^)(NSDictionary *dict))success
                                andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.memberService;
    NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *url = [NSString stringWithFormat:@"%@address/member/%@/region/%@", baseUrl, jMemberId, regionId];
    
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:nil];
        
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}
@end

