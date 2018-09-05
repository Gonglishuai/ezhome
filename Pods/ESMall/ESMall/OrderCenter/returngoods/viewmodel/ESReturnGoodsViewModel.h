//
//  ESReturnGoodsViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESReturnOrderDetail.h"

@interface ESReturnGoodsViewModel : NSObject


/**
 获取退款详情

 @param returnGoodsId 退货单id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveReturnGoodsDetailWithId:(NSString *)returnGoodsId
                            withSuccess:(void(^)(ESReturnOrderDetail *order))success
                             andFailure:(void(^)(void))failure;

/**
 获取商品数量

 @param order 订单详情
 @return 数量
 */
+ (NSInteger)getCommodityNumsWithOrder:(ESReturnOrderDetail *)order;

/**
 获取订单状态

 @param order 订单
 @return 类型
 */
+ (ESReturnGoodsType)getOrderTypeWithOrder:(ESReturnOrderDetail *)order;

/**
 获取联系电话

 @param order 订单
 @return 电话
 */
+ (NSString *)getContactNumberWithOrder:(ESReturnOrderDetail *)order;

/**
 获取品牌名称

 @param order 订单
 @return 品牌名
 */
+ (NSString *)getBrandName:(ESReturnOrderDetail *)order;

/**
 获取状态栏背景图

 @param order 订单
 @return 背景图
 */
+ (NSString *)getOrderStatusBackImg:(ESReturnOrderDetail *)order;

/**
 获取状态栏title

 @param order 订单
 @return title
 */
+ (NSString *)getOrderStatusTitle:(ESReturnOrderDetail *)order;

/**
 获取退款拒绝原因

 @param order 订单
 @return 拒绝原因
 */
+ (NSString *)getOrderRefuseReason:(ESReturnOrderDetail *)order;

/**
 获取显示金额的title

 @param order 订单
 @return title
 */
+ (NSString *)getReturnPriceTitle:(ESReturnOrderDetail *)order;

/**
 获取显示相对应的金额

 @param order 订单
 @return 金额
 */
+ (NSString *)getReturnPrice:(ESReturnOrderDetail *)order;

/**
 获取退货商品缩略图
 
 @param index 索引
 @param order 订单
 @return 缩略图
 */
+ (NSString *)getItemImage:(NSInteger)index
                 withOrder:(ESReturnOrderDetail *)order;

/**
 获取退货商品名称
 
 @param index 索引
 @param order 订单
 @return 名称
 */
+ (NSString *)getItemName:(NSInteger)index
                withOrder:(ESReturnOrderDetail *)order;

/**
 获取退货商品单价
 
 @param index 索引 
 @param order 订单
 @return 单价
 */
+ (NSString *)getItemPrice:(NSInteger)index
                 withOrder:(ESReturnOrderDetail *)order;

/**
 获取退货商品数量
 
 @param index 索引
 @param order 订单
 @return 数量
 */
+ (NSString *)getItemQuantity:(NSInteger)index
                    withOrder:(ESReturnOrderDetail *)order;

/**
 获取退货商品SKU
 
 @param index 索引
 @param order 订单
 @return SKU字符串
 */
+ (NSString *)getItemSKU:(NSInteger)index
               withOrder:(ESReturnOrderDetail *)order;

/**
 获取退货商品退款金额
 
 @param index 索引
 @param order 订单
 @return 退款金额
 */
+ (NSString *)getReturnAmount:(NSInteger)index
                    withOrder:(ESReturnOrderDetail *)order;

/**
 获取退款订单号
 
 @param order 订单
 @return 订单号
 */
+ (NSString *)getOrderNoWithOrder:(ESReturnOrderDetail *)order;

/**
 获取申请时间
 
 @param order 订单
 @return 时间
 */
+ (NSString *)getOrderCreateTimeWithOrder:(ESReturnOrderDetail *)order;

/**
 获取申请退款金额
 
 @param order 订单
 @return 金额
 */
+ (NSString *)getOrderReturnAmountWithOrder:(ESReturnOrderDetail *)order;

/**
 获取退款原因
 
 @param order 订单
 @return 原因
 */
+ (NSString *)getOrderReturnReasonWithOrder:(ESReturnOrderDetail *)order;

/**
 确认退款成功

 @param orderId 订单
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)confirmReturnGoodsWithOrderId:(NSString *)orderId
                          withSuccess:(void(^)(void))success
                           andFailure:(void(^)(void))failure;

/**
 获取服务门店

 @param order 订单
 @return 门店
 */
+ (NSString *)getOrderServiceStoreWithOrder:(ESReturnOrderDetail *)order;
@end
