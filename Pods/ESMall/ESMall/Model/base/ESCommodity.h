//
//  ESCommodity.h
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESStockKeepingUnit.h"
#import "ESCartCommodityPromotion.h"

@interface ESCommodity : NSObject
@property (nonatomic, strong) NSString *itemId;                                 //商品id
@property (nonatomic, strong) NSString *itemQuantity;                           //商品数量
@property (nonatomic, strong) NSString *itemPrice;                              //商品单价
@property (nonatomic, strong) NSString *itemAmount;                             //商品计算优惠后的总价格
@property (nonatomic, strong) NSString *itemName;                               //商品名称
@property (nonatomic, strong) NSString *itemImg;                                //商品缩略图
@property (nonatomic, strong) NSMutableArray <ESStockKeepingUnit *> *skuList;   //SKU list
@property (nonatomic, strong) NSString *sku;
@property (nonatomic, retain) ESCartCommodityPromotion *promotion;

- (instancetype)initWithDict:(NSDictionary *)dict;

+ (instancetype)objFromDict:(NSDictionary *)dict;
@end
