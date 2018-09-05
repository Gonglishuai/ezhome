//
//  ESRecommendAPI.m
//  ESNetworking
//
//  Created by jiang on 2018/1/4.
//  Copyright © 2018年 Easyhome Shejijia. All rights reserved.
//

#import "ESRecommendAPI.h"
#import "SHHttpRequestManager.h"
#import "SHRequestTool.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"

@implementation ESRecommendAPI

/**
 获取推荐清单列表

 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance
                         
                         
                         
                         ].netEnvModel.recommend;
    NSString *url = [NSString stringWithFormat:@"%@recommends?offset=%ld&limit=%ld", baseUrl, (long)pageNum, (long)pageSize];
    if(name && name.length>0) {
        url = [NSString stringWithFormat:@"%@&name=%@", url, name];
    }
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 获取推荐清单详情
 
 @param recommendId 推荐清单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.recommend;
    NSString *url = [NSString stringWithFormat:@"%@recommends/app/%@", baseUrl, recommendId];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 获取推荐品牌列表
 
 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getBrandRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.recommend;
    NSString *url = [NSString stringWithFormat:@"%@recommendsBrand?offset=%ld&limit=%ld", baseUrl, (long)pageNum, (long)pageSize];
    if(name && name.length>0) {
        url = [NSString stringWithFormat:@"%@&name=%@", url, name];
    }
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
/**
 获取推荐品牌详情
 
 @param recommendId 推荐品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getBrandRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.recommend;
    NSString *url = [NSString stringWithFormat:@"%@recommendsBrand/detail/%@", baseUrl, recommendId];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
/**
 删除推荐品牌
 
 @param recommendId 推荐品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)deleteBrandRecommendDetailWithRecommendId:(NSString *)recommendId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.recommend;
    NSString *url = [NSString stringWithFormat:@"%@recommendsBrand/%@", baseUrl, recommendId];
    
    [SHHttpRequestManager Delete:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 获取合作品牌列表
 
 @param name 搜索名字
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getCooperativeBrandRecommendListWithName:(NSString *)name pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.manufacturer;
     NSString *jMemberId = [JRKeychain loadSingleUserInfo:UserInfoCodeJId];
    NSString *url = [NSString stringWithFormat:@"%@decoration/designer/getBrandPageByMemberId?jMemberId=%@&offset=%ld&limit=%ld", baseUrl, jMemberId, (long)pageNum, (long)pageSize];
    if(name && name.length>0) {
        url = [NSString stringWithFormat:@"%@&brandName=%@", url, name];
    }
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 获取客户订单订单列表
 
 @param searchName 搜索字段
 @param orderType 订单类型
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendOrderListWithName:(NSString *)searchName OrderType:(NSString *)orderType pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/recommendListApp?", baseUrl];
    if (searchName.length>0) {
        url = [NSString stringWithFormat:@"%@condition=%@&", url, searchName];
    }
    if (orderType.length>0) {
        url = [NSString stringWithFormat:@"%@orderStatus=%@&", url, orderType];
    }
    url = [NSString stringWithFormat:@"%@offset=%ld&limit=%ld", url, (long)pageNum, (long)pageSize];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 客户订单退货订单列表

 @param searchName 搜索字段
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getRecommendReturnOrderListWithName:(NSString *)searchName PageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/returnsListApp?", baseUrl];
    if (searchName.length>0) {
        url = [NSString stringWithFormat:@"%@sourceName=%@&", url, searchName];
    }
    url = [NSString stringWithFormat:@"%@offset=%ld&limit=%ld", url, (long)pageNum, (long)pageSize];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 获取推荐清单列表
 
 @param X_Member_Id 设计师id
 @param offset 起始记录数
 @param limit 每页条数
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getDesignerRecommendList:(NSString *)X_Member_Id
                      withOffset:(NSInteger)offset
                       withLimit:(NSInteger)limit
                     withSuccess:(void(^)(NSDictionary *dict))success
                      andFailure:(void(^)(NSError *error))failure{
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.recommend;
    NSString *url =[NSString stringWithFormat:@"%@recommends/share/record/member?offset=%ld&limit=%ld", baseUrl,offset,limit];
    //    @"http://10.101.0.197:8080/api/v1/recommends/share/record/member?offset=0&limit=10";
    
    
    [SHHttpRequestManager Get:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**
 推送分享 --- 设计师使用
 
 @param dict 数据模型  包括推荐分享的资源和消费者信息
 @param success success
 @param failure failure
 */
+ (void)postRecommendShareDictionary:(NSDictionary *)dict withSuccess:(void(^)(NSDictionary *dict))success andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@recommends/share",[JRNetEnvConfig sharedInstance].netEnvModel.recommend];
    
    [SHHttpRequestManager Post: url withParameters:nil withHeader:headerDict withBody:dict  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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


/**
 校验手机号是否为平台用户
 
 @param phoneNumber 推送的手机号
 @param success success
 @param failure failure
 */
+ (void)postCheckPhoneNumberIsUser:(NSString *)phoneNumber withSuccess:(void(^)(NSDictionary *dict))success andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@/cas-proxy-sign/guest_user_account/api/v1/users/validate?execute=user.account.validate.has",[JRNetEnvConfig sharedInstance].netEnvModel.host];
    
    
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setValue:phoneNumber forKey:@"mobile"];
    
    [SHHttpRequestManager Post: url withParameters:nil withHeader:headerDict withBody:body  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
