//
//  ESReturnGoodsCommodity.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  退货商品

#import "ESCommodity.h"
#import "ESReturnGoodsType.h"

@interface ESReturnGoodsCommodity : ESCommodity
@property (nonatomic, strong) NSString *returnAmount;       // 退款金额
@property (nonatomic, strong) NSString *returnGoodsId;      // 退货ID
@property (nonatomic, strong) NSString *orderItemId;        // 子订单ID
@property (nonatomic, strong) NSString *payAmount;          // 实际支付金额
@property (nonatomic, assign) ESReturnCommodityStatus returnGoodsStatus; //退货状态
@property (nonatomic, assign) BOOL isSelected;              // 是否已选择
@property (nonatomic, strong) NSString *returnedQuantity;   // 已退的商品数量
@property (nonatomic, strong) NSString *editReturnItemNum;  // 当前要退货的数量

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
