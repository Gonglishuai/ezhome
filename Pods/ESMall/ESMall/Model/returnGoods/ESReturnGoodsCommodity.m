//
//  ESReturnGoodsCommodity.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/11.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnGoodsCommodity.h"
#import "CoStringManager.h"

@implementation ESReturnGoodsCommodity

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        self.returnAmount  = [CoStringManager judgeNSString:dict forKey:@"returnAmount"];
        self.returnGoodsId = [CoStringManager judgeNSString:dict forKey:@"returnGoodsId"];
        self.orderItemId   = [CoStringManager judgeNSString:dict forKey:@"orderItemId"];
        self.payAmount     = [CoStringManager judgeNSString:dict forKey:@"payAmount"];
        self.returnedQuantity = [CoStringManager judgeNSString:dict forKey:@"returnedQuantity"];
        self.isSelected    = NO;
        
        NSInteger returnNum = [self.itemQuantity integerValue] - [self.returnedQuantity integerValue];
        self.editReturnItemNum = returnNum > 0 ? [NSString stringWithFormat:@"%ld", (long)returnNum] : @"0";
        
        if (dict && [dict objectForKey:@"returnGoodsStatus"]) {
            
            self.returnGoodsStatus = ESReturnCommodityStatusNone;
            switch ([[dict objectForKey:@"returnGoodsStatus"] integerValue]) {
                case 1:
                    self.returnGoodsStatus = ESReturnCommodityStatusUnApplied;
                    break;
                default:
                    self.returnGoodsStatus = ESReturnCommodityStatusApplied;
                    break;
            }
        }
        NSString *itemType = [NSString stringWithFormat:@"%@", dict[@"itemType"]];
        if ([dict isKindOfClass:[NSDictionary class]]
            && [itemType isEqualToString:@"1"])
        {// itemType 1 赠品
            self.returnGoodsStatus = ESReturnCommodityStatusGift;
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESReturnGoodsCommodity alloc] initWithDict:dict];
}
@end
