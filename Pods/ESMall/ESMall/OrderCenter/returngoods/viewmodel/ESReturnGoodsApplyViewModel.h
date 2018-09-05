//
//  ESReturnGoodsApplyViewModel.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESReturnApplyOrderInfo.h"

@interface ESReturnGoodsApplyViewModel : NSObject

/**
 获取申请退货订单信息

 @param orderId 订单Id
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)retrieveRefundOrderInfoWithOrderId:(NSString *)orderId
                               withSuccess:(void(^)(ESReturnApplyOrderInfo *orderInfo))success
                                andFailure:(void(^)(void))failure;

/**
 新增退货单

 @param orderInfo 订单信息
 @param success 成功回调
 @param failure 失败回调
 */
+ (void)createNewReturnGoods:(ESReturnApplyOrderInfo *)orderInfo
                 withSuccess:(void(^)(NSString *returnGoodsId))success
                  inProgress:(void(^)(void))progress
                  andFailure:(void(^)(NSString *errorMsg, NSInteger index))failure;

/**
 获取每组条数
 
 @param section 组索引
 @param orderInfo 订单信息
 @return item数
 */
+ (NSInteger)getItemsNumsWithSection:(NSInteger)section
                           withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商家联系电话

 @param orderInfo 订单信息
 @return 联系电话
 */
+ (NSString *)getContactNumberWithOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 是否全选

 @param orderInfo 订单信息
 @return YES:全选
 */
+ (BOOL)itemsIsSelectedAllWithOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取总退款金额

 @param orderInfo 订单信息
 @return 退款金额
 */
+ (NSString *)getTotoalPriceWithOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 选择全部

 @param selectAll 全选/全不选
 @param orderInfo 订单信息
 */
+ (void)selectAllItems:(BOOL)selectAll withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 商品是否已选择

 @param index 索引
 @param orderInfo 订单信息
 @return YES:商品已选择
 */
+ (BOOL)itemIsSelectedWithIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品缩略图

 @param index 索引
 @param orderInfo 订单信息
 @return 缩略图
 */
+ (NSString *)getItemImage:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品名称

 @param index 索引
 @param orderInfo 订单信息
 @return 名称
 */
+ (NSString *)getItemName:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品SKU

 @param index 索引
 @param orderInfo 订单信息
 @return sku
 */
+ (NSString *)getItemSKUs:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品价格

 @param index 索引
 @param orderInfo 订单信息
 @return 商品单价
 */
+ (NSString *)getItemPrice:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品数量

 @param index 索引
 @param orderInfo 订单信息
 @return 商品数量
 */
+ (NSString *)getItemQuantity:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 选择一个商品

 @param select 是否选择
 @param index 索引
 @param orderInfo 订单信息
 */
+ (void)selectItem:(BOOL)select withIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取商品是否可选

 @param index 索引
 @param orderInfo 订单信息
 @return YES:可选
 */
+ (BOOL)itemIsValidWithIndex:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取输入项标题

 @param index 索引
 @return 标题
 */
+ (NSString *)getInputTitle:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取输入项内容

 @param index 索引
 @param orderInfo 订单信息
 @return 内容
 */
+ (NSString *)getInputContent:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取输入项的提示文字

 @param index 索引
 @return 提示文字
 */
+ (NSString *)getInputPlaceHolder:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 完成输入后赋值操作

 @param content 输入的内容
 @param index 索引
 @param orderInfo 订单信息
 */
+ (void)setInputContent:(NSString *)content
              withIndex:(NSInteger)index
              withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 是否有可选的商品

 @param orderInfo 订单信息
 @return YES:有可选商品
 */
+ (BOOL)hasSelectedItemWithOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取申请退款金额描述

 @return 描述
 */
+ (NSString *)getReturnGoodsDescription;

/**
 获取已付价格

 @param index 索引
 @param orderInfo 订单信息
 @return 已付价格
 */
+ (NSString *)getItemOriginalPrice:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 是否是部分支付

 @param orderInfo 订单信息
 @return YES:为部分支付
 */
+ (BOOL)isInstalmentWithOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 商品是否可减

 @param index 索引
 @param orderInfo 订单详情
 @return YES:可减
 */
+ (BOOL)itemCouldMinus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 商品是否可加

 @param index 索引
 @param orderInfo 订单信息
 @return YES:可加
 */
+ (BOOL)itemCouldPlus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 减商品

 @param index 索引
 @param orderInfo 订单信息
 */
+ (void)itemMinus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 加商品

 @param index 索引
 @param orderInfo 订单信息
 */
+ (void)itemPlus:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/**
 获取要申请退款的商品数量

 @param index 索引
 @param orderInfo 订单信息
 @return 数量
 */
+ (NSString *)getReturnApplyItemNum:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

/// 是否赠品
+ (BOOL)getReturnApplyItemGiftStatusNum:(NSInteger)index withOrder:(ESReturnApplyOrderInfo *)orderInfo;

@end
