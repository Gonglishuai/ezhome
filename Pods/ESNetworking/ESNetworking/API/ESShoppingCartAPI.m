//
//  ESShoppingCartAPI.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/6.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESShoppingCartAPI.h"
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"
@interface ESShoppingCartAPI()

@end

@implementation ESShoppingCartAPI

+ (void)getShoppingCartInfoWithSuccess:(void(^)(NSDictionary *dict))success
                            andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/getCartItems", baseUrl];
    
    [SHHttpRequestManager Get:url withParameters:nil withHeaderField:[self getDefaultHeader] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        
        if (success) {
            success(returnDict);
        }
    } andFailure:failure];
}

+ (void)updateCartItemWithId:(NSString *)cartItemId
                    newSkuId:(NSString *)newSkuId
                itemQuantity:(NSInteger)itemQuantity
                 withSuccess:(void(^)(NSDictionary *dict))success
                  andFailure:(void(^)(NSError *error))failure
{
    if (!cartItemId
        || !newSkuId)
    {
        if (failure)
        {
            failure(ERROR(@"111", 999, @"itemId或skuId有误"));
        }
        return;
    }
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/updateCartItemForSku", baseUrl];
    NSDictionary *body = @{@"cartItemBeans": @[
                                   @{
                                       @"cartItemId": cartItemId,
                                       @"itemQuantity": @(itemQuantity),
                                       @"sku": newSkuId
                                       }
                                   ]};
    
    [SHHttpRequestManager Put:url
               withParameters:nil
                   withHeader:[self getDefaultHeader]
                     withBody:body
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
     {
         NSDictionary *returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
         if ([returnDict isKindOfClass:[NSDictionary class]])
         {
             if (success)
             {
                 success(returnDict);
             }
         }
         else
         {
             if (failure)
             {
                 failure(ERROR(@"0", 999, @"response格式不正确"));
             }
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
         if (failure)
         {
             failure(error);
         }
     }];
}



+ (void)deleteCartItems:(NSString *)cartItems
            withSuccess:(void(^)(void))success
             andFailure:(void(^)(NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/deleteCartItem", baseUrl];
    
    NSDictionary *param = @{@"cartItemIds" : cartItems};
    [SHHttpRequestManager Delete:url withParameters:param withHeaderField:[self getDefaultHeader] withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:failure];
}

+ (void)requestForProductDetailWithID:(NSString *)productId
                                 type:(NSString *)type
                      flashSaleItemId:(NSString *)flashSaleItemId
                           activityId:(NSString *)activityId
                              success:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSError *error))failure
{
    if (!productId
        || ![productId isKindOfClass:[NSString class]]
        || !type
        || ![type isKindOfClass:[NSString class]])
    {
        if (failure)
        {
            failure(ERROR(@"商品详情", -1000, @"商品ID或者type有问题"));
        }
        return;
    }
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = nil;
    if (activityId
        && [activityId isKindOfClass:[NSString class]]
        && activityId.length > 0)
    {
        url =  [NSString stringWithFormat:
                @"%@product/detail/%@?searchType=%@&flashSaleItemId=%@&activityId=%@",
                baseUrl,
                productId,
                type,
                flashSaleItemId,
                activityId];
    }
    else
    {
        url =  [NSString stringWithFormat:
                @"%@product/detail/%@?searchType=%@",
                baseUrl,
                productId,
                type];
    }
    
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)createPendingOrderSuccess:(void(^)(NSDictionary *dict))success
                       andFailure:(void(^)(NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@pendingOrder/addPendingOrder", baseUrl];
    
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:[self getDefaultHeader]
                      withBody:nil
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
    {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                    options:NSJSONReadingMutableContainers
                                                                      error:nil];
        if (success) {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

+ (void)addCartItemWithSkuId:(NSString *)skuId
                itemQuantity:(NSInteger)itemQuantity
                  designerId:(NSString *)designerId
                     success:(void (^) (NSDictionary *dict))success
                     failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url = [baseUrl stringByAppendingString:@"cartItem/addCartItem"];
    if (!skuId
        || ![skuId isKindOfClass:[NSString class]]
        || skuId.length <= 0)
    {
        if (failure)
        {
            failure(ERROR(@"添加购物车", -1000, @"添加购物车SKUID有问题"));
        }
        return;
    }
    
    if (!designerId
        || ![designerId isKindOfClass:[NSString class]])
    {
        designerId = @"0";
    }
    
    NSDictionary *body = @{
                           @"designerId": designerId,
                           @"itemQuantity": @(itemQuantity),
                           @"sku": skuId
                           };
    
    [SHHttpRequestManager Post:url
                withParameters:body
               withHeaderField:[self getDefaultHeader]
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success) {
             success(returnDict);
         }
     } andFailure:failure];
}

/**
 * 登陆后同步未登录时购物车信息
 *
 * @param success 成功回调
 * @param failure 失败回调
 */
+ (void)updateCartItemForMemberWithSuccess:(void(^)(void))success
                                   failure:(void (^) (NSError *error))failure {
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/updateItemForMember", baseUrl];
    
    [SHHttpRequestManager Put:url withParameters:nil withHeader:[self getDefaultHeader] withBody:nil withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData) {
        if (success) {
            success();
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
        if (failure) {
            failure(error);
        }
    }];
}

//+ (void)getJMemberIdSuccess:(void(^)(NSString *))success
//                    failure:(void (^) (NSError *error))failure
//{
//    NSString *url = [@"http://ec2-54-223-20-197.cn-north-1.compute.amazonaws.com.cn:8080/api/v1/memberId/umsMemberId/e" stringByAppendingString:[JRKeychain loadSingleUserInfo:UserInfoCodeHsUid]];
//    [SHHttpRequestManager Get:url
//               withParameters:nil
//              withHeaderField:nil
//            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
//                   andSuccess:^(NSData * _Nullable responseData)
//     {
//
//         if (success)
//         {
//             success([[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
//         }
//     } andFailure:failure];
//}

+ (void)addCustomItemWithSkuId:(NSString *)skuId
                  itemQuantity:(NSInteger)itemQuantity
                       success:(void (^) (NSDictionary *dict))success
                       failure:(void (^) (NSError *error))failure
{
    if (!skuId
        || ![skuId isKindOfClass:[NSString class]]
        || skuId.length <= 0)
    {
        if (failure)
        {
            failure(ERROR(@"立即定制", -1000, @"立即定制SKUID有问题"));
        }
        return;
    }
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [baseUrl stringByAppendingString:@"pendingOrder/addCustom"];
    url = [NSString stringWithFormat:@"%@?sku=%@&itemQuantity=%ld", url, skuId, (long)itemQuantity];
    [SHHttpRequestManager Post:url
                withParameters:nil
               withHeaderField:[self getDefaultHeader]
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success) {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)buyItemWithSkuId:(NSString *)skuId
            itemQuantity:(NSInteger)itemQuantity
                 success:(void (^) (NSDictionary *dict))success
                 failure:(void (^) (NSError *error))failure
{
    if (!skuId
        || ![skuId isKindOfClass:[NSString class]]
        || skuId.length <= 0)
    {
        if (failure)
        {
            failure(ERROR(@"立即购买", -1000, @"立即购买SKUID有问题"));
        }
        return;
    }
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [baseUrl stringByAppendingString:@"pendingOrder/addGeneral"];
    url = [NSString stringWithFormat:@"%@?sku=%@&itemQuantity=%ld", url, skuId, (long)itemQuantity];
    [SHHttpRequestManager Post:url
                withParameters:nil
               withHeaderField:[self getDefaultHeader]
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success) {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)activityBuyWithBody:(NSDictionary *)body
                    success:(void (^) (NSDictionary *dict))success
                    failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.marketing;
    NSString *url = [baseUrl stringByAppendingString:@"itemTag/addGeneralForActivity"];
    
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:[self getDefaultHeader]
                      withBody:body
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                 NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
         
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
         
         if (failure)
         {
             failure(error);
         }
         
     }];
}

+ (void)getSpuAttributesWithId:(NSString *)spuId
                       success:(void (^) (NSDictionary *dict))success
                       failure:(void (^) (NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.gatewayServer;
    NSString *url =  [NSString stringWithFormat:
                      @"%@product/productInfo/%@",
                      baseUrl,
                      spuId];
    
    [SHHttpRequestManager Get:url
               withParameters:nil
              withHeaderField:[self getDefaultHeader]
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:failure];
}

+ (void)requestForCreateFlashSaleWithBody:(NSDictionary *)body
                                  success:(void (^) (NSDictionary *dict))success
                                  failure:(void (^) (NSError *error))failure {
    
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.marketing;
    NSString *url = [baseUrl stringByAppendingString:@"flashSale"];
    [SHHttpRequestManager Post:url
                withParameters:nil
                    withHeader:[self getDefaultHeader]
                      withBody:body
             withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                    andSuccess:^(NSURLSessionDataTask * _Nonnull task,
                                 NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData
                                                                     options:NSJSONReadingMutableContainers
                                                                       error:nil];
         if (success)
         {
             success(returnDict);
         }
         
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) {
         
         if (failure)
         {
             failure(error);
         }
         
     }];
}

/// 选中item
+ (void)selectedItemWithCartItemIds:(NSString *)cartItemIds
                            success:(void(^)(NSDictionary *dict))success
                            failure:(void(^)(NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/select?cartItemIds=%@", baseUrl, cartItemIds];
    [SHHttpRequestManager Put:url
               withParameters:nil
                   withHeader:[self getDefaultHeader]
                     withBody:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
    {
        NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if (success)
        {
            success(returnDict);
        }
    } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error) 
    {
        if (failure) {
            failure(error);
        }
    }];
}

/// 取消选中item
+ (void)unselectedItemWithCartItemIds:(NSString *)cartItemIds
                              success:(void(^)(NSDictionary *dict))success
                              failure:(void(^)(NSError *error))failure
{
    NSString *baseUrl = [JRNetEnvConfig sharedInstance].netEnvModel.order;
    NSString *url = [NSString stringWithFormat:@"%@cartItem/cancel?cartItemIds=%@", baseUrl, cartItemIds];
    
    [SHHttpRequestManager Put:url
               withParameters:nil
                   withHeader:[self getDefaultHeader]
                     withBody:nil
            withAFTTPInstance:[ESHTTPSessionManager sharedInstance].manager
                   andSuccess:^(NSURLSessionDataTask * _Nonnull task, NSData * _Nullable responseData)
     {
         NSDictionary * returnDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
         if (success)
         {
             success(returnDict);
         }
     } andFailure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nullable error)
     {
         if (failure) {
             failure(error);
         }
     }];
}

@end

