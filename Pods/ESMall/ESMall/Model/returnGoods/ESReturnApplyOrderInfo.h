//
//  ESReturnApplyOrderInfo.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/13.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  申请退货单订单详情

#import <Foundation/Foundation.h>
#import "ESReturnGoodsCommodity.h"

typedef NS_ENUM(NSInteger, ESReturnAmountType)
{
    ESReturnAmountTypeGoodsAndMoney,
    ESReturnAmountTypeMoney,
};

@interface ESReturnApplyOrderInfo : NSObject
@property (nonatomic, strong) NSString *ordersId;       // 订单ID
@property (nonatomic, strong) NSString *name;           // 姓名
@property (nonatomic, strong) NSString *mobile;         // 联系人电话
@property (nonatomic, strong) NSString *merchantMobile; // 联系商家电话
@property (nonatomic, strong) NSMutableArray <ESReturnGoodsCommodity *>* itemList; //要申请退货的商品
@property (nonatomic, strong) NSString *orderType;       // 0定制1普通
@property (nonatomic, strong) NSString *orderStatus;       //订单状态
@property (nonatomic, strong) NSString *returnGoodsReason; // 退款退货原因
@property (nonatomic, strong) NSString *returnMoney; // 退款金额
@property (nonatomic, strong) NSString *remark;         // 备注

/// 退款方式
@property (nonatomic, assign) ESReturnAmountType returnWay;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
