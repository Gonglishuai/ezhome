//
//  ESShoppingCartCellProtocol.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/5.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#ifndef ESShoppingCartCellProtocol_h
#define ESShoppingCartCellProtocol_h


#endif /* ESShoppingCartCellProtocol_h */

#import "ESShoppingCartViewModel.h"

@protocol ESShoppingCartCellDelegate <NSObject>

/// 展示文本
- (void)showMessage:(NSString *)message;

/// 修改属性
- (void)changeSkuAttribute:(NSInteger)section
                  andIndex:(NSInteger)index;

/**
 获取当前item商品状态
 
 @param section 组索引
 @param index item索引
 @return 类型
 */
- (ESCommodityType)getCommodityTyep:(NSInteger)section
                           andIndex:(NSInteger)index;

/**
 是否是选中状态
 
 @param section 组索引
 @param index item索引
 @return YES:为选中状态
 */
- (BOOL)isSelected:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品图片
 
 @param section 组索引
 @param index item索引
 @return 图片url
 */
- (NSString *)getItemImage:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品名称
 
 @param section 组索引
 @param index item索引
 @return 名称
 */
- (NSString *)getItemName:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品SKU
 
 @param section 组索引
 @param index item索引
 @return sku
 */
- (NSString *)getItemSKU:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品单价
 
 @param section 组索引
 @param index item索引
 @return 单价
 */
- (double)getItemPrice:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品数量
 
 @param section 组索引
 @param index item索引
 @return 数量
 */
- (NSInteger)getItemAmount:(NSInteger)section andIndex:(NSInteger)index;

/**
 选中一个条目

 @param section 组索引
 @param index item索引
 */
- (void)selectItemWithSection:(NSInteger)section andIndex:(NSInteger)index callBack:(void(^)(BOOL successStatus))callback;

/**
 删除商品
 
 @param section 组索引
 @param index item索引
 */
- (void)deleteItemWithSection:(NSInteger)section andIndex:(NSInteger)index;

/**
 更新商品

 @param section 组索引
 @param index item索引
 */
- (void)updateItemCount:(NSInteger)count
            withSection:(NSInteger)section
               andIndex:(NSInteger)index
               callback:(void(^)(BOOL successStatus))callback;

/**
 获取商品最小数

 @param section 组索引
 @param index item索引
 @return 下限
 */
- (NSInteger)getMinAmountWithSection:(NSInteger)section andIndex:(NSInteger)index;

/**
 获取商品最大数
 
 @param section 组索引
 @param index item索引
 @return 上限
 */
- (NSInteger)getMaxAmountWithSection:(NSInteger)section andIndex:(NSInteger)index;

/// 获取促销信息
- (ESCartCommodityPromotion *)getPromotionInfoWithSection:(NSInteger)section andIndex:(NSInteger)index;

/// 促销信息被点击
- (void)promotionDidTappedWithSection:(NSInteger)section andIndex:(NSInteger)index;

@end
