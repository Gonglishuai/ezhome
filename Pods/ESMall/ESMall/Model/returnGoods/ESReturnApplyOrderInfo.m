//
//  ESReturnApplyOrderInfo.m
//  Consumer
//
//  Created by 焦旭 on 2017/7/13.
//  Copyright © 2017年 Easyhome Shejijia. All rights reserved.
//

#import "ESReturnApplyOrderInfo.h"
#import "CoStringManager.h"

@implementation ESReturnApplyOrderInfo

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.ordersId          = [CoStringManager judgeNSString:dict forKey:@"ordersId"];
        self.name              = [CoStringManager judgeNSString:dict forKey:@"name"];
        self.mobile            = [CoStringManager judgeNSString:dict forKey:@"mobile"];
        self.merchantMobile    = [CoStringManager judgeNSString:dict forKey:@"merchantMobile"];
        self.returnGoodsReason = [CoStringManager judgeNSString:dict forKey:@"returnGoodsReason"];
        self.remark            = [CoStringManager judgeNSString:dict forKey:@"remark"];
        self.orderType         = [CoStringManager judgeNSString:dict forKey:@"orderType"];
        self.orderStatus         = [CoStringManager judgeNSString:dict forKey:@"orderStatus"];
        
        self.itemList = [NSMutableArray array];
        if (dict && [dict objectForKey:@"itemList"]) {
            for (NSDictionary *dic in [dict objectForKey:@"itemList"]) {
                [self.itemList addObject:[ESReturnGoodsCommodity objFromDict:dic]];
            }
        }
    }
    return self;
}

+ (instancetype)objFromDict:(NSDictionary *)dict {
    return [[ESReturnApplyOrderInfo alloc] initWithDict:dict];
}
@end
