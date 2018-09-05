//
//  ESCartInfo.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESCartInfo.h"

@implementation ESCartInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        
        self.itemQuantity   = [CoStringManager judgeNSInteger:dict forKey:@"itemQuantity"];
        self.discountAmount = [CoStringManager judgeFloat:dict forKey:@"discountAmount"];
        self.orderAmount    = [CoStringManager judgeFloat:dict forKey:@"orderAmount"];
        self.realAmount    = [CoStringManager judgeFloat:dict forKey:@"realAmount"];

        if (![CoStringManager objectIsNull:dict forKey:@"cartItems"] &&
            [[dict objectForKey:@"cartItems"] isKindOfClass:[NSArray class]]) {
            self.cartItems = [NSMutableArray array];
            for (NSDictionary *dic in [dict objectForKey:@"cartItems"]) {
                [self.cartItems addObject:[ESCartBrand objFromDict:dic]];
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCartInfo alloc] initWithDict:dict];
}
@end
