//
//  ESShoppingCartAPI.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/6.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESMaterialBaseAPI.h"

@interface ESShoppingCartAPI : ESMaterialBaseAPI

/**
 获取购物车信息
 
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)getShoppingCartInfoWithSuccess:(void(^)(NSDictionary *dict))success
                            andFailure:(void(^)(NSError *error))failure;

/**
 更新购物车商品属性
 
 @param cartItemId 需要更新的商品ID
 @param newSkuId 新skuID
 @param itemQuantity 数量
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)updateCartItemWithId:(NSString *)cartItemId
                    newSkuId:(NSString *)newSkuId
                itemQuantity:(NSInteger)itemQuantity
                 withSuccess:(void(^)(NSDictionary *dict))success
                  andFailure:(void(^)(NSError *error))failure;

/**
 删除购物车中的商品
 
 @param cartItems 要删除的商品ids
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)deleteCartItems:(NSString *)cartItems
            withSuccess:(void(^)(void))success
             andFailure:(void(^)(NSError *error))failure;

/**
 * @brief 请求秒杀商品详情的数据
 *
 * @param productId 商品ID
 * @param flashSaleItemId Item ID
 * @param activityId 活动ID
 * @param success 成功回调
 * @param failure 失败回调
 *
 */
+ (void)requestForProductDetailWithID:(NSString *)productId
                                 type:(NSString *)type
                      flashSaleItemId:(NSString *)flashSaleItemId
                           activityId:(NSString *)activityId
                              success:(void (^) (NSDictionary *dict))success
                              failure:(void (^) (NSError *error))failure;

/**
 生成结算订单
 
 @param cartItemIds 商品购物车唯一标识
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)createPendingOrderSuccess:(void(^)(NSDictionary *dict))success
                       andFailure:(void(^)(NSError *error))failure;

/**
 * @brief 添加购物车
 *
 * @param skuId skuID
 * @param itemQuantity 数量
 * @param designerId 设计师id(选填)
 * @param success 成功回调
 * @param failure 失败回调
 *
 */
+ (void)addCartItemWithSkuId:(NSString *)skuId
                itemQuantity:(NSInteger)itemQuantity
                  designerId:(NSString *)designerId
                     success:(void (^) (NSDictionary *dict))success
                     failure:(void (^) (NSError *error))failure;

/**
 * 登陆后同步未登录时购物车信息
 *
 * @param success 成功回调
 * @param failure 失败回调
 */
+ (void)updateCartItemForMemberWithSuccess:(void(^)(void))success
                                   failure:(void (^) (NSError *error))failure;

/**
 * @brief 立即定制
 *
 * @param skuId skuID
 * @param itemQuantity 数量
 * @param success 成功回调
 * @param failure 失败回调
 *
 */
+ (void)addCustomItemWithSkuId:(NSString *)skuId
                  itemQuantity:(NSInteger)itemQuantity
                       success:(void (^) (NSDictionary *dict))success
                       failure:(void (^) (NSError *error))failure;

/**
 * @brief 立即购买
 *
 * @param skuId skuID
 * @param itemQuantity 数量
 * @param success 成功回调
 * @param failure 失败回调
 *
 */
+ (void)buyItemWithSkuId:(NSString *)skuId
            itemQuantity:(NSInteger)itemQuantity
                 success:(void (^) (NSDictionary *dict))success
                 failure:(void (^) (NSError *error))failure;

/**
 活动购买, 包括抢购和定金膨胀,及以后其他活动, 根据activityType区分
 
 @param body 信息体
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)activityBuyWithBody:(NSDictionary *)body
                    success:(void (^) (NSDictionary *dict))success
                    failure:(void (^) (NSError *error))failure;


/// 获取属性
+ (void)getSpuAttributesWithId:(NSString *)spuId
                       success:(void (^) (NSDictionary *dict))success
                       failure:(void (^) (NSError *error))failure;


// 旧抢购
+ (void)requestForCreateFlashSaleWithBody:(NSDictionary *)body
                                  success:(void (^) (NSDictionary *dict))success
                                  failure:(void (^) (NSError *error))failure;

/// 选中item
+ (void)selectedItemWithCartItemIds:(NSString *)cartItemIds
                            success:(void(^)(NSDictionary *dict))success
                            failure:(void(^)(NSError *error))failure;

/// 取消选中item
+ (void)unselectedItemWithCartItemIds:(NSString *)cartItemIds
                            success:(void(^)(NSDictionary *dict))success
                            failure:(void(^)(NSError *error))failure;

@end

