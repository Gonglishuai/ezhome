//
//  ESOrderAPI.m
//  Consumer
//
//  Created by jiang on 2017/6/28.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESOrderAPI.h"
#import "SHHttpRequestManager.h"
#import "SHRequestTool.h"
#import "JRKeychain.h"
#import "JRNetEnvConfig.h"
#import "JRLocationServices.h"

@interface ESOrderAPI()

@end

@implementation ESOrderAPI

/**
 获取商城首页信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMasterialWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@espot/espotOfIndex", baseUrl];
    
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
 获取商品列表信息
 
 @param categoryId 目录id
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMasterialListWithCategoryId:(NSString *)categoryId
                            catalogId:(NSString *)catalogId
                             pageSize:(NSInteger)pageSize
                              pageNum:(NSInteger)pageNum
                              Success:(void (^)(NSDictionary * dict))success
                              failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    
    //    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    //    [body setObject:orderId forKey:@"payOrderId"];
    //    [body setObject:payWay forKey:@"payType"];
    
    NSString *url = [NSString stringWithFormat:@"%@product/list/%@?catalogId=%@&offset=%ld&limit=%ld", baseUrl, categoryId ,catalogId ,(long)pageNum, (long)pageSize];
    
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
 搜索商品列表
 
 @param searchName 搜索词
 @param facet 筛选项
 @param sort 排序
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)searchGoodsListWithName:(NSString *)searchName
                     catalogId:(NSString *)catalogId
                         facet:(NSString *)facet
                          sort:(NSString *)sort
                      pageSize:(NSInteger)pageSize
                       pageNum:(NSInteger)pageNum
                       Success:(void (^)(NSDictionary * dict))success
                       failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    
    NSString *url = [NSString stringWithFormat:@"%@product/search?catalogId=%@&searchTerm=%@&offset=%ld&limit=%ld", baseUrl, catalogId, searchName, (long)pageNum, (long)pageSize];
    
    if (![sort isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"%@&sort=%@", url, sort];
    }
    
    if (![facet isEqualToString:@""]) {
        url = [NSString stringWithFormat:@"%@&facet=%@", url, facet];
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
 支付订单
 
 @param orderId 订单id
 @param payWay 支付方式  支付方式 1支付宝app支付 2支付宝网页支付 3微信app支付 4微信网页扫码支付 5微信公众号支付 6支付宝当面付
 @param success 成功回调
 @param failure 失败回调
 */
+(void)payForWithOrderId:(NSString *)orderId payWay:(NSString *)payWay Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    [self payForWithOrderId:orderId
                     rateId:@""
                     payWay:payWay
                  payAmount:nil
                    Success:success
                    failure:failure];
}

+(void)payForWithOrderId:(NSString *)orderId
                  rateId:(NSString *)rateId
                  payWay:(NSString *)payWay
               payAmount:(NSString *)payAmount
                 Success:(void (^)(NSDictionary * dict))success
                 failure:(void(^)(NSError * error))failure
{
    if (!payAmount
        || ![payAmount isKindOfClass:[NSString class]])
    {
        payAmount = @"";
    }
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    
    NSString *businessType = @"101";
    NSString *appType = [JRNetEnvConfig sharedInstance].netEnvModel.appType;
    if ([appType isEqualToString:@"MALL"]) {
        businessType = @"102";
    }
    NSString *url = [NSString stringWithFormat:@"%@pay/payRequest?payOrderId=%@&payType=%@&payAmount=%@&businessType=%@", baseUrl, orderId, payWay, payAmount, businessType];
    if ([payWay isEqualToString:@"17"]) {
        url = [NSString stringWithFormat:@"%@&rateId=%@", url, rateId];
    }
    
    [SHHttpRequestManager Post:url withParameters:nil
                    withHeader:headerDict
                      withBody:nil
             withAFTTPInstance:manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
     {
         NSDictionary * dict = [NSJSONSerialization
                                JSONObjectWithData:responseData
                                options:NSJSONReadingMutableContainers
                                error:nil];
         if (success)
         {
             success(dict);
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error)
     {
         if (failure)
         {
             failure(error);
         }
     }];
}
/**
 草签转正签首款支付
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)initialToFormalpayForWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure{
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.designUrl;
    NSString *url = [NSString stringWithFormat:@"%@order/updateContractOrder/%@", baseUrl,orderId];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 获取订单列表
 
 @param orderType 订单类型
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getOrderListWithOrderType:(NSString *)orderType pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/list?orderStatus=%@&offset=%ld&limit=%ld", baseUrl, orderType, (long)pageNum, (long)pageSize];
    
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
 我的退货订单列表
 
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getReturnOrderListWithPageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/myList?offset=%ld&limit=%ld", baseUrl, (long)pageNum, (long)pageSize];
    
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
 新增退货
 
 @param orderItemId 订单商品项ID
 @param reason 退货原因
 @param remark 退货备注
 @param success 成功回调
 @param failure 失败回调
 */
+(void)cancelReturnGoodWithOrderItemId:(NSString *)orderItemId reason:(NSString *)reason remark:(NSString *)remark Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:orderItemId forKey:@"orderItemId"];
    [body setObject:reason forKey:@"returnGoodsReason"];
    [body setObject:remark forKey:@"remark"];
    
    NSString *url = [NSString stringWithFormat:@"%@returngoods",[JRNetEnvConfig sharedInstance].netEnvModel.order];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:body withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

/**
 取消退货单
 
 @param returnOrderId 退货订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)cancelReturnOrderWithReturnOrderId:(NSString *)returnOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *url = [NSString stringWithFormat:@"%@returngoods/cancel/%@",[JRNetEnvConfig sharedInstance].netEnvModel.order, returnOrderId];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
        
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
 获取订单详情
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getOrderDetailWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/%@", baseUrl, orderId];
    
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
 去支付
 
 @param orderId 订单id
 @param brandId 品牌id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)goPayWithOrderId:(NSString *)orderId brandId:(NSString *)brandId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@pay/goPay/%@/%@", baseUrl, orderId, brandId];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 确认收货
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getGoodsWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/receipt/%@", baseUrl, orderId];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 取消订单
 
 @param orderId 订单id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)cancelOrderWithOrderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/cancel/%@", baseUrl, orderId];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 购物车结算
 
 @param paramDic 要结算的购物车的信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)createOrderWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/createPendingOrderApp", baseUrl];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 查看结算订单基本信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getPendingOrderWithSuccess:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/getPendingOrder", baseUrl];
    
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
 提交订单
 
 @param paramDic 信息集合
 @param success 成功回调
 @param failure 失败回调
 */
+(void)placeOrderAppWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/place/order", baseUrl];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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


/*---------------------------------发票----------------------------------*/
/**
 设置发票信息
 
 @param paramDic 发票信息
 @param success 成功回调
 @param failure 失败回调
 */
+(void)setInvoiceWithParamDic:(NSDictionary*)paramDic Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@invoices/createInvoice", baseUrl];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:paramDic  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 获取发票信息
 
 @param orderId 发票id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getInvoiceWithInvoiceId:(NSString *)invoiceId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@invoices/getInvoice?invoiceId=%@", baseUrl, invoiceId];
    
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

#pragma mark - 退款退货服务

+ (void)retrieveReturnGoodsDetailWithId:(NSString *)returnGoodsId
                            withSuccess:(void(^)(NSDictionary *dict))success
                             andFailure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/%@", baseUrl, returnGoodsId];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)confirmReturnGoodsWithId:(NSString *)returngGoodsId
                     withSuccess:(void(^)(void))success
                      andFailure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/receipt/%@", baseUrl, returngGoodsId];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:manager andSuccess:^(NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:^(NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)getReturnGoodsApplyInfo:(NSString *)ordersId
                    withSuccess:(void(^)(NSDictionary *dict))success
                     andFailure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@orders/return/%@", baseUrl, ordersId];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:failure];
}

+ (void)createNewReturnGoodsWithInfo:(NSDictionary *)info
                         withSuccess:(void(^)(NSDictionary *dict))success
                          andFailure:(void(^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@returngoods/supportChooseQuantity", baseUrl];
    
    [SHHttpRequestManager Post:url withParameters:nil withHeader:[self getDefaultHeader] withBody:info withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 服务门店列表
 
 @param subOrderId 子订单Id
 @param pageSize 每页数据条数
 @param pageNum 第几页数据
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getStoreListWithSubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/listStore/%@", baseUrl, subOrderId];
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
 选择优惠券列表
 
 @param type 优惠券状态：1可用  2不可用
 @param subOrderId 子订单Id
 @param orderId 订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getSelectCouponsListWithType:(NSString *)type SubOrderId:(NSString *)subOrderId orderId:(NSString *)orderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure{
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@coupon/pendingCoupon?status=%@&pendingSubOrderId=%@&pendingOrderId=%@", baseUrl, type, subOrderId, orderId];
    //    NSString *url = [NSString stringWithFormat:@"http://52.80.80.57:8080/api/v1/coupon/pendingCoupon?status=%@&pendingSubOrderId=%@&pendingOrderId=%@", type, subOrderId, orderId];
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
 添加优惠券
 
 @param couponId 优惠券Id
 @param subOrderId 子订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)addPendingCouponWithCouponId:(NSString *)couponId SubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:couponId forKey:@"couponIds"];
    [body setObject:subOrderId forKey:@"subOrderId"];
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/addPendingCoupon?couponIds=%@&subOrderId=%@", baseUrl, couponId, subOrderId];
    //    NSString *url = [NSString stringWithFormat:@"http://52.80.80.57:8080/api/v1/pendingOrder/addPendingCoupon?couponIds=%@&subOrderId=%@", couponId, subOrderId];
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 取消优惠券
 
 @param couponId 优惠券Id
 @param subOrderId 子订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+(void)deletePendingCouponWithCouponId:(NSString *)couponId SubOrderId:(NSString *)subOrderId Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    [body setObject:couponId forKey:@"couponId"];
    [body setObject:subOrderId forKey:@"subOrderId"];
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/cancelPendingCoupon?couponId=%@&subOrderId=%@", baseUrl, couponId, subOrderId];
    //    NSString *url = [NSString stringWithFormat:@"http://52.80.80.57:8080/api/v1/pendingOrder/cancelPendingCoupon?couponIds=%@&subOrderId=%@", couponId, subOrderId];
    [SHHttpRequestManager Put:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

/**
 我的优惠券列表
 
 @param type 优惠券状态：1 未使用，2 已使用，3 已过期，4 已退回
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMyCouponsListWithType:(NSString *)type pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithDictionary:headerDict];
    //    [ddd setObject:@"121212" forKey:@"X-Member-Id"];
    
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [NSString stringWithFormat:@"%@coupon/selfCoupon?status=%@&offset=%ld&limit=%ld", baseUrl, type , (long)pageNum, (long)pageSize];
    //    NSString *url = [NSString stringWithFormat:@"http://52.80.80.57:8080/api/v1/coupon/selfCoupon?status=%@&offset=%ld&limit=%ld", type , (long)pageNum, (long)pageSize];
    [SHHttpRequestManager Get:url withParameters:nil withHeader:ddd withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 我的装修基金券列表
 
 @param type 1 返现记录，2 消费记录
 @param success 成功回调
 @param failure 失败回调
 */
+(void)getMyGoldListWithType:(NSString *)type pageSize:(NSInteger)pageSize pageNum:(NSInteger)pageNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    NSMutableDictionary *ddd = [NSMutableDictionary dictionaryWithDictionary:headerDict];
    //    [ddd setObject:@"12345" forKey:@"X-Member-Id"];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.promotion;
    NSString *url = [NSString stringWithFormat:@"%@cash/memberCashLogs?logType=%@&offset=%ld&limit=%ld&isFreeze=1", baseUrl, type , (long)pageNum, (long)pageSize];
    //    NSString *url = [NSString stringWithFormat:@"http://52.80.99.37:8080/api/v1/cash/memberCashLogs?logType=%@&offset=%ld&limit=%ld", type , (long)pageNum, (long)pageSize];
    [SHHttpRequestManager Get:url withParameters:nil withHeader:ddd withBody:nil  withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask *task, NSData *responseData) {
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
 使用装修基金
 
 @param orderId 订单Id
 @param goldNum 装修基金数量
 @param success 成功回调
 @param failure 失败回调
 */
+(void)useGoldWithOrderId:(NSString *)orderId goldNum:(NSString *)goldNum Success:(void (^)(NSDictionary * dict))success failure:(void(^)(NSError * error))failure {
    NSDictionary *headerDict = [self getDefaultHeader];
    AFHTTPSessionManager *manager = [ESHTTPSessionManager sharedInstance].manager;
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/usedDecorationFund?pendingOrderId=%@&fundAmount=%@", baseUrl, orderId, goldNum];
    //    NSString *url = [NSString stringWithFormat:@"http://ec2-54-223-123-229.cn-north-1.compute.amazonaws.com.cn:8080/api/v1/pendingOrder/usedDecorationFund?pendingOrderId=%@&fundAmount=%@", orderId, goldNum];
    [SHHttpRequestManager Post:url withParameters:nil withHeader:headerDict withBody:nil withAFTTPInstance:manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success) {
            success(dict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}



@end


