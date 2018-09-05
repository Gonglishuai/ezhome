//
//  ESCartCommodity.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  购物车 商品

#import "ESCommodity.h"
#import "CoStringManager.h"

typedef NS_ENUM(NSUInteger, ESCommodityStatus) {
    ESCommodityStatusNone,
    ESCommodityStatusValid,   //商品有效
    ESCommodityStatusInvalid, //商品无效
};

typedef NS_ENUM(NSUInteger, ESCommodityChooseStatus) {
    ESCommodityChooseStatusNone,
    ESCommodityChooseStatusSelected, //商品选中状态
    ESCommodityChooseStatusCancel,   //商品未选中状态
};

@interface ESCartCommodity : ESCommodity
@property (nonatomic, strong) NSString *cartItemId;                             //商品在购物车的唯一标识
@property (nonatomic, strong) NSString *originQuantity;                         //原数量
@property (nonatomic, strong) NSString *regionId;                               //区域id
@property (nonatomic, assign) ESCommodityStatus status;                         //商品状态
@property (nonatomic, assign) ESCommodityChooseStatus chooseStatus;             //商品选择状态
@property (nonatomic, assign) ESCommodityChooseStatus originChooseStatus;             //商品选择状态
@property (nonatomic, strong) NSString *createTime;                             //创建时间

+ (instancetype)objFromDict:(NSDictionary *)dict;

+ (NSDictionary *)dictFromObj:(ESCartCommodity *)object;
@end
