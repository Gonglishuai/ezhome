//
//  ESReturnGoodsOrderInfoCell.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESReturnGoodsOrderInfoCellDelegate <NSObject>

/**
 获取退款订单号

 @return 订单号
 */
- (NSString *)getOrderNo;

/**
 获取申请时间

 @return 时间
 */
- (NSString *)getOrderCreateTime;

/**
 获取申请退款金额

 @return 金额
 */
- (NSString *)getOrderReturnAmount;

/**
 获取退款原因

 @return 原因
 */
- (NSString *)getOrderReturnReason;

/**
 获取服务门店

 @return 门店
 */
- (NSString *)getServiceStore;

@end

@interface ESReturnGoodsOrderInfoCell : UITableViewCell

@property (nonatomic, weak) id<ESReturnGoodsOrderInfoCellDelegate> delegate;

- (void)updateOrderInfoCell;
@end
