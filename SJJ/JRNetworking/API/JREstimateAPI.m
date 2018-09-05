//
//  JREstimateAPI.m
//  Consumer
//
//  Created by jiang on 2017/5/3.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "JREstimateAPI.h"
#import "SHHttpRequestManager.h"
#import "SHRequestTool.h"
#import "JRDesignInfomodel.h"
#import "JRKeychain.h"

@interface JREstimateAPI()

@end

@implementation JREstimateAPI

+ (NSDictionary *)getHeaderAuthorization {
    NSDictionary *headerDict = @{HEADER_AUTHORIZATION_KEY : [self getAuthorization]};
    return [SHRequestTool addAuthorizationForHeader:headerDict];
}

+ (NSString *)getAuthorization {
    return [NSString stringWithFormat:@"Basic %@",[JRKeychain loadSingleUserInfo:UserInfoCodeXToken]];//[SHAppGlobal AppGlobal_GetMemberInfoObj].X_Token];
}

//立即预约
+(void)estimateWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
     NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@demand/booking",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl];

    [SHHttpRequestManager Post: url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//设计详情
+ (void)getEngineDetailWithDemandsId:(NSString *)demands_id
                       andSuccess:(void(^)(JRDesignInfomodel *requirement))success
                       andFailure:(void(^)(NSError *error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@admin/booking/%@",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl,demands_id] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            JRDesignInfomodel *requirement = (JRDesignInfomodel *)[JRDesignInfomodel createModelWithDic:dict];
            success(requirement);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getDesignDetailWithDesignId:(NSString *)designId
                            success:(void(^)(NSDictionary *dict))success
                            failure:(void(^)(NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.construct;
    NSString *url = [NSString stringWithFormat:@"%@construct/mobile/basicInfo",baseUrl];
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    [SHHttpRequestManager Get:url
               withParameters:@{@"projectNum":designId}
                   withHeader:headerDict
                     withBody:nil
            withAFTTPInstance:manager
                   andSuccess:^(NSURLSessionDataTask *task, NSData *responseData)
    {
        NSDictionary * dict = [NSJSONSerialization
                               JSONObjectWithData:responseData
                               options:NSJSONReadingMutableContainers
                               error:nil];
        if (success)
        {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

//发起收款
+(void)makeCollectionsWithDemandsId:(NSString *)demands_id paramDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];

    NSString *url = [NSString stringWithFormat:@"%@demand/order/create",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl];
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//面对面生成二维码
+ (void)getPaymentQRWithBody:(NSDictionary *)body
                 withSuccess:(void (^)(NSDictionary * dict))success
                  andFailure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    [SHHttpRequestManager Post:[NSString stringWithFormat:@"%@demand/order/face2Face",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl] withParameters:nil withHeader:headerDict withBody:body  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

/**面对面是否已支付*/
+(void)getPaySuccessWithDemandsId:(NSString *)demands_id andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@demand/payStatus/%@",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl, demands_id] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//算算你家要花多少钱
+(void)computeYourHouseWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void (^)(NSURLSessionDataTask *, NSError *))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [SHHttpRequestManager Post:[NSString stringWithFormat:@"%@v1/budgets/result", [JRNetEnvConfig sharedInstance].netEnvModel.quoteUrl] withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (failure) {
            failure(task,error);
        }
    }];
}

//算算你家要花多少钱--获取短信验证码
+(void)getMessageCodeWithParamDic:(NSDictionary*)paramDic andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [SHHttpRequestManager Post:[NSString stringWithFormat:@"%@v1/sms/sms_codes", [JRNetEnvConfig sharedInstance].netEnvModel.quoteUrl] withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//算算你家要花多少钱--房屋类型几室几厅
+ (void)getHouseTypeSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
//    NSDictionary *headerDict = [self getHeaderAuthorization];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [SHHttpRequestManager Post:[NSString stringWithFormat:@"%@v1/houseTypes",[JRNetEnvConfig sharedInstance].netEnvModel.quoteUrl] withParameters:nil withHeader:nil withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//套餐首页
+ (void)getPackageHomeInfoWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
//    NSDictionary *headerDict = [self getHeaderAuthorization];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //dk: fixed
    NSString *fixedUrl = [NSString stringWithFormat:@"%@design/packageInfo",[JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer];
    
    [SHHttpRequestManager Get: fixedUrl withParameters:nil withHeader:nil withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {

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

/**支付定金*/
// TODO: 材料订单接口
+(void)payForWithOrderId:(NSString *)orderId orderLineId:(NSString *)orderLineId andSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@pay/alipay/app/parameters?orderId=%@&orderLineId=%@",[JRNetEnvConfig sharedInstance].netEnvModel.designUrl,orderId, orderLineId] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

//算算你家要花多少钱--也有业主数
+ (void)getComputNumSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [[ESHTTPSessionManager sharedInstance] getRequestHeader:nil];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [SHHttpRequestManager Get:[NSString stringWithFormat:@"%@v1/budgets/count", [JRNetEnvConfig sharedInstance].netEnvModel.quoteUrl] withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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

+ (void)getReturnGoodsListWithProjectId:(NSString *)pid
                                 offset:(NSInteger)offset
                                  limlt:(NSInteger)limit
                                success:(void (^) (NSDictionary *dict))success
                                failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/constructList?offset=%ld&limit=%ld&orderId=%@",baseUrl, (long)offset, (long)limit, pid];
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    [SHHttpRequestManager Get:url
               withParameters:nil
                   withHeader:headerDict
                     withBody:nil
            withAFTTPInstance:manager
                   andSuccess:^(NSURLSessionDataTask *task, NSData *responseData)
     {
         NSDictionary * dict = [NSJSONSerialization
                                JSONObjectWithData:responseData
                                options:NSJSONReadingMutableContainers
                                error:nil];
         if (success)
         {
             success(dict);
         }
     } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
                  
         if (failure)
         {
             failure(error);
         }
     }];
}

+ (void)createReturnGoodsWithOrderId:(NSString *)orderId
                              reason:(NSString *)reason
                             success:(void (^) (NSDictionary *dict))success
                             failure:(void (^) (NSError *error))failure
{
    if (!orderId
        || !reason)
    {
        if (failure)
        {
            failure(ERROR(@"111", 999, @"订单id或退款原因不存在"));
        }
        return;
    }
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/construct",baseUrl];
    NSDictionary *headerDict = [self getDefaultHeader];
    NSDictionary *body = @{
                           @"reason"   :reason,
                           @"ordersId" :orderId
                           };
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:headerDict
                      withBody:body
             withAFTTPInstance:manager
                    andSuccess:^(NSURLSessionDataTask *task, NSData *responseData)
    {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success)
        {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

+ (void)getRefundDetailWithRefundId:(NSString *)refundId
                            success:(void (^) (NSDictionary *dict))success
                            failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/constructRefundDetail?refundId=%@",baseUrl, refundId];
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    [SHHttpRequestManager Get:url
               withParameters:nil
                   withHeader:headerDict
                     withBody:nil
            withAFTTPInstance:manager
                   andSuccess:^(NSURLSessionDataTask *task, NSData *responseData)
     {
         NSDictionary * dict = [NSJSONSerialization
                                JSONObjectWithData:responseData
                                options:NSJSONReadingMutableContainers
                                error:nil];
         if (success)
         {
             success(dict);
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
         
         if (failure)
         {
             failure(error);
         }
     }];
}

@end
