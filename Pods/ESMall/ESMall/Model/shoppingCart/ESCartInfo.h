//
//  ESCartInfo.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  购物车 信息

#import <Foundation/Foundation.h>
#import "ESCartBrand.h"

@interface ESCartInfo : NSObject
@property (nonatomic, assign) NSInteger itemQuantity;                     //商品项数量
@property (nonatomic, assign) float discountAmount;                       //优惠金额
@property (nonatomic, assign) float orderAmount;                          //订单价格
@property (nonatomic, assign) float realAmount;                          //订单价格
@property (nonatomic, strong) NSMutableArray <ESCartBrand *> *cartItems;  //购物车商品项

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
