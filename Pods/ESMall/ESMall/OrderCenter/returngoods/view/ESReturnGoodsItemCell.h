//
//  ESReturnGoodsItemCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnGoodsItemCellDelegate <NSObject>

/**
 获取退货商品缩略图

 @param index 索引
 @return 缩略图
 */
- (NSString *)getItemImage:(NSInteger)index;

/**
 获取退货商品名称

 @param index 索引
 @return 名称
 */
- (NSString *)getItemName:(NSInteger)index;

/**
 获取退货商品单价

 @param index 索引
 @return 单价
 */
- (NSString *)getItemPrice:(NSInteger)index;

/**
 获取退货商品数量

 @param index 索引
 @return 数量
 */
- (NSString *)getItemQuantity:(NSInteger)index;

/**
 获取退货商品SKU

 @param index 索引
 @return SKU字符串
 */
- (NSString *)getItemSKU:(NSInteger)index;

/**
 获取退货商品退款金额

 @param index 索引
 @return 退款金额
 */
- (NSString *)getReturnAmount:(NSInteger)index;
@end

@interface ESReturnGoodsItemCell : UITableViewCell

@property (nonatomic, weak) id<ESReturnGoodsItemCellDelegate> delegate;

- (void)updateItemCell:(NSInteger)index;
@end
