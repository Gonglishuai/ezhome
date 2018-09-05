//
//  ESReturnApplyItemCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/14.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnApplyItemCellDelegate <NSObject>

/**
 获取商品选择状态

 @param index 索引
 @return 是否已选择
 */
- (BOOL)itemIsSelected:(NSInteger)index;

/**
 获取商品缩略图

 @param index 索引
 @return 缩略图url
 */
- (NSString *)getItemImage:(NSInteger)index;

/**
 获取商品名称

 @param index 索引
 @return 商品名称
 */
- (NSString *)getItemName:(NSInteger)index;

/**
 获取商品sku

 @param index 索引
 @return 所有sku
 */
- (NSString *)getItemSKUs:(NSInteger)index;

/**
 获取商品单价

 @param index 索引
 @return 单价
 */
- (NSString *)getItemPrice:(NSInteger)index;

/**
 获取商品数量

 @param index 索引
 @return 数量
 */
- (NSString *)getItemQuantity:(NSInteger)index;

/**
 选择一个商品

 @param select 是否选中
 @param index 索引
 */
- (void)selectItem:(BOOL)select withIndex:(NSInteger)index;

/**
 获取商品是否有效
 
 @param index 索引
 @return YES:有效
 */
- (BOOL)itemIsValidWithIndex:(NSInteger)index;

/**
 已付价格

 @param index 索引
 @return 已付价格
 */
- (NSString *)getItemOriginalPrice:(NSInteger)index;


/**
 是否可更改商品选择状态
 
 @return YES:可改变
 */
- (BOOL)itemSelectedStatusWithIndex:(NSInteger)index;

/**
 减按钮是否可点击

 @param index 索引
 @return YES:可点击
 */
- (BOOL)minusBtnCanSelectWithIndex:(NSInteger)index;

/**
 加按钮是否可点击
 
 @param index 索引
 @return YES:可点击
 */
- (BOOL)plusBtnCanSelectWithIndex:(NSInteger)index;

/**
 点击了减按钮

 @param index 索引
 */
- (void)minusBtnClickWithIndex:(NSInteger)index;

/**
 点击了加按钮

 @param index 索引
 */
- (void)plusBtnClickWithIndex:(NSInteger)index;

/**
 获取商品申请退款的数量

 @param index 索引
 @return 数量
 */
- (NSString *)getReturnApplyNum:(NSInteger)index;

/// 获取赠品状态
- (BOOL)getGiftStatusWithIndex:(NSInteger)index;

@end

@interface ESReturnApplyItemCell : UITableViewCell

@property (nonatomic, weak) id<ESReturnApplyItemCellDelegate> delegate;

- (void)updateReturnApplyCellWithIndex:(NSInteger)index;
@end
