//
//  ESCartBrand.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESCartBrand.h"

@implementation ESCartBrand

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.brandId        = [CoStringManager judgeNSString:dict forKey:@"brandId"];
        self.brandName      = [CoStringManager judgeNSString:dict forKey:@"brandName"];
        self.merchantId     = [CoStringManager judgeNSString:dict forKey:@"merchantId"];
        self.merchantName   = [CoStringManager judgeNSString:dict forKey:@"merchantName"];
        self.dispatchTime   = [CoStringManager judgeNSString:dict forKey:@"dispatchTime"];
        self.selected       = NO;
        
        [self initItems:dict];
    }
    return self;
}

/// 处理品牌下的商品信息和顺序
- (void)initItems:(NSDictionary *)dict
{
    if (![CoStringManager objectIsNull:dict forKey:@"items"] &&
        [[dict objectForKey:@"items"] isKindOfClass:[NSArray class]]) {
        
        NSMutableArray *commodityArrM = [NSMutableArray array];
        for (NSDictionary *dic in [dict objectForKey:@"items"])
        {
            [commodityArrM addObject:[ESCartCommodity objFromDict:dic]];
        }
        
        NSMutableDictionary *commodityDictM = [NSMutableDictionary dictionary];
        for (ESCartCommodity *cartCommodity in commodityArrM)
        {
            if ([cartCommodity isKindOfClass:[ESCartCommodity class]])
            {
                if (cartCommodity.promotion
                    && [cartCommodity.promotion isKindOfClass:[ESCartCommodityPromotion class]]
                    && [cartCommodity.promotion.tagId isKindOfClass:[NSString class]])
                {
                    if (commodityDictM[cartCommodity.promotion.tagId]
                        && [commodityDictM[cartCommodity.promotion.tagId] isKindOfClass:[NSMutableArray class]])
                    {
                        [commodityDictM[cartCommodity.promotion.tagId] addObject:cartCommodity];
                    }
                    else
                    {
                        NSMutableArray *arrM = [NSMutableArray array];
                        [arrM addObject:cartCommodity];
                        [commodityDictM setObject:arrM forKey:cartCommodity.promotion.tagId];
                    }
                }
                else if ([cartCommodity.cartItemId isKindOfClass:[NSString class]])
                {
                    if (commodityDictM[cartCommodity.cartItemId]
                        && [commodityDictM[cartCommodity.cartItemId] isKindOfClass:[NSMutableArray class]])
                    {
                        [commodityDictM[cartCommodity.cartItemId] addObject:cartCommodity];
                    }
                    else
                    {
                        NSMutableArray *arrM = [NSMutableArray array];
                        [arrM addObject:cartCommodity];
                        [commodityDictM setObject:arrM forKey:cartCommodity.cartItemId];
                    }
                }
            }
        }
        
        self.items = [NSMutableArray array];
        for (NSString *promotionId in [commodityDictM allKeys])
        {
            NSArray *arr = commodityDictM[promotionId];
            for (NSInteger i = 0; i < arr.count; i++)
            {
                ESCartCommodity *commodity = arr[i];
                if (i != arr.count - 1)
                {
                    commodity.promotion = nil;
                }
                [self.items addObject: commodity];
            }
        }
    }
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCartBrand alloc] initWithDict:dict];
}
@end
