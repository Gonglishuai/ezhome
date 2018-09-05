//
//  ESCartCommodity.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/4.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESCartCommodity.h"

@implementation ESCartCommodity

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super initWithDict:dict];
    if (self) {
        self.cartItemId     = [CoStringManager judgeNSString:dict forKey:@"cartItemId"];
        self.originQuantity = self.itemQuantity;
        self.regionId       = [CoStringManager judgeNSString:dict forKey:@"regionId"];
        self.createTime     = [CoStringManager judgeNSString:dict forKey:@"createTime"];
        
        self.originChooseStatus = ESCommodityChooseStatusCancel;
        if (![CoStringManager objectIsNull:dict forKey:@"chooseStatus"]) {
            NSInteger chooseStatus = [[dict objectForKey:@"chooseStatus"] integerValue];
            switch (chooseStatus) {
                case 0:
                    self.originChooseStatus = ESCommodityChooseStatusCancel;
                    break;
                case 1:
                    self.originChooseStatus = ESCommodityChooseStatusSelected;
                    break;
                default:
                    break;
            }
        }
        self.chooseStatus = self.originChooseStatus;
        
        if (![CoStringManager objectIsNull:dict forKey:@"status"]) {
            NSInteger status = [[dict objectForKey:@"status"] integerValue];
            switch (status) {
                case 0:
                    self.status = ESCommodityStatusValid;
                    break;
                case 1:
                    self.status = ESCommodityStatusInvalid;
                    break;
                default:
                    self.status = ESCommodityStatusNone;
                    break;
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESCartCommodity alloc] initWithDict:dict];
}

+ (NSDictionary *)dictFromObj:(ESCartCommodity *)object {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    return dict;
}
@end
