//
//  ESCartBrand.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//
//  购物车 品牌

#import <Foundation/Foundation.h>
#import "ESCartCommodity.h"

@interface ESCartBrand : NSObject
@property (nonatomic, strong) NSString *brandId;                            //品牌id
@property (nonatomic, strong) NSString *brandName;                          //品牌名称
@property (nonatomic, strong) NSString *merchantId;                         //厂商id
@property (nonatomic, strong) NSString *merchantName;                       //厂商名称
@property (nonatomic, strong) NSString *dispatchTime;                       //
@property (nonatomic, assign) BOOL selected;                                //品牌是否为选择状态
@property (nonatomic, strong) NSMutableArray <ESCartCommodity *> *items;    //品牌下的商品

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
