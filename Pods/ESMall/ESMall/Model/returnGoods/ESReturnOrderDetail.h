//
//  ESReturnOrderDetail.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/12.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  退款详情订单详情

#import <Foundation/Foundation.h>
#import "ESReturnGoodsCommodity.h"
#import "ESReturnGoodsType.h"

typedef NS_ENUM(NSInteger, ESReturnType)
{
    ESReturnTypeGoodsUnknow = 0,
    ESReturnTypeGoodsAndMoney,
    ESReturnTypeMoney
};

@interface ESReturnOrderDetail : NSObject
@property (nonatomic, strong) NSString *orderId;                // 订单ID ,
@property (nonatomic, strong) NSString *brandName;              // 品牌名称 ,
@property (nonatomic, strong) NSString *returnAmount;           // 申请退款金额 ,
@property (nonatomic, strong) NSString *realityReturnAmount;    // 实际退款金额 ,
@property (nonatomic, strong) NSString *returnReason;           // 退货原因 ,
@property (nonatomic, strong) NSString *deductioAmount;         // 调价金额 ,
@property (nonatomic, assign) ESReturnGoodsType processStatus;  // 退货状态 10订单进行中 20 订单已取消 30 订单已完成 40 用户确认收款 50商家拒绝,
@property (nonatomic, strong) NSString *remark;                 // 备注 ,
@property (nonatomic, strong) NSString *createTime;             // 退货时间 ,
@property (nonatomic, strong) NSString *contactMobile;          // 联系商家电话 ,
@property (nonatomic, strong) NSString *refuseReason;           // 审核拒绝原因
@property (nonatomic, strong) NSMutableArray <ESReturnGoodsCommodity *> *detailList; //退款商品
@property (nonatomic, strong) NSString *storeName;              // 服务门店
@property (nonatomic, assign) ESReturnType returnType;              // 退款方式

@property (nonatomic, strong) NSString *consumerName;                 // 客户昵称 ,
@property (nonatomic, strong) NSString *consumerAvatar;             // 客户头像 ,
@property (nonatomic, strong) NSString *consumerMobile;          // 客户电话 ,

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
